import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:roadis/auth/services/session_storage.dart';
import 'package:roadis/core/api_config.dart';
import 'package:roadis/core/detection/models/detection_result.dart';
import 'package:roadis/core/detection/services/detection_service.dart';
import 'package:roadis/core/detection/services/groq_service.dart';
import 'package:roadis/core/laporan/models/wilayah_model.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';

import './report_form_screen.dart';

class ReportCameraScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ReportCameraScreen({super.key, this.onBack});

  @override
  State<ReportCameraScreen> createState() => _ReportCameraScreenState();
}

class _ReportCameraScreenState extends State<ReportCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isInitializingCamera = false;

  final DetectionService _detectionService = DetectionService();

  /// 'yolo' (lokal) atau 'groq' (cloud)
  String _selectedEngine = 'yolo';

  bool _isProcessing = false;
  String _processingLabel = '';
  bool _modelLoaded = false;
  bool _isFlashOn = false;
  bool _isLoadingWilayah = false;

  List<WilayahModel> _wilayahList = [];

  bool get _cameraReady =>
      _cameraController != null && _cameraController!.value.isInitialized;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _loadModel();
    _loadWilayah();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _cameraController = null;
      controller.dispose();
      if (mounted) setState(() => _isFlashOn = false);
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      controller.setFlashMode(FlashMode.off).catchError((_) {});
    }
    controller?.dispose();
    _detectionService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_isInitializingCamera) return;
    _isInitializingCamera = true;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('Kamera tidak ditemukan.');

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      try {
        await controller.setExposureOffset(0.5);
      } catch (e) {
        debugPrint('Exposure tidak didukung: $e');
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isFlashOn = false;
      });
    } catch (e) {
      _showSnack(
        'Kamera tidak bisa dibuka',
        e.toString().replaceFirst('Exception: ', ''),
        ContentType.failure,
      );
    } finally {
      _isInitializingCamera = false;
    }
  }

  Future<void> _loadModel() async {
    try {
      await _detectionService.loadModel();
      if (mounted) setState(() => _modelLoaded = true);
    } catch (e) {
      debugPrint('Gagal load model: $e');
      _showSnack(
        'Model lokal gagal dimuat',
        'Deteksi YOLO tidak tersedia. Coba mode Groq AI.',
        ContentType.failure,
      );
    }
  }

  Future<void> _loadWilayah() async {
    if (_isLoadingWilayah) return;
    _isLoadingWilayah = true;

    try {
      final token = SessionStorage.getToken();

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/warga/wilayah'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil wilayah (${response.statusCode})');
      }

      final data = jsonDecode(response.body)['data'];
      if (data is! List) {
        throw Exception('Format data wilayah tidak valid.');
      }

      final wilayah = data
          .whereType<Map<String, dynamic>>()
          .map((json) {
            final idValue = json['id'] ?? json['ID'];
            final namaValue = json['nama'] ?? json['Nama'] ?? json['name'];

            return WilayahModel(
              id: idValue is num
                  ? idValue.toInt()
                  : int.tryParse(idValue?.toString() ?? '') ?? 0,
              nama: namaValue?.toString() ?? '',
            );
          })
          .where((w) => w.id != 0 && w.nama.isNotEmpty)
          .toList();

      if (mounted) setState(() => _wilayahList = wilayah);
    } catch (e) {
      debugPrint('Gagal mengambil wilayah: $e');
    } finally {
      _isLoadingWilayah = false;
    }
  }

  void _showSnack(String title, String message, ContentType type) {
    if (!mounted) return;
    showAwesomeSnackbar(title: title, message: message, contentType: type);
  }

  void _setProcessing(String label) {
    if (mounted) setState(() => _processingLabel = label);
  }

  Future<void> _turnOffFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      await controller.setFlashMode(FlashMode.off);
    } catch (e) {
      debugPrint('Gagal matikan flash: $e');
    }

    if (mounted) setState(() => _isFlashOn = false);
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      if (mounted) setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('Flash tidak tersedia: $e');
      _showSnack(
        'Flash',
        'Flash tidak tersedia di kamera ini.',
        ContentType.failure,
      );
    }
  }

  Future<Position> _getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('GPS belum aktif. Aktifkan GPS lalu coba lagi.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi dibutuhkan untuk mengirim laporan.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
    } on TimeoutException {
      throw Exception(
        'Titik GPS belum didapat. Coba lagi di tempat yang lebih terbuka.',
      );
    }
  }

  /// Menjalankan deteksi sesuai mesin yang dipilih.
  /// Mengembalikan hasil terbaik dan gambar yang ditampilkan di form
  /// (gambar beranotasi untuk YOLO, gambar asli untuk Groq).
  Future<(DetectionResult?, XFile)> _detect(
    Uint8List bytes,
    XFile original,
  ) async {
    if (_selectedEngine == 'groq') {
      try {
        return (await GroqService.detectRoadDamage(bytes), original);
      } catch (e) {
        debugPrint('Groq detection error: $e');
        if (!_modelLoaded) rethrow;
        _showSnack(
          'Groq tidak bisa dipakai',
          'Deteksi dialihkan ke model lokal.',
          ContentType.help,
        );
      }
    }

    if (!_modelLoaded) return (null, original);

    final detections = await _detectionService.detect(bytes);
    if (detections.isEmpty) return (null, original);

    final annotated = _detectionService.drawDetections(bytes, detections);
    final path = '${original.path}_det.jpg';
    await File(path).writeAsBytes(annotated);

    return (detections.first, XFile(path));
  }

  Future<void> _takePicture() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (_isProcessing) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _processingLabel = 'Mengambil foto...';
    });

    try {
      final wilayahFuture = _wilayahList.isEmpty ? _loadWilayah() : null;

      final image = await controller.takePicture();
      await _turnOffFlash();

      _setProcessing('Mencari titik GPS...');
      final position = await _getLocation();

      _setProcessing(
        _selectedEngine == 'groq'
            ? 'Menganalisis dengan Groq AI...'
            : 'Menganalisis dengan YOLO...',
      );
      final bytes = await image.readAsBytes();
      final (detection, displayImage) = await _detect(bytes, image);

      await wilayahFuture;
      if (!mounted) return;

      await Get.to(
        () => ReportFormScreen(
          image: displayImage,
          rawImage: image,
          position: position,
          detection: detection,
          wilayahList: _wilayahList,
          isUsingGroq: _selectedEngine == 'groq',
        ),
      );
    } catch (e) {
      _showSnack(
        'Foto belum bisa diproses',
        e.toString().replaceFirst('Exception: ', ''),
        ContentType.failure,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildPreview() {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Preview kamera berorientasi landscape, jadi lebar & tinggi ditukar.
    final size = controller.value.previewSize!;

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryColor
              : Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }

  Widget _buildHeader(double topInset) {
    return Positioned(
      top: topInset + 12,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Row(
            children: [
              _roundButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    Get.back();
                  }
                },
              ),
              Expanded(
                child: Text(
                  'Foto kerusakan jalan',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _roundButton(
                icon: _isFlashOn
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                onTap: _toggleFlash,
                active: _isFlashOn,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Arahkan kamera ke bagian jalan yang rusak',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFrame(EdgeInsets inset) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            40,
            inset.top + 110,
            40,
            inset.bottom + 230,
          ),
          child: Center(
            child: AspectRatio(
              aspectRatio: 0.85,
              child: CustomPaint(
                painter: _FramePainter(
                  _isProcessing ? AppColors.primaryColor : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _engineButton({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final selected = _selectedEngine == id;

    return GestureDetector(
      onTap: () {
        if (_isProcessing) return;
        setState(() => _selectedEngine = id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _engineButton(
            id: 'yolo',
            label: 'YOLO11s Lokal',
            icon: Icons.memory_rounded,
          ),
          const SizedBox(width: 4),
          _engineButton(
            id: 'groq',
            label: 'Groq Cloud',
            icon: Icons.cloud_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLine() {
    final isGroq = _selectedEngine == 'groq';
    final ready = isGroq || _modelLoaded;

    final text = isGroq
        ? 'Groq Vision siap, butuh koneksi internet'
        : (_modelLoaded
              ? 'Model lokal siap, bisa dipakai tanpa internet'
              : 'Memuat model lokal...');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ready ? const Color(0xFF4ADE80) : AppColors.orangeColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildShutter() {
    final enabled = _cameraReady && !_isProcessing;

    return GestureDetector(
      onTap: enabled ? _takePicture : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: 78,
          height: 78,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel(double bottomInset) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEngineSelector(),
            const SizedBox(height: 12),
            _buildStatusLine(),
            const SizedBox(height: 20),
            _buildShutter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.55),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _processingLabel,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).padding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildPreview(),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xB3000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xD9000000),
                    ],
                    stops: [0, 0.25, 0.55, 1],
                  ),
                ),
              ),
            ),
            _buildFrame(inset),
            _buildHeader(inset.top),
            _buildBottomPanel(inset.bottom),
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }
}

/// Bingkai bidik dengan sudut membulat.
class _FramePainter extends CustomPainter {
  final Color color;

  const _FramePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const len = 38.0;
    const r = 18.0;
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      // kiri atas
      ..moveTo(0, len)
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..lineTo(len, 0)
      // kanan atas
      ..moveTo(w - len, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
      ..lineTo(w, len)
      // kanan bawah
      ..moveTo(w, h - len)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: const Radius.circular(r))
      ..lineTo(w - len, h)
      // kiri bawah
      ..moveTo(len, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
      ..lineTo(0, h - len);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.color != color;
}
