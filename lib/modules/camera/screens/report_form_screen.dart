import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;

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

  @override
  void initState() {
    super.initState();

    final detectionName = widget.detection?.displayName;

    _selectedType = detectionName;

    _judulController = TextEditingController(
      text: detectionName != null ? 'Kerusakan $detectionName' : '',
    );

    _deskripsiController = TextEditingController(
      text: detectionName != null ? 'Ditemukan $detectionName pada jalan.' : '',
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

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

        'latitude': widget.position.latitude,
        'longitude': widget.position.longitude,

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
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
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
      
                // LOKASI
                _buildLocationCard()
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

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi Terdeteksi',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.position.latitude.toStringAsFixed(6)}, '
                  '${widget.position.longitude.toStringAsFixed(6)}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
