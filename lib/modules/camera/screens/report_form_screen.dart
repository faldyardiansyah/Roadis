import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:roadis/core/detection/models/detection_result.dart';
import 'package:roadis/core/laporan/models/wilayah_model.dart';
import 'package:roadis/modules/camera/controllers/report_form_controller.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';

class ReportFormScreen extends StatefulWidget {
  final XFile image;
  final Position position;
  final DetectionResult? detection;
  final List<WilayahModel> wilayahList;

  const ReportFormScreen({
    super.key,
    required this.image,
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

  // warna utama dari app_colors
  static const Color _primary = AppColors.primaryColor;
  static const Color _dark = AppColors.darkTextColor;
  static const Color _muted = AppColors.greyColor;
  static const Color _background = AppColors.backgroundColor;
  static const Color _border = AppColors.whitetr;

  @override
  void initState() {
    super.initState();

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

  TextStyle get _titleStyle => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: _dark,
  );

  TextStyle get _bodyStyle =>
      GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted, height: 1.6);

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _titleStyle),
              const SizedBox(height: 4),
              Text(subtitle, style: _bodyStyle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.plusJakartaSans(
            color: _dark,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF94A3B8),
        fontSize: 12,
      ),
      prefixIcon: Icon(icon, size: 19, color: _muted),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildImageCard() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Image.file(
              File(widget.image.path),
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: const Color(0xFFE2E8F0),
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF15803D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Foto kerusakan jalan', style: _titleStyle),
                      const SizedBox(height: 4),
                      Text('Foto yang dipilih dari kamera', style: _bodyStyle),
                    ],
                  ),
                ),
                const Icon(Icons.verified_rounded, color: Color(0xFF16A34A)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08);
  }

  Widget _buildDetectionCard() {
    final detection = widget.detection;

    final confidence = detection == null
        ? 0.0
        : detection.confidence.clamp(0.0, 1.0).toDouble();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Hasil Deteksi AI',
            'Analisis awal dari foto kerusakan',
            Icons.auto_awesome,
          ),
          const SizedBox(height: 18),
          if (detection == null)
            _notice(
              icon: Icons.info_outline,
              color: const Color(0xFF64748B),
              title: 'Belum ada hasil deteksi',
              message:
                  'Jenis kerusakan dapat kamu pilih secara manual di formulir.',
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.center_focus_strong,
                    color: _primary,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detection.displayName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _dark,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tingkat keyakinan: ${(confidence * 100).toStringAsFixed(1)}%',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 7,
                backgroundColor: const Color(0xFFE2E8F0),
                color: confidence >= 0.8
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hasil AI merupakan rekomendasi awal. '
              'Pastikan jenis kerusakan sesuai dengan kondisi sebenarnya.',
              style: _bodyStyle,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.06);
  }

  Widget _notice({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _titleStyle),
                const SizedBox(height: 5),
                Text(message, style: _bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKewenanganCard() {
    return Obx(() {
      final c = _controller;
      final checking = c.isCheckingRoad.value;
      final error = c.roadCheckError.value;
      final detected = c.roadDetected.value;

      final jenisJalan = c.jenisJalanOSM.value ?? '';
      final kewenangan = c.kewenanganOSM.value ?? '';
      final namaJalan = c.namaJalanOSM.value;

      String labelJenisJalan(String jenis) {
        switch (jenis.toLowerCase().trim()) {
          case 'residential':
            return 'Residential (jalan permukiman)';
          case 'living_street':
            return 'Living street (jalan lingkungan)';
          case 'primary':
          case 'primary_link':
            return 'Primary (jalan arteri utama)';
          case 'secondary':
          case 'secondary_link':
            return 'Secondary (jalan arteri sekunder)';
          case 'tertiary':
          case 'tertiary_link':
            return 'Tertiary (jalan penghubung)';
          case 'motorway':
          case 'motorway_link':
            return 'Motorway (jalan bebas hambatan)';
          case 'trunk':
          case 'trunk_link':
            return 'Trunk (jalan utama)';
          case 'unclassified':
            return 'Unclassified (jalan lokal)';
          case 'service':
            return 'Service (jalan akses)';
          case 'track':
            return 'Track (jalan akses lahan)';
          case 'road':
            return 'Road (jenis jalan belum diketahui)';
          default:
            return jenis.isEmpty ? 'Belum diketahui' : jenis;
        }
      }

      String labelPenanggungJawab(String nilai) {
        switch (nilai.toLowerCase().trim()) {
          case 'pemdes':
          case 'desa':
          case 'pemerintah desa':
          case 'pemerintah desa (pemdes)':
            return 'Pemerintah Desa (Pemdes)';
          case 'kabupaten':
          case 'pemerintah kabupaten':
          case 'pemerintah kabupaten / dinas pu':
            return 'Pemerintah Kabupaten';
          case 'provinsi':
          case 'pemerintah provinsi':
            return 'Pemerintah Provinsi';
          case 'nasional':
          case 'pemerintah pusat':
          case 'pemerintah pusat / kementerian pu':
          case 'perkiraan pemerintah pusat (nasional)':
            return 'Perkiraan Pemerintah Pusat (Nasional)';
          default:
            return 'Belum dapat dipastikan';
        }
      }

      final penanggungJawab = labelPenanggungJawab(kewenangan);

      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              'Informasi Jalan',
              'Informasi jenis jalan dan perkiraan penanggung jawab',
              Icons.account_balance_outlined,
            ),
            const SizedBox(height: 18),

            if (checking)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(color: _primary),
                ),
              )
            else if (error != null)
              _notice(
                icon: Icons.cloud_off_outlined,
                color: const Color(0xFFF59E0B),
                title: 'Pemeriksaan belum selesai',
                message: error,
              )
            else if (detected == false)
              _notice(
                icon: Icons.wrong_location_outlined,
                color: const Color(0xFF64748B),
                title: 'Jalan tidak ditemukan',
                message:
                    c.penjelasanKewenangan.value ??
                    'Geser pin lebih dekat ke badan jalan, lalu periksa ulang.',
              )
            else if (detected == true) ...[
              // Status pemeriksaan jalan
              _notice(
                icon: Icons.check_circle_outline,
                color: const Color(0xFF16A34A),
                title: 'Jalan berhasil diperiksa',
                message: namaJalan == null || namaJalan.trim().isEmpty
                    ? 'Jenis jalan berhasil ditemukan dari OpenStreetMap. Nama jalan belum tersedia.'
                    : 'Nama jalan: $namaJalan',
              ),

              const SizedBox(height: 16),

              // Jenis jalan
              _roadInfoRow(
                Icons.route_outlined,
                'Jenis jalan',
                labelJenisJalan(jenisJalan),
              ),

              const Divider(height: 24, color: _border),

              // Perkiraan penanggung jawab
              _roadInfoRow(
                Icons.account_balance_outlined,
                'Perkiraan penanggung jawab',
                penanggungJawab,
              ),

              const SizedBox(height: 14),

              // Catatan untuk warga
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFD97706),
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Catatan untuk warga',
                            style: _titleStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Instansi penanggung jawab ditampilkan berdasarkan '
                      'perkiraan dari jenis jalan OpenStreetMap. '
                      'Jika belum terverifikasi, penanggung jawab masih '
                      'perlu diperiksa oleh admin.',
                      style: _bodyStyle,
                    ),
                  ],
                ),
              ),

              if (c.jarakJalanOSM.value != null) ...[
                const Divider(height: 24, color: _border),
                _roadInfoRow(
                  Icons.social_distance_outlined,
                  'Jarak ke jalan',
                  '${c.jarakJalanOSM.value!.toStringAsFixed(1)} meter',
                ),
              ],
            ] else
              _notice(
                icon: Icons.help_outline,
                color: const Color(0xFF64748B),
                title: 'Belum diperiksa',
                message: 'Ketuk tombol di bawah untuk memeriksa jalan.',
              ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: checking
                    ? null
                    : () => c.checkRoad(c.pickedPoint.value ?? c.gpsPoint),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Periksa ulang jalan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _border),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.06);
    });
  }

  Widget _roadInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: _muted),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: _bodyStyle)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.plusJakartaSans(
              color: _dark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWawasanCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Panduan Pelaporan',
            'Pastikan informasi laporan sesuai kondisi lapangan',
            Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(height: 16),
          _bullet('Gunakan foto yang jelas dan memperlihatkan kerusakan.'),
          _bullet('Periksa kembali titik lokasi pada peta sebelum mengirim.'),
          _bullet(
            'Pastikan judul, deskripsi, dan jenis kerusakan sudah sesuai.',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.06);
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: _bodyStyle)),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    final now = _controller.waktu;

    String two(int n) => n.toString().padLeft(2, '0');

    final time = '${two(now.hour)}:${two(now.minute)}';
    final date = '${two(now.day)}/${two(now.month)}/${now.year}';

    return _card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.schedule_rounded, color: _primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Waktu laporan', style: _titleStyle),
                const SizedBox(height: 5),
                Text('$date • $time WIB', style: _bodyStyle),
              ],
            ),
          ),
          const Icon(Icons.verified_outlined, color: Color(0xFF16A34A)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildWilayahField() {
    return Obx(() {
      final c = _controller;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Wilayah laporan', required: true),
          DropdownButtonFormField<int>(
            value: c.wilayahList.any((w) => w.id == c.selectedWilayahId.value)
                ? c.selectedWilayahId.value
                : null,
            isExpanded: true,
            decoration: _inputDecoration(
              hint: 'Pilih wilayah laporan',
              icon: Icons.location_city_outlined,
            ),
            items: c.wilayahList.map((w) {
              return DropdownMenuItem<int>(
                value: w.id,
                child: Text(
                  w.nama,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: _dark,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              c.selectedWilayahId.value = value;
            },
            validator: (value) {
              if (value == null) {
                return 'Silakan pilih wilayah laporan';
              }
              return null;
            },
          ),
          const SizedBox(height: 7),
          Text(
            'Wilayah harus sesuai dengan lokasi kerusakan.',
            style: _bodyStyle,
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
            decoration: _inputDecoration(
              hint: 'Pilih jenis kerusakan jalan',
              icon: Icons.broken_image_outlined,
            ),
            items: c.jenisKerusakan.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: GoogleFonts.plusJakartaSans(
                    color: _dark,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              c.selectedType.value = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Silakan pilih jenis kerusakan';
              }
              return null;
            },
          ),
        ],
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: true),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(color: _dark, fontSize: 12),
          decoration: _inputDecoration(hint: hint, icon: icon),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    return Obx(() {
      final c = _controller;
      final picked = c.pickedPoint.value ?? c.gpsPoint;

      final distance = const Distance().distance(c.gpsPoint, picked);

      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              'Lokasi Kerusakan',
              'Ketuk peta untuk mengatur titik laporan',
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            Container(
              height: 260,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
              ),
              child: FlutterMap(
                mapController: c.mapController,
                options: MapOptions(
                  initialCenter: c.gpsPoint,
                  initialZoom: 18,
                  onTap: (tapPosition, point) {
                    c.onMapTap(point);
                  },
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
                        width: 42,
                        height: 42,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: _primary, width: 2),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: _primary,
                            size: 20,
                          ),
                        ),
                      ),
                      Marker(
                        point: picked,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFFDC2626),
                          size: 43,
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
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  _roadInfoRow(
                    Icons.gps_fixed,
                    'Latitude',
                    picked.latitude.toStringAsFixed(7),
                  ),
                  const SizedBox(height: 10),
                  _roadInfoRow(
                    Icons.gps_fixed,
                    'Longitude',
                    picked.longitude.toStringAsFixed(7),
                  ),
                  const SizedBox(height: 10),
                  _roadInfoRow(
                    Icons.social_distance_outlined,
                    'Jarak dari GPS',
                    '${distance.toStringAsFixed(1)} meter',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 17, color: _primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Titik pin dibatasi maksimal 5 meter dari titik GPS.',
                    style: _bodyStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: c.resetPoint,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Kembali ke lokasi GPS'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _border),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.06);
    });
  }

  Future<void> _submitReport() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final reportData = await _controller.submitReport();

      if (!mounted || reportData == null) return;

      Get.back(result: reportData);

      showAwesomeSnackbar(
        title: 'Berhasil',
        message: 'Data laporan berhasil disiapkan.',
        contentType: ContentType.success,
      );
    } catch (e) {
      if (!mounted) return;

      showAwesomeSnackbar(
        title: 'Gagal',
        message: 'Terjadi kesalahan saat menyiapkan laporan.',
        contentType: ContentType.failure,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: _dark,
          ),
        ),
        title: Text(
          'Detail Laporan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _dark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.17),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lengkapi Laporan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Periksa data sebelum mengirim laporan jalan.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.06),
              const SizedBox(height: 18),

              _buildImageCard(),
              const SizedBox(height: 15),

              _buildDetectionCard(),
              const SizedBox(height: 15),

              _buildKewenanganCard(),
              const SizedBox(height: 15),

              _buildWawasanCard(),
              const SizedBox(height: 15),

              _buildTimeCard(),
              const SizedBox(height: 22),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      'Informasi Laporan',
                      'Lengkapi informasi kerusakan jalan',
                      Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: 22),

                    _buildWilayahField(),
                    const SizedBox(height: 18),

                    _buildTypeField(),
                    const SizedBox(height: 18),

                    _buildTextField(
                      label: 'Judul laporan',
                      controller: _controller.judulController,
                      hint: 'Contoh: Jalan berlubang di jalan utama',
                      icon: Icons.title_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul laporan wajib diisi';
                        }
                        if (value.trim().length < 5) {
                          return 'Judul minimal 5 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _buildTextField(
                      label: 'Deskripsi kerusakan',
                      controller: _controller.deskripsiController,
                      hint: 'Jelaskan kondisi dan lokasi kerusakan...',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi wajib diisi';
                        }
                        if (value.trim().length < 10) {
                          return 'Deskripsi minimal 10 karakter';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.06),

              const SizedBox(height: 15),
              _buildMapCard(),
              const SizedBox(height: 22),

              Obx(() {
                final loading = _controller.isSubmitting.value;

                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, size: 19),
                              const SizedBox(width: 10),
                              Text(
                                'Kirim Laporan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }).animate().fadeIn(delay: 320.ms).slideY(begin: 0.08),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Pastikan data yang kamu kirim sudah benar.',
                  style: _bodyStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
