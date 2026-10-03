import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:roadis/core/detection/models/detection_result.dart';
import 'package:roadis/core/laporan/models/wilayah_model.dart';
import 'package:roadis/utils/app_colors.dart';

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
  static const double _maxShiftMeters = 8; // batas geser pin dari GPS

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;

  final MapController _mapController = MapController();
  final Distance _distance = const Distance();
  late final LatLng _gpsPoint; // titik asli dari GPS
  late LatLng _pickedPoint; // titik pin yang dipilih

  final DateTime _waktu = DateTime.now(); // jam saat laporan dibuat

  String? _selectedType;
  int? _selectedWilayahId;

  bool _isSubmitting = false;

  final List<String> _jenisKerusakan = [
    'Retak Buaya',
    'Retak Tepi',
    'Retak Memanjang',
    'Tambalan',
    'Lubang Jalan',
    'Jalan Bergelombang',
    'Retak Melintang',
  ];

  // pagi sampai siang (06:00-14:59) = AI paling bagus
  bool get _isGoodTime => _waktu.hour >= 6 && _waktu.hour < 15;

  // sore (15:00-17:59) = mulai kurang bagus
  bool get _isEvening => _waktu.hour >= 15 && _waktu.hour < 18;

  @override
  void initState() {
    super.initState();

    final det = widget.detection;
    // isi otomatis hanya kalau waktunya bagus dan AI yakin
    final confident = det != null && det.confidence >= 0.8 && _isGoodTime;
    final name = confident ? det.displayName : null;
    _selectedType = name;
    _judulController = TextEditingController(
      text: name != null ? 'Kerusakan $name' : '',
    );
    _deskripsiController = TextEditingController(
      text: name != null ? 'Ditemukan $name pada jalan.' : '',
    );

    _gpsPoint = LatLng(widget.position.latitude, widget.position.longitude);
    _pickedPoint = _gpsPoint;
    _detectWilayah(_pickedPoint);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ---------- JAM ----------

  String _two(int n) => n.toString().padLeft(2, '0'); 

  String get _jamText => '${_two(_waktu.hour)}:${_two(_waktu.minute)}';

  String get _tanggalText =>
      '${_two(_waktu.day)}/${_two(_waktu.month)}/${_waktu.year}';

  // ---------- LOKASI & WILAYAH ----------

  // kalau titik di luar zona, tempel ke tepi lingkaran
  LatLng _clampToZone(LatLng p) {
    final d = _distance.distance(_gpsPoint, p);
    if (d <= _maxShiftMeters) return p;
    final bearing = _distance.bearing(_gpsPoint, p);
    return _distance.offset(_gpsPoint, _maxShiftMeters, bearing);
  }

  // pin pindah ke titik yang diketuk (maksimal di tepi zona)
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    final outside = _distance.distance(_gpsPoint, point) > _maxShiftMeters;
    final clamped = _clampToZone(point);

    setState(() => _pickedPoint = clamped);
    _detectWilayah(clamped);

    if (outside) {
      Get.snackbar(
        'Di luar zona',
        'Titik hanya boleh dalam ${_maxShiftMeters.toInt()} m dari lokasi GPS.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // balikin pin ke titik GPS
  void _resetPoint() {
    setState(() => _pickedPoint = _gpsPoint);
    _mapController.move(_gpsPoint, 20);
    _detectWilayah(_gpsPoint);
  }

  // buang kata kabupaten/kota/dll biar nama gampang dicocokin
  String _norm(String s) => s
      .toLowerCase()
      .replaceAll(
        RegExp(r'kabupaten|kab\.|kota|kecamatan|kec\.|kelurahan|desa'),
        '',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // cari nama wilayah dari koordinat, lalu cocokin ke daftar wilayah
  Future<void> _detectWilayah(LatLng p) async {
    if (widget.wilayahList.isEmpty) return;
    try {
      final marks = await geo.placemarkFromCoordinates(p.latitude, p.longitude);
      if (marks.isEmpty) return;

      final m = marks.first;
      final candidates = [
        m.subLocality,
        m.locality,
        m.subAdministrativeArea,
        m.administrativeArea,
      ].whereType<String>().map(_norm).where((e) => e.isNotEmpty).toList();

      debugPrint('Geocode: $candidates'); // lihat ini buat nyocokin nama

      for (final w in widget.wilayahList) {
        final name = _norm(w.nama);
        if (name.isEmpty) continue;
        if (candidates.any((c) => c.contains(name) || name.contains(c))) {
          if (mounted) setState(() => _selectedWilayahId = w.id);
          return;
        }
      }
    } catch (e) {
      debugPrint('Gagal deteksi wilayah: $e');
    }
  }

  // ---------- SUBMIT ----------

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWilayahId == null) {
      Get.snackbar(
        'Wilayah belum dipilih',
        'Silakan pilih wilayah laporan terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reportData = {
        'judul': _judulController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'tipe_kerusakan': _selectedType,
        'wilayah_id': _selectedWilayahId,

        'latitude': _pickedPoint.latitude, // titik pin
        'longitude': _pickedPoint.longitude,
        'gps_latitude': widget.position.latitude, // titik GPS asli
        'gps_longitude': widget.position.longitude,
        'lokasi_digeser': _distance.distance(_gpsPoint, _pickedPoint) > 0.5,

        'waktu_laporan': _waktu.toIso8601String(), // jam laporan dibuat

        'image_path': widget.image.path,

        'ai_class': widget.detection?.className,
        'ai_confidence': widget.detection?.confidence,
      };

      debugPrint('DATA LAPORAN: $reportData');

      // TODO:
      // Panggil API upload laporan di sini.

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Get.back(result: reportData);

      Get.snackbar(
        'Berhasil',
        'Data laporan siap dikirim.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          title: Text(
            'Detail Laporan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO
                _buildImageCard()
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(height: 18),

                // HASIL AI
                _buildDetectionCard()
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 500.ms)
                    .slideX(begin: 0.08, end: 0),

                const SizedBox(height: 12),

                // JAM
                _buildTimeCard()
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 500.ms)
                    .slideX(begin: 0.08, end: 0),

                const SizedBox(height: 18),

                // FORM
                Text(
                  'Informasi Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 14),

                // WILAYAH
                _buildWilayahField()
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 450.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 14),

                // TIPE KERUSAKAN
                _buildTypeField()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 450.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 14),

                // JUDUL
                _buildTextField(
                      controller: _judulController,
                      label: 'Judul Laporan',
                      hint: 'Masukkan judul laporan',
                      icon: Icons.title_rounded,
                    )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 450.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 14),

                // DESKRIPSI
                _buildTextField(
                      controller: _deskripsiController,
                      label: 'Deskripsi',
                      hint: 'Jelaskan kondisi jalan',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 450.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 18),

                // PETA
                _buildMapCard()
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 450.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // SUBMIT
                SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          disabledBackgroundColor: Colors.grey.shade400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kirim Laporan',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.file(File(widget.image.path), fit: BoxFit.cover),
    );
  }

  Widget _buildDetectionCard() {
    final detection = widget.detection;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasil Deteksi AI',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detection?.displayName ?? 'Tidak terdeteksi',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Periksa kembali, hasil AI bisa keliru',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (detection != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                detection.confidencePercent,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // kartu jam: hijau (pagi-siang), oranye (sore), merah (malam)
  Widget _buildTimeCard() {
    final Color color;
    final IconData icon;
    final String status;
    final String note;

    if (_isGoodTime) {
      color = Colors.green;
      icon = Icons.wb_sunny_rounded;
      status = 'Waktu ideal untuk AI';
      note = 'Pagi sampai siang, hasil deteksi paling akurat.';
    } else if (_isEvening) {
      color = Colors.orange;
      icon = Icons.wb_twilight_rounded;
      status = 'Cahaya mulai berkurang';
      note = 'Sore hari, akurasi AI bisa menurun. Periksa kembali hasilnya.';
    } else {
      color = Colors.red;
      icon = Icons.nights_stay_rounded;
      status = 'Malam hari';
      note = 'Hasil AI kurang bisa diandalkan. Pastikan jenis kerusakan benar.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_tanggalText  •  $_jamText',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // kartu peta: pin bisa dipindah, tapi cuma di dalam lingkaran
  Widget _buildMapCard() {
    final moved = _distance.distance(_gpsPoint, _pickedPoint) > 0.5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lokasi Kerusakan',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (moved)
                TextButton.icon(
                  onPressed: _resetPoint,
                  icon: const Icon(Icons.my_location, size: 16),
                  label: Text(
                    'Reset ke GPS',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _gpsPoint,
                  initialZoom: 20,
                  minZoom: 17,
                  maxZoom: 21,
                  onTap: _onMapTap,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.roadis',
                    maxNativeZoom: 19,
                    maxZoom: 21,
                  ),
                  // lingkaran zona 8 m
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _gpsPoint,
                        radius: _maxShiftMeters,
                        useRadiusInMeter: true,
                        color: AppColors.primaryColor.withOpacity(0.15),
                        borderColor: AppColors.primaryColor,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                  // pin merah
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pickedPoint,
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_pickedPoint.latitude.toStringAsFixed(6)}, '
            '${_pickedPoint.longitude.toStringAsFixed(6)}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Ketuk peta untuk menggeser titik. Maksimal ${_maxShiftMeters.toInt()} m dari lokasi GPS (area biru).',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWilayahField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Wilayah Laporan'),

        const SizedBox(height: 7),

        DropdownButtonFormField<int>(
          value: _selectedWilayahId,
          decoration: _inputDecoration(
            Icons.location_city_outlined,
            'Pilih wilayah',
          ),
          items: widget.wilayahList.map((wilayah) {
            return DropdownMenuItem<int>(
              value: wilayah.id,
              child: Text(
                wilayah.nama,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedWilayahId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Wilayah wajib dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Jenis Kerusakan'),

        const SizedBox(height: 7),

        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: _inputDecoration(
            Icons.warning_amber_rounded,
            'Pilih jenis kerusakan',
          ),
          items: _jenisKerusakan.map((jenis) {
            return DropdownMenuItem<String>(
              value: jenis,
              child: Text(jenis, style: GoogleFonts.poppins(fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jenis kerusakan wajib dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),

        const SizedBox(height: 7),

        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: _inputDecoration(icon, hint),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label wajib diisi';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
