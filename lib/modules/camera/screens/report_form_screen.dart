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
import 'package:photo_view/photo_view.dart';

import 'package:roadis/core/detection/models/detection_result.dart';
import 'package:roadis/core/detection/services/detection_service.dart';
import 'package:roadis/core/detection/services/groq_service.dart';
import 'package:roadis/core/laporan/models/wilayah_model.dart';
import 'package:roadis/modules/camera/controllers/report_form_controller.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';

import '../presentation/report_succes_screen.dart';

enum _Authority { pusat, provinsi, kabupaten, desa, unknown }

class ReportFormScreen extends StatefulWidget {
  final XFile image;
  final XFile? rawImage;
  final Position position;
  final DetectionResult? detection;
  final List<WilayahModel> wilayahList;
  final bool isUsingGroq;

  const ReportFormScreen({
    super.key,
    required this.image,
    this.rawImage,
    required this.position,
    this.detection,
    required this.wilayahList,
    this.isUsingGroq = false,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final ReportFormController _controller;
  late final String _controllerTag;
  late final DetectionService _detectionService;

  DetectionResult? _currentDetection;
  late XFile _currentImage;

  bool _isUsingGroq = false;
  bool _isSwitchingDetection = false;
  bool? _switchingToGroq;

  static const Color _primary = AppColors.primaryColor;
  static const Color _dark = AppColors.darkTextColor;
  static const Color _muted = AppColors.greyColor;
  static const Color _background = AppColors.backgroundColor;
  static const Color _line = Color(0xFFE5EDF4);
  static const Color _fieldFill = Color(0xFFF5F9FC);
  static const Color _ok = Color(0xFF168B68);
  static const Color _warn = Color(0xFFD58B25);
  static const Color _danger = Color(0xFFDC5656);
  static const Color _info = Color(0xFF168BCE);
  static const Color _softBlue = Color(0xFFEAF6FD);

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
    _currentImage = widget.image;
    _isUsingGroq = widget.isUsingGroq;

    _detectionService = DetectionService();

    _controllerTag = 'report_form_${DateTime.now().microsecondsSinceEpoch}';
    _controller = Get.put(ReportFormController(), tag: _controllerTag);

    _controller.initialize(
      image: widget.image,
      position: widget.position,
      detection: widget.detection,
      wilayahList: widget.wilayahList,
      isUsingGroq: widget.isUsingGroq,
    );
  }

  @override
  void dispose() {
    _detectionService.dispose();
    Get.delete<ReportFormController>(tag: _controllerTag);
    super.dispose();
  }

  Future<void> _switchDetectionToGroq() async {
    if (_isSwitchingDetection || _isUsingGroq) return;

    setState(() {
      _isSwitchingDetection = true;
      _switchingToGroq = true;
    });

    try {
      final source = widget.rawImage ?? widget.image;
      final bytes = await source.readAsBytes();

      if (!mounted) return;

      showAwesomeSnackbar(
        title: 'Sedang menganalisis foto',
        message: 'Mohon tunggu sebentar, Groq AI sedang memeriksa foto kamu.',
        contentType: ContentType.help,
      );

      final result = await GroqService.detectRoadDamage(bytes);

      if (!mounted) return;

      setState(() {
        _currentImage = source;
        _currentDetection = result;
        _isUsingGroq = true;
      });

      _controller.updateImage(source);
      _controller.updateDetection(result);
      _controller.isUsingGroq.value = true;

      if (result != null) {
        showAwesomeSnackbar(
          title: 'Analisis berhasil',
          message:
              'Foto berhasil dianalisis. Terindikasi ${result.displayName} dengan tingkat keyakinan ${(result.confidence * 100).toStringAsFixed(1)}%.',
          contentType: ContentType.success,
        );
      } else {
        showAwesomeSnackbar(
          title: 'Analisis selesai',
          message: 'Belum terlihat kerusakan yang dapat dikenali. Kamu tetap bisa memilih jenis kerusakan secara manual.',
          contentType: ContentType.help,
        );
      }
    } catch (e) {
      if (!mounted) return;

      showAwesomeSnackbar(
        title: 'Analisis belum berhasil',
        message: 'Groq AI belum dapat memeriksa foto. Periksa koneksi internet lalu coba lagi.',
        contentType: ContentType.failure,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSwitchingDetection = false;
          _switchingToGroq = null;
        });
      }
    }
  }

  Future<void> _selectYolo() async {
    if (_isSwitchingDetection || !_isUsingGroq) return;

    setState(() {
      _isSwitchingDetection = true;
      _switchingToGroq = false;
    });

    try {
      final source = widget.rawImage ?? widget.image;
      final bytes = await source.readAsBytes();

      if (!mounted) return;

      showAwesomeSnackbar(
        title: 'Sedang menganalisis foto',
        message: 'Mohon tunggu sebentar, YOLO sedang memeriksa foto kamu.',
        contentType: ContentType.help,
      );

      await _detectionService.loadModel();

      final detections = await _detectionService.detect(bytes);

      if (!mounted) return;

      DetectionResult? result;
      XFile displayImage = source;

      if (detections.isNotEmpty) {
        result = detections.first;

        final annotatedBytes = _detectionService.drawDetections(
          bytes,
          detections,
        );

        final annotatedPath =
            '${source.path}_yolo_${DateTime.now().microsecondsSinceEpoch}.jpg';

        await File(annotatedPath).writeAsBytes(annotatedBytes);

        displayImage = XFile(annotatedPath);
      }

      if (!mounted) return;

      setState(() {
        _currentImage = displayImage;
        _currentDetection = result;
        _isUsingGroq = false;
      });

      _controller.updateImage(displayImage);
      _controller.updateDetection(result);
      _controller.isUsingGroq.value = false;

      if (result != null) {
        showAwesomeSnackbar(
          title: 'Deteksi berhasil',
          message:
              'YOLO berhasil menemukan ${result.displayName}. Kotak penanda sudah ditampilkan pada foto.',
          contentType: ContentType.success,
        );
      } else {
        showAwesomeSnackbar(
          title: 'Pemeriksaan selesai',
          message: 'YOLO belum menemukan kerusakan pada foto. Kamu bisa memilih jenis kerusakan secara manual.',
          contentType: ContentType.help,
        );
      }
    } catch (e) {
      if (!mounted) return;

      showAwesomeSnackbar(
        title: 'Deteksi belum berhasil',
        message: e.toString().replaceFirst('Exception: ', ''),
        contentType: ContentType.failure,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSwitchingDetection = false;
          _switchingToGroq = null;
        });
      }
    }
  }

  void _showPhotoPreview() {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: PhotoView(
                  imageProvider: FileImage(File(_currentImage.path)),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  initialScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white,
                        size: 45,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 35,
                right: 15,
                child: IconButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Text(
                  'Cubit foto untuk memperbesar',
                  textAlign: TextAlign.center,
                  style: _text(
                    12,
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        title: 'Laporan belum terkirim',
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
    EdgeInsetsGeometry padding = const EdgeInsets.all(17),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _line.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF315C78).withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
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
                const SizedBox(height: 4),
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
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: _text(12, color: const Color(0xFF9AAEBC)),
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
        borderRadius: BorderRadius.circular(13),
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

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 19, 14, 19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE4F4FD), Color(0xFFD3ECFA)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bantu perbaiki\nkondisi jalan.',
                  style: _text(
                    19,
                    weight: FontWeight.w800,
                    color: _dark,
                  ).copyWith(height: 1.3),
                ),
                const SizedBox(height: 7),
                Text(
                  'Sampaikan temuan kerusakan agar dapat segera ditindaklanjuti.',
                  style: _text(11, color: const Color(0xFF58758A), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.add_road_rounded,
              size: 42,
              color: Color(0xFF168BCE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: selected ? _softBlue : Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: loading || _isSwitchingDetection ? null : onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(12, 13, 10, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected ? _primary : _line,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: _primary, size: 23),
                    const Spacer(),
                    if (loading)
                      const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _primary,
                        ),
                      )
                    else
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: selected ? _primary : const Color(0xFFCBD5DF),
                        size: 19,
                      ),
                  ],
                ),
                const SizedBox(height: 11),
                Text(title, style: _text(13, weight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: _text(10, color: _muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (loading) ...[
                  const SizedBox(height: 7),
                  Text(
                    'Sedang menganalisis...',
                    style: _text(9, color: _primary, weight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionSelector() {
    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: _primary, size: 20),
              const SizedBox(width: 9),
              Text('Metode deteksi', style: _text(14, weight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Pilih teknologi yang ingin digunakan untuk menganalisis foto.',
            style: _body,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildDetectionOption(
                title: 'YOLO',
                subtitle: 'Deteksi model lokal',
                icon: Icons.center_focus_strong_rounded,
                selected: !_isUsingGroq,
                loading: _isSwitchingDetection && _switchingToGroq == false,
                onTap: _selectYolo,
              ),
              const SizedBox(width: 10),
              _buildDetectionOption(
                title: 'Groq AI',
                subtitle: 'Analisis gambar',
                icon: Icons.psychology_alt_rounded,
                selected: _isUsingGroq,
                loading: _isSwitchingDetection && _switchingToGroq == true,
                onTap: _switchDetectionToGroq,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto() {
    final now = _controller.waktu;
    String two(int n) => n.toString().padLeft(2, '0');

    final stamp =
        '${two(now.day)}/${two(now.month)}/${now.year} • ${two(now.hour)}:${two(now.minute)} WIB';

    return ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showPhotoPreview,
            child: Image.file(
              File(_currentImage.path),
              key: ValueKey(_currentImage.path),
              width: double.infinity,
              height: 225,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 225,
                color: _line,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined, size: 38),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xDD172B3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.zoom_in_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Perbesar',
                    style: _text(
                      10,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xDD172B3A),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    stamp,
                    style: _text(
                      10,
                      color: Colors.white,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
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
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: _primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil deteksi',
                      style: _text(14, weight: FontWeight.w800),
                    ),
                    Text(
                      _isUsingGroq ? 'Analisis Groq AI' : 'Analisis YOLO',
                      style: _text(10, color: _muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isUsingGroq ? 'GROQ AI' : 'YOLO',
                  style: _text(9, weight: FontWeight.w800, color: _primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          if (d == null)
            _notice(
              icon: Icons.info_outline_rounded,
              color: _warn,
              title: 'Belum ada hasil deteksi',
              message: 'Belum ditemukan kerusakan yang dapat dikenali. Kamu tetap bisa memilih jenis kerusakan secara manual.',
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: _softBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: _primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.displayName,
                        style: _text(17, weight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text('Jenis kerusakan terdeteksi', style: _body),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(confidence * 100).toStringAsFixed(1)}%',
                      style: _text(
                        21,
                        weight: FontWeight.w800,
                        color: barColor,
                      ),
                    ),
                    Text('Keyakinan', style: _text(9, color: _muted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 7,
                backgroundColor: _line,
                color: barColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strong
                  ? 'Tingkat keyakinan tinggi. Tetap periksa kembali hasil deteksi.'
                  : 'Tingkat keyakinan belum tinggi. Pastikan jenis kerusakan sesuai foto.',
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
          _sectionHeader(
            'Informasi laporan',
            subtitle: 'Lengkapi detail kerusakan yang ditemukan.',
          ),
          const SizedBox(height: 18),
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
              'Titik lokasi laporan',
              subtitle:
                  'Geser pin pada peta. Maksimal $maxShift m dari titik GPS.',
              trailing: _chipButton(
                label: 'Ke GPS',
                onPressed: c.resetPoint,
                icon: const Icon(Icons.my_location, size: 14),
                color: _primary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 235,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
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
                const Icon(
                  Icons.location_on_outlined,
                  color: _primary,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${picked.latitude.toStringAsFixed(6)}, ${picked.longitude.toStringAsFixed(6)}',
                    style: _text(10, weight: FontWeight.w600),
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
                borderRadius: BorderRadius.circular(13),
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
              'Informasi ruas jalan',
              subtitle: 'Data jalan berdasarkan OpenStreetMap.',
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: _line)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF315C78).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final loading = _controller.isSubmitting.value;

          return SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Kirim laporan',
                          style: _text(
                            14,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: _primary, size: 8),
                    const SizedBox(width: 6),
                    Text(
                      'Draft',
                      style: _text(
                        10,
                        weight: FontWeight.w800,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(16, 17, 16, 26),
          children: [
            _buildIntro(),
            const SizedBox(height: 17),
            _buildDetectionSelector(),
            const SizedBox(height: 17),
            _buildPhoto(),
            const SizedBox(height: 14),
            _buildDetectionCard(),
            const SizedBox(height: 17),
            _buildFormCard(),
            const SizedBox(height: 17),
            _buildMapCard(),
            const SizedBox(height: 17),
            _buildRoadCard(),
          ],
        ),
      ),
    );
  }
}
