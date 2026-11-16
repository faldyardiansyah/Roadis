import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:roadis/core/detection/models/detection_result.dart';
import 'package:roadis/core/detection/services/groq_service.dart';
import 'package:roadis/core/laporan/models/wilayah_model.dart';
import 'package:roadis/modules/camera/controllers/report_form_controller.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';

import '../presentation/report_succes_screen.dart';

/// Perkiraan pihak yang bertanggung jawab atas ruas jalan.
enum _Authority { pusat, provinsi, kabupaten, desa, unknown }

class ReportFormScreen extends StatefulWidget {
  final XFile image;
  final XFile? rawImage;
  final Position position;
  final DetectionResult? detection;
  final List<WilayahModel> wilayahList;

  const ReportFormScreen({
    super.key,
    required this.image,
    this.rawImage,
    required this.position,
    this.detection,
    this.wilayahList = const [],
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final ReportFormController _controller;
  late final String _controllerTag;

  DetectionResult? _currentDetection;
  bool _isSwitchingToGroq = false;

  // Warna
  static const Color _primary = AppColors.primaryColor;
  static const Color _dark = AppColors.darkTextColor;
  static const Color _muted = AppColors.greyColor;
  static const Color _background = AppColors.backgroundColor;
  static const Color _line = Color(0xFFE2E8F0);
  static const Color _fieldFill = Color(0xFFF8FAFC);
  static const Color _ok = Color(0xFF16A34A);
  static const Color _warn = Color(0xFFD97706);
  static const Color _danger = Color(0xFFDC2626);
  static const Color _info = Color(0xFF0284C7);

  // Pemetaan tipe jalan OSM / nilai kewenangan -> penanggung jawab
  static const _pusatTypes = {
    'nasional',
    'trunk',
    'trunk_link',
    'motorway',
    'motorway_link',
  };
  static const _provinsiTypes = {'provinsi', 'primary', 'primary_link'};
  static const _desaTypes = {
    'desa',
    'residential',
    'living_street',
    'unclassified',
    'service',
    'track',
    'path',
    'road',
  };
  static const _kabupatenTypes = {
    'kabupaten',
    'secondary',
    'secondary_link',
    'tertiary',
    'tertiary_link',
  };

  @override
  void initState() {
    super.initState();

    _currentDetection = widget.detection;
    _controllerTag = 'report_form_${DateTime.now().microsecondsSinceEpoch}';
    _controller = Get.put(ReportFormController(), tag: _controllerTag);

    _controller.initialize(
      image: widget.image,
      position: widget.position,
      detection: widget.detection,
      wilayahList: widget.wilayahList,
    );
  }

  @override
  void dispose() {
    Get.delete<ReportFormController>(tag: _controllerTag);
    super.dispose();
  }

  Future<void> _switchDetectionToGroq() async {
    if (_isSwitchingToGroq) return;

    setState(() => _isSwitchingToGroq = true);

    try {
      final source = widget.rawImage ?? widget.image;
      final bytes = await source.readAsBytes();
      final result = await GroqService.detectRoadDamage(bytes);

      if (!mounted) return;

      if (result != null) {
        setState(() => _currentDetection = result);
        _controller.updateDetection(result);

        showAwesomeSnackbar(
          title: 'Deteksi Groq AI berhasil',
          message:
              'Terdeteksi: ${result.displayName} (${(result.confidence * 100).toStringAsFixed(1)}%)',
          contentType: ContentType.success,
        );
      } else {
        showAwesomeSnackbar(
          title: 'Groq AI',
          message: 'Groq tidak menemukan pola kerusakan yang spesifik.',
          contentType: ContentType.help,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showAwesomeSnackbar(
        title: 'Groq AI gagal dipakai',
        message: e.toString().replaceFirst('Exception: ', ''),
        contentType: ContentType.failure,
      );
    } finally {
      if (mounted) setState(() => _isSwitchingToGroq = false);
    }
  }

  Future<void> _submitReport() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    try {
      final reportData = await _controller.submitReport();

      if (!mounted || reportData == null) return;

      HapticFeedback.mediumImpact();

      Get.off(() => ReportSuccessScreen(report: reportData));
    } catch (e) {
      if (!mounted) return;

      showAwesomeSnackbar(
        title: 'Laporan gagal dikirim',
        message: e.toString().replaceFirst('Exception: ', ''),
        contentType: ContentType.failure,
      );
    }
  }

  _Authority _resolveAuthority(String jenis, String kewenangan) {
    bool has(String s) => kewenangan.contains(s);

    if (has('nasional') ||
        has('pusat') ||
        has('pupr') ||
        _pusatTypes.contains(jenis)) {
      return _Authority.pusat;
    }
    if (has('provinsi') || has('jabar') || _provinsiTypes.contains(jenis)) {
      return _Authority.provinsi;
    }
    if (has('pemdes') || has('desa') || _desaTypes.contains(jenis)) {
      return _Authority.desa;
    }
    if (has('kabupaten') ||
        has('dinas pu') ||
        _kabupatenTypes.contains(jenis)) {
      return _Authority.kabupaten;
    }
    return _Authority.unknown;
  }

  String _authorityLabel(_Authority a) {
    switch (a) {
      case _Authority.pusat:
        return 'Pemerintah Pusat (Kementerian PU)';
      case _Authority.provinsi:
        return 'Pemerintah Provinsi Jawa Barat';
      case _Authority.kabupaten:
        return 'Pemerintah Kab. Indramayu';
      case _Authority.desa:
        return 'Pemerintah Desa';
      case _Authority.unknown:
        return 'Belum dapat dipastikan';
    }
  }

  String _authorityNote(_Authority a) {
    switch (a) {
      case _Authority.pusat:
        return 'Ruas ini kewenangan Pemerintah Pusat (Kementerian PU). '
            'Karena berada di Kabupaten Indramayu, laporanmu tetap diterima, '
            'diverifikasi, dan dikoordinasikan oleh Dinas PU Kab. Indramayu '
            'dan Superadmin.';
      case _Authority.provinsi:
        return 'Ruas ini kewenangan Pemerintah Provinsi Jawa Barat '
            '(Dinas Bina Marga). Laporan tetap diterima dan diteruskan oleh '
            'Dinas PU Kab. Indramayu dan Superadmin.';
      case _Authority.desa:
        return 'Ruas jalan lingkungan ini berada di bawah kewenangan teknis '
            'Pemerintah Desa setempat.';
      case _Authority.kabupaten:
        return 'Ruas ini dikelola Pemerintah Kabupaten Indramayu '
            '(Dinas PUPR Kab. Indramayu).';
      case _Authority.unknown:
        return 'Penanggung jawab ruas ini belum bisa dipastikan dari data '
            'peta. Laporanmu tetap akan ditinjau oleh Dinas PU Kab. Indramayu.';
    }
  }

  String _jenisJalanLabel(String jenis) {
    switch (jenis) {
      case 'residential':
        return 'Jalan permukiman';
      case 'living_street':
        return 'Jalan lingkungan';
      case 'primary':
      case 'primary_link':
        return 'Arteri utama';
      case 'secondary':
      case 'secondary_link':
        return 'Arteri sekunder';
      case 'tertiary':
      case 'tertiary_link':
        return 'Jalan penghubung';
      case 'motorway':
      case 'motorway_link':
        return 'Jalan bebas hambatan';
      case 'trunk':
      case 'trunk_link':
        return 'Jalan utama';
      case 'unclassified':
        return 'Jalan lokal';
      case 'service':
        return 'Jalan akses';
      case 'track':
        return 'Jalan akses lahan';
      case 'road':
        return 'Jenis belum diketahui';
      default:
        return jenis.isEmpty ? 'Belum diketahui' : jenis;
    }
  }

  static TextStyle _text(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = _dark,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  TextStyle get _body => _text(12, color: _muted, height: 1.55);

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, {String? subtitle, Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _text(14, weight: FontWeight.w800)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle, style: _body),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }

  Widget _chipButton({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    Color color = _info,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon ?? const SizedBox.shrink(),
      label: Text(
        label,
        style: _text(11, weight: FontWeight.w700, color: color),
      ),
      style: TextButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withValues(alpha: 0.08),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: _text(12, weight: FontWeight.w700),
          children: [
            if (required)
              TextSpan(
                text: ' *',
                style: _text(12, weight: FontWeight.w700, color: _danger),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: _text(12, color: const Color(0xFF94A3B8)),
      errorStyle: _text(11, color: _danger),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(_line),
      enabledBorder: border(_line),
      focusedBorder: border(_primary, 1.5),
      errorBorder: border(_danger),
      focusedErrorBorder: border(_danger, 1.5),
    );
  }

  Widget _notice({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _text(12, weight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(message, style: _body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: _body)),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: _text(12, weight: FontWeight.w700, height: 1.4),
          ),
        ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> rows) {
    final out = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        out.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 11),
            child: Divider(height: 1, color: _line),
          ),
        );
      }
      out.add(rows[i]);
    }
    return out;
  }

  Widget _buildPhoto() {
    final now = _controller.waktu;
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp =
        '${two(now.day)}/${two(now.month)}/${now.year}, ${two(now.hour)}:${two(now.minute)} WIB';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.file(
            File(widget.image.path),
            width: double.infinity,
            height: 230,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 230,
              color: _line,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined, size: 38),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stamp,
                style: _text(11, weight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionCard() {
    final d = _currentDetection;
    final confidence = d == null
        ? 0.0
        : d.confidence.clamp(0.0, 1.0).toDouble();
    final strong = confidence >= 0.8;
    final barColor = strong ? _ok : _warn;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Hasil deteksi AI',
            subtitle: d == null
                ? 'Belum ada hasil deteksi'
                : 'Rekomendasi awal, tetap periksa lagi',
            trailing: _chipButton(
              label: _isSwitchingToGroq ? 'Memproses...' : 'Pakai Groq AI',
              onPressed: _isSwitchingToGroq ? null : _switchDetectionToGroq,
              icon: _isSwitchingToGroq
                  ? const SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _info,
                      ),
                    )
                  : const Icon(Icons.psychology_outlined, size: 15),
            ),
          ),
          const SizedBox(height: 14),
          if (d == null)
            Text(
              'Pilih jenis kerusakan secara manual di formulir, atau coba deteksi dengan Groq AI.',
              style: _body,
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    d.displayName,
                    style: _text(17, weight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${(confidence * 100).toStringAsFixed(1)}%',
                  style: _text(17, weight: FontWeight.w800, color: barColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 6,
                backgroundColor: _line,
                color: barColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strong ? 'Tingkat keyakinan tinggi.' : 'Keyakinan belum tinggi. Pastikan jenis kerusakannya sesuai dengan foto.',
              style: _body,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWilayahField() {
    return Obx(() {
      final c = _controller;
      final empty = c.wilayahList.isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Wilayah', required: true),
          DropdownButtonFormField<int>(
            value: c.wilayahList.any((w) => w.id == c.selectedWilayahId.value)
                ? c.selectedWilayahId.value
                : null,
            isExpanded: true,
            decoration: _inputDecoration('Pilih wilayah'),
            items: c.wilayahList
                .map(
                  (w) => DropdownMenuItem<int>(
                    value: w.id,
                    child: Text(
                      w.nama,
                      overflow: TextOverflow.ellipsis,
                      style: _text(12),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => c.selectedWilayahId.value = value,
            validator: (value) =>
                value == null ? 'Pilih wilayah laporan' : null,
          ),
          const SizedBox(height: 6),
          Text(
            empty
                ? 'Daftar wilayah belum termuat. Kembali ke kamera dan coba lagi.'
                : 'Pilih wilayah tempat kerusakan berada.',
            style: _body.copyWith(color: empty ? _warn : _muted),
          ),
        ],
      );
    });
  }

  Widget _buildTypeField() {
    return Obx(() {
      final c = _controller;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Jenis kerusakan', required: true),
          DropdownButtonFormField<String>(
            value: c.jenisKerusakan.contains(c.selectedType.value)
                ? c.selectedType.value
                : null,
            isExpanded: true,
            decoration: _inputDecoration('Pilih jenis kerusakan'),
            items: c.jenisKerusakan
                .map(
                  (type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type, style: _text(12)),
                  ),
                )
                .toList(),
            onChanged: (value) => c.selectedType.value = value,
            validator: (value) => (value == null || value.isEmpty)
                ? 'Pilih jenis kerusakan'
                : null,
          ),
        ],
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    int minLines = 1,
    int maxLines = 1,
    TextInputAction action = TextInputAction.next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: true),
        TextFormField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          textInputAction: action,
          textCapitalization: TextCapitalization.sentences,
          style: _text(12),
          decoration: _inputDecoration(hint),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Data laporan'),
          const SizedBox(height: 16),
          _buildWilayahField(),
          const SizedBox(height: 16),
          _buildTypeField(),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Judul',
            controller: _controller.judulController,
            hint: 'Contoh: Lubang besar di depan pasar',
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Judul wajib diisi';
              if (v.length < 5) return 'Judul minimal 5 karakter';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Deskripsi',
            controller: _controller.deskripsiController,
            hint: 'Ceritakan kondisi kerusakan dan patokan lokasinya',
            minLines: 3,
            maxLines: 5,
            action: TextInputAction.newline,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Deskripsi wajib diisi';
              if (v.length < 10) return 'Deskripsi minimal 10 karakter';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Obx(() {
      final c = _controller;
      final picked = c.pickedPoint.value ?? c.gpsPoint;
      final distance = const Distance().distance(c.gpsPoint, picked);
      final maxShift = ReportFormController.maxShiftMeters.toStringAsFixed(0);

      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              'Lokasi kerusakan',
              subtitle:
                  'Ketuk peta untuk menggeser pin, maksimal $maxShift m dari titik GPS',
              trailing: _chipButton(
                label: 'Ke GPS',
                onPressed: c.resetPoint,
                icon: const Icon(Icons.my_location, size: 14),
                color: _primary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 240,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
              ),
              child: FlutterMap(
                mapController: c.mapController,
                options: MapOptions(
                  initialCenter: c.gpsPoint,
                  initialZoom: 18,
                  onTap: (tapPosition, point) => c.onMapTap(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.roadis.app',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: c.gpsPoint,
                        radius: ReportFormController.maxShiftMeters,
                        useRadiusInMeter: true,
                        color: _primary.withValues(alpha: 0.12),
                        borderColor: _primary.withValues(alpha: 0.65),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: c.gpsPoint,
                        width: 34,
                        height: 34,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: _primary, width: 2),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: _primary,
                            size: 17,
                          ),
                        ),
                      ),
                      Marker(
                        point: picked,
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on,
                          color: _danger,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${picked.latitude.toStringAsFixed(6)}, ${picked.longitude.toStringAsFixed(6)}',
                    style: _text(12, weight: FontWeight.w600),
                  ),
                ),
                Text('${distance.toStringAsFixed(1)} m dari GPS', style: _body),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRoadCard() {
    return Obx(() {
      final c = _controller;
      final checking = c.isCheckingRoad.value;
      final error = c.roadCheckError.value;
      final detected = c.roadDetected.value;

      final jenis = (c.jenisJalanOSM.value ?? '').toLowerCase().trim();
      final kewenangan = (c.kewenanganOSM.value ?? '').toLowerCase().trim();
      final nama = (c.namaJalanOSM.value ?? '').trim();
      final jarak = c.jarakJalanOSM.value;
      final authority = _resolveAuthority(jenis, kewenangan);

      Widget body;

      if (checking) {
        body = Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
            ),
            const SizedBox(width: 12),
            Text('Memeriksa jalan di sekitar pin...', style: _body),
          ],
        );
      } else if (error != null) {
        body = _notice(
          icon: Icons.cloud_off_outlined,
          color: _warn,
          title: 'Pemeriksaan belum selesai',
          message: error,
        );
      } else if (detected == false) {
        body = _notice(
          icon: Icons.wrong_location_outlined,
          color: const Color(0xFF64748B),
          title: 'Jalan tidak ditemukan',
          message:
              c.penjelasanKewenangan.value ??
              'Geser pin lebih dekat ke badan jalan, lalu periksa ulang.',
        );
      } else if (detected == true) {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._withDividers([
              _infoRow('Nama jalan', nama.isEmpty ? 'Belum tersedia' : nama),
              _infoRow('Jenis jalan', _jenisJalanLabel(jenis)),
              _infoRow('Penanggung jawab', _authorityLabel(authority)),
              if (jarak != null)
                _infoRow('Jarak pin ke jalan', '${jarak.toStringAsFixed(1)} m'),
            ]),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: _fieldFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line),
              ),
              child: Text(_authorityNote(authority), style: _body),
            ),
          ],
        );
      } else {
        body = _notice(
          icon: Icons.help_outline,
          color: const Color(0xFF64748B),
          title: 'Belum diperiksa',
          message: 'Ketuk "Periksa ulang" untuk memeriksa jalan di pin.',
        );
      }

      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              'Informasi jalan',
              subtitle: 'Perkiraan dari data OpenStreetMap di sekitar pin',
              trailing: _chipButton(
                label: 'Periksa ulang',
                onPressed: checking
                    ? null
                    : () => c.checkRoad(c.pickedPoint.value ?? c.gpsPoint),
                icon: const Icon(Icons.refresh_rounded, size: 15),
                color: _primary,
              ),
            ),
            const SizedBox(height: 14),
            body,
          ],
        ),
      );
    });
  }

  Widget _buildSubmitBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final loading = _controller.isSubmitting.value;

          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Kirim laporan',
                      style: _text(
                        14,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: _dark,
          ),
        ),
        title: Text(
          'Detail laporan',
          style: _text(17, weight: FontWeight.w800),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _line),
        ),
      ),
      bottomNavigationBar: _buildSubmitBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _buildPhoto(),
            const SizedBox(height: 14),
            _buildDetectionCard(),
            const SizedBox(height: 14),
            _buildFormCard(),
            const SizedBox(height: 14),
            _buildMapCard(),
            const SizedBox(height: 14),
            _buildRoadCard(),
          ],
        ),
      ),
    );
  }
}
