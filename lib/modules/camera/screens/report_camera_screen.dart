import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:roadis/core/detection/models/detection_result.dart';
import 'package:roadis/core/detection/services/detection_service.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';
import './report_form_screen.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ReportCameraScreen extends StatefulWidget {
  const ReportCameraScreen({super.key});

  @override
  State<ReportCameraScreen> createState() => _ReportCameraScreenState();
}

class _ReportCameraScreenState extends State<ReportCameraScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  final DetectionService _detectionService = DetectionService();

  bool _isProcessing = false;
  bool _modelLoaded = false;
  bool _isFlashOn = false;

  XFile? _image;
  Position? _currentPosition;
  DetectionResult? _bestDetection;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('Kamera tidak ditemukan.');
      }

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _cameraController!.initialize();

      await _initializeControllerFuture;

      try {
        await _cameraController!.setExposureOffset(0.5);
      } catch (e) {
        debugPrint('Exposure tidak didukung: $e');
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        showAwesomeSnackbar(
          title: 'Gagal',
          message: 'Gagal mengakses kamera: $e',
          contentType: ContentType.failure,
        );
      }
    }
  }

  Future<void> _turnOffFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      await _cameraController!.setFlashMode(FlashMode.off);
    } catch (e) {
      debugPrint('Gagal matikan flash: $e');
    }
    if (mounted) setState(() => _isFlashOn = false);
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }

      if (mounted) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    } catch (e) {
      debugPrint('Flash tidak tersedia: $e');

      if (mounted) {
        showAwesomeSnackbar(
          title: 'Flash',
          message: 'Flash tidak tersedia pada kamera ini.',
          contentType: ContentType.failure,
        );
      }
    }
  }

  Future<void> _loadModel() async {
    try {
      await _detectionService.loadModel();

      if (mounted) {
        setState(() {
          _modelLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Gagal load model: $e');

      if (mounted) {
        showAwesomeSnackbar(
          title: 'Gagal',
          message: 'Gagal load model deteksi kerusakan.',
          contentType: ContentType.failure,
        );
      }
    }
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        showAwesomeSnackbar(
          title: 'Lokasi',
          message: 'Aktifkan GPS terlebih dahulu.',
          contentType: ContentType.failure,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showAwesomeSnackbar(
          title: 'Lokasi',
          message: 'Izin lokasi diperlukan.',
          contentType: ContentType.failure,
        );
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Gagal mendapatkan lokasi: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _cameraController!.takePicture();
      await _turnOffFlash();
      await _getLocation();
      if (_currentPosition == null) {
        throw Exception('Lokasi tidak berhasil didapatkan.');
      }

      DetectionResult? bestDetection;
      XFile displayImage = image;

      if (_modelLoaded) {
        final imageBytes = await image.readAsBytes();
        final detections = await _detectionService.detect(imageBytes);

        if (detections.isNotEmpty) {
          bestDetection = detections.first;

          final annotated = _detectionService.drawDetections(
            imageBytes,
            detections,
          );
          final path = '${image.path}_det.jpg';
          await File(path).writeAsBytes(annotated);
          displayImage = XFile(path);
        }
      }

      _image = image;
      _bestDetection = bestDetection;

      if (!mounted) return;

      await Get.to(
        () => ReportFormScreen(
          image: displayImage,
          position: _currentPosition!,
          detection: bestDetection,
        ),
      );
    } catch (e) {
      if (mounted) {
        showAwesomeSnackbar(
          title: 'Gagal',
          message: e.toString().replaceFirst('Exception: ', ''),
          contentType: ContentType.failure,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _cameraController!.setFlashMode(FlashMode.off);
    }

    _cameraController?.dispose();
    _detectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // CAMERA
            Positioned.fill(
              child:
                  _cameraController != null &&
                      _initializeControllerFuture != null
                  ? FutureBuilder(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(
                            _cameraController!,
                          ).animate().fadeIn(duration: 600.ms);
                        }

                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),

            // GRADIENT OVERLAY
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.65),
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // HEADER
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Laporkan Kerusakan',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleFlash,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isFlashOn
                            ? AppColors.primaryColor
                            : Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFlashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),

            // TITLE
            Positioned(
                  top: 95,
                  left: 24,
                  right: 24,
                  child: Column(
                    children: [
                      Text(
                        'Deteksi Kerusakan Jalan',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Arahkan kamera ke bagian jalan yang rusak',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 150.ms, duration: 600.ms)
                .slideY(begin: -0.15, end: 0),

            // CAMERA FRAME
            Center(
                  child: Container(
                    width: 280,
                    height: 360,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(top: -2, left: -2, child: _corner()),
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Transform.rotate(
                            angle: math.pi / 2,
                            child: _corner(),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          left: -2,
                          child: Transform.rotate(
                            angle: -math.pi / 2,
                            child: _corner(),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Transform.rotate(
                            angle: math.pi,
                            child: _corner(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 700.ms)
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1, 1),
                ),

            // AI STATUS
            Positioned(
                  left: 24,
                  right: 24,
                  bottom: 130,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _modelLoaded
                              ? Icons.auto_awesome
                              : Icons.hourglass_top,
                          color: _modelLoaded
                              ? AppColors.primaryColor
                              : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _modelLoaded
                                ? 'AI YOLO11s siap mendeteksi kerusakan'
                                : 'Menyiapkan AI YOLO11s...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 450.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0),

            // BUTTON
            Positioned(
                  left: 24,
                  right: 24,
                  bottom: 30,
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _takePicture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Ambil Foto & Deteksi',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.25, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _corner() {
    return Container(
      width: 35,
      height: 35,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white, width: 4),
          left: BorderSide(color: Colors.white, width: 4),
        ),
      ),
    );
  }
}
