import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadis/core/laporan/models/laporan_model.dart';
import 'package:roadis/modules/history/screens/detail_laporan_screen.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/location_service.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/maps_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final _c = Get.put(MapsController());
  late final TextEditingController _searchC;
  Worker? _searchWorker;

  final LatLng _indramayuCenter = const LatLng(-6.4731, 108.3039);
  LatLng? _currentLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController(text: _c.searchQuery.value);
    _searchWorker = ever(_c.searchQuery, (_) => _moveToFirstResult());
    _initUserLocation();
  }

  @override
  void dispose() {
    _searchWorker?.dispose();
    _searchC.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _move(LatLng point, double zoom) {
    try {
      _mapController.move(point, zoom);
    } catch (_) {}
  }

  Future<void> _initUserLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null && mounted) {
        final userPoint = LatLng(pos.latitude, pos.longitude);
        setState(() => _currentLocation = userPoint);
        _move(userPoint, 16.0);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _moveToUserLocation() async {
    HapticFeedback.lightImpact();
    if (_currentLocation != null) {
      _move(_currentLocation!, 16.0);
      return;
    }

    setState(() => _isLocating = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null && mounted) {
        final userPoint = LatLng(pos.latitude, pos.longitude);
        setState(() => _currentLocation = userPoint);
        _move(userPoint, 16.0);
      } else {
        _move(_indramayuCenter, 15.0);
      }
    } catch (_) {
      _move(_indramayuCenter, 15.0);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _moveToFirstResult() {
    if (_c.searchQuery.value.trim().isEmpty) return;
    if (_c.filteredLaporan.isEmpty) return;

    final first = _c.filteredLaporan.first;
    _move(LatLng(first.latitude, first.longitude), 16.0);
  }

  void _selectMarker(LaporanModel lap) {
    HapticFeedback.selectionClick();
    _c.selectLaporan(lap);
    _move(LatLng(lap.latitude, lap.longitude), _mapController.camera.zoom);
  }

  void _showFilterBottomSheet() {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Sebaran Peta',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkTextColor,
                            ),
                          ),
                          Text(
                            'Saring titik kerusakan di Indramayu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _c.resetFilters();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _sheetLabel(Icons.flag_rounded, 'Status Perbaikan'),
                const SizedBox(height: 10),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final filter in MapsController.filterOptions)
                        _SheetChip(
                          label: filter,
                          selected: _c.selectedFilter.value == filter,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _c.selectFilter(filter);
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sheetLabel(
                  Icons.account_balance_rounded,
                  'Kewenangan Jalan',
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final kw in MapsController.kewenanganOptions)
                        _SheetChip(
                          label: kw == 'Semua'
                              ? 'Semua Kewenangan'
                              : 'Jalan $kw',
                          selected: _c.selectedKewenangan.value == kw,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _c.selectKewenangan(kw);
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Obx(
                      () => Text(
                        'Tampilkan ${_c.filteredLaporan.length} Titik Laporan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _sheetLabel(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 15, color: AppColors.primaryColor),
      const SizedBox(width: 6),
      Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextColor,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Fullscreen Map Canvas
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _indramayuCenter,
              initialZoom: 15.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: (_, __) => _c.closeDetailCard(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jalanku.indramayu',
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 56,
                      height: 56,
                      child: const _UserDot(),
                    ),
                  ],
                ),
              Obx(() {
                final selectedId = _c.selectedLaporan.value?.id;
                return MarkerLayer(
                  markers: [
                    for (final lap in _c.filteredLaporan)
                      Marker(
                        point: LatLng(lap.latitude, lap.longitude),
                        width: 54,
                        height: 54,
                        child: GestureDetector(
                          onTap: () => _selectMarker(lap),
                          child: _ReportMarker(
                            color: lap.status.statusColor,
                            selected: lap.id == selectedId,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),

          // Floating Top Controls (Search Bar & Filter Chips)
          Positioned(
            top: topInset + 10,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSearchBar()),
                    const SizedBox(width: 10),
                    _buildFilterButton(),
                  ],
                ),
                const SizedBox(height: 10),
                _buildStatusChips(),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.1, curve: Curves.easeOutCubic),
          ),

          // Floating Right Controls (My Location & Zoom In/Out)
          Positioned(
            right: 16,
            top: topInset + 120,
            child: Column(
              children: [
                _MapIconButton(
                  onTap: _moveToUserLocation,
                  child: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          size: 21,
                          color: AppColors.primaryColor,
                        ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _floatingShadow,
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.add_rounded,
                            size: 22,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      InkWell(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.remove_rounded,
                            size: 22,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 450.ms, delay: 150.ms)
                .slideX(begin: 0.15, curve: Curves.easeOutCubic),
          ),

          // Loading & Error Badges
          Obx(() {
            if (_c.isLoading.value) {
              return Positioned(
                top: topInset + 120,
                left: 0,
                right: 0,
                child: const Center(child: _StatusPill(loading: true)),
              );
            }

            if (_c.errorMessage.value != null) {
              return Positioned(
                top: topInset + 120,
                left: 16,
                right: 76,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _floatingShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _c.errorMessage.value!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _c.fetchLaporan,
                        child: Text(
                          'Coba lagi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_c.selectedLaporan.value != null || isKeyboardOpen) {
              return const SizedBox.shrink();
            }

            final total = _c.filteredLaporan.length;

            return Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: _StatusPill(
                  icon: total == 0
                      ? Icons.search_off_rounded
                      : Icons.location_on_rounded,
                  label: total == 0
                      ? 'Tidak ada laporan yang cocok'
                      : '$total titik kerusakan jalan',
                ),
              ).animate().fadeIn(duration: 300.ms),
            );
          }),

          // Bottom Detail Preview Card (Hidden when keyboard is active)
          Obx(() {
            final lap = _c.selectedLaporan.value;
            if (lap == null || isKeyboardOpen) return const SizedBox.shrink();

            return Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: _DetailCard(
                key: ValueKey(lap.id),
                laporan: lap,
                onClose: _c.closeDetailCard,
              )
                  .animate()
                  .fadeIn(duration: 250.ms)
                  .slideY(begin: 0.12, curve: Curves.easeOutCubic),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 10, right: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _floatingShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchC,
              onChanged: _c.updateSearch,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primaryColor,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Cari desa, kecamatan, atau jalan...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.lightGreyColor,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchC,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () {
                  _searchC.clear();
                  _c.updateSearch('');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Obx(() {
      final active =
          _c.selectedFilter.value != 'Semua' ||
          _c.selectedKewenangan.value != 'Semua';

      return GestureDetector(
        onTap: _showFilterBottomSheet,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryColor : Colors.white,
            shape: BoxShape.circle,
            boxShadow: _floatingShadow,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                color: active ? Colors.white : AppColors.primaryColor,
                size: 21,
              ),
              if (active)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.skyBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusChips() {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (final filter in MapsController.filterOptions)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TopChip(
                  label: filter == 'Semua'
                      ? 'Semua (${_c.semuaLaporan.length})'
                      : filter,
                  selected: _c.selectedFilter.value == filter,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _c.selectFilter(filter);
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}

final List<BoxShadow> _floatingShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 16,
    offset: const Offset(0, 4),
  ),
];

class _TopChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primaryColor
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primaryColor.withOpacity(0.28)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? Colors.white : AppColors.darkTextColor,
          ),
        ),
      ),
    );
  }
}

class _SheetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SheetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor
              : AppColors.primaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primaryColor
                : AppColors.primaryColor.withOpacity(0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _MapIconButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _floatingShadow,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool loading;
  final String? label;
  final IconData? icon;

  const _StatusPill({this.loading = false, this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _floatingShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
          ] else if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.primaryColor),
            const SizedBox(width: 6),
          ],
          Text(
            label ?? 'Memuat sebaran laporan...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMarker extends StatelessWidget {
  final Color color;
  final bool selected;

  const _ReportMarker({required this.color, required this.selected});

  @override
  Widget build(BuildContext context) {
    final size = selected ? 42.0 : 34.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (selected)
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.28),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.15, 1.15),
                duration: 1200.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(duration: 1200.ms),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: selected ? 3.0 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: selected ? 14 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: selected ? 20 : 16,
          ),
        ),
      ],
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback onClose;

  const _DetailCard({super.key, required this.laporan, required this.onClose});

  Future<void> _openNavigation() async {
    final lat = laporan.latitude;
    final lng = laporan.longitude;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) _showFail();
    } catch (_) {
      _showFail();
    }
  }

  void _showFail() {
    showAwesomeSnackbar(
      title: 'Terjadi Kesalahan',
      message: 'Gagal membuka rute Google Maps.',
      contentType: ContentType.failure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = laporan.status.statusColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumb(url: laporan.image, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  laporan.status.statusLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onClose,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        laporan.tipeKerusakan.isNotEmpty
                            ? laporan.tipeKerusakan
                            : laporan.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              laporan.wilayahNama ?? laporan.judul,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greyColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.lightGreyColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              laporan.waktuLaporan,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.greyColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => DetailLaporanScreen(laporan: laporan),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lihat Rincian',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _openNavigation,
                      icon: const Icon(
                        Icons.navigation_rounded,
                        size: 15,
                        color: AppColors.primaryColor,
                      ),
                      label: Text(
                        'Navigasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.35),
                        ),
                        backgroundColor: AppColors.primaryColor.withOpacity(0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  final Color color;

  const _Thumb({required this.url, required this.color});

  Widget _placeholder() => Container(
    color: color.withOpacity(0.1),
    alignment: Alignment.center,
    child: Icon(Icons.add_road_rounded, size: 28, color: color),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 80,
        height: 80,
        child: url.isEmpty
            ? _placeholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _placeholder(),
              ),
      ),
    );
  }
}
