import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:roadis/auth/controllers/auth_controller.dart';
import 'package:roadis/modules/notification/services/notification_polling_service.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final authC = Get.find<AuthController>();

  String _lokasi = 'Mencari lokasi...';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLokasi();
  }

  String get _sapaan {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi,';
    if (h < 15) return 'Selamat siang,';
    if (h < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  Future<void> _loadLokasi() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _lokasi = 'Mencari lokasi...';
      });
    }

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return _setLokasi('GPS tidak aktif');
      }

      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }

      if (izin == LocationPermission.denied ||
          izin == LocationPermission.deniedForever) {
        return _setLokasi('Izin lokasi ditolak');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint(
        'GPS: ${pos.latitude}, ${pos.longitude} (akurasi ${pos.accuracy} m)',
      );

      final nama = await _reverseGeocode(pos.latitude, pos.longitude);
      _setLokasi(nama ?? 'Lokasi tidak diketahui');
    } catch (e) {
      debugPrint('Gagal ambil lokasi: $e');
      _setLokasi('Gagal memuat lokasi');
    }
  }

  void _setLokasi(String text) {
    if (!mounted) return;
    setState(() {
      _lokasi = text;
      _loading = false;
    });
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat&lon=$lng&format=json&zoom=18&addressdetails=1&accept-language=id',
    );

    final res = await http
        .get(url, headers: {'User-Agent': 'Jalan-Rusak/1.0'})
        .timeout(const Duration(seconds: 8));

    debugPrint('Nominatim: ${res.body}');
    if (res.statusCode != 200) return null;

    final addr = (jsonDecode(res.body)['address'] ?? {}) as Map;

    String? pick(List<String> keys) {
      for (final key in keys) {
        final value = addr[key];
        if (value is String && value.isNotEmpty) return value;
      }
      return null;
    }

    final desa = pick(['village', 'suburb', 'town', 'municipality']);
    final kabupaten = pick(['county', 'city', 'state_district']);

    if (desa != null && kabupaten != null) return '$desa, $kabupaten';
    return desa ?? kabupaten;
  }

  BoxDecoration get _glass => BoxDecoration(
    color: Colors.white.withOpacity(0.16),
    border: Border.all(color: Colors.white.withOpacity(0.24)),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(),
            const SizedBox(width: 12),
            Expanded(child: _greeting()),
            _notificationButton(),
          ],
        ),
        const SizedBox(height: 16),
        _locationPill(),
      ],
    );
  }

  Widget _avatar() {
    return Obx(() {
      final nama = authC.user.value?.nama ?? 'Warga';
      final inisial = nama.trim().isEmpty ? 'W' : nama.trim()[0].toUpperCase();
      return Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Text(
          inisial,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryColor,
          ),
        ),
      );
    });
  }

  Widget _greeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _sapaan,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 2),
        Obx(() {
          final nama = authC.user.value?.nama ?? 'Warga';
          return Text(
            nama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          );
        }),
      ],
    );
  }

  Widget _locationPill() {
    return GestureDetector(
      onTap: _loading ? null : _loadLokasi,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: _glass.copyWith(borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading)
              const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: Colors.white,
                ),
              )
            else
              const Icon(
                Icons.location_on_rounded,
                size: 15,
                color: Colors.white,
              ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _lokasi,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            if (!_loading) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.refresh_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _notificationButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Get.toNamed(AppRoutes.notifikasi),
        child: Container(
          width: 46,
          height: 46,
          decoration: _glass.copyWith(shape: BoxShape.circle),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 23,
                color: Colors.white,
              ),
              Obx(() {
                if (NotificationPollingService.instance.unreadCount.value <= 0) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  right: 12,
                  top: 11,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.redColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
