import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';

class PengaturanNotifikasiScreen extends StatefulWidget {
  const PengaturanNotifikasiScreen({super.key});

  @override
  State<PengaturanNotifikasiScreen> createState() =>
      _PengaturanNotifikasiScreenState();
}

class _PengaturanNotifikasiScreenState
    extends State<PengaturanNotifikasiScreen> {
  final GetStorage box = GetStorage();

  late bool semuaNotifikasi;
  late bool perkembanganLaporan;
  late bool laporanDikirim;
  late bool kerusakanSekitar;
  late bool kerusakanPrioritas;
  late bool suaraNotifikasi;
  late bool getaran;

  late String radiusPeringatan;

  @override
  void initState() {
    super.initState();

    semuaNotifikasi = box.read('notif_semua') ?? true;
    perkembanganLaporan = box.read('notif_perkembangan') ?? true;
    laporanDikirim = box.read('notif_laporan_dikirim') ?? true;
    kerusakanSekitar = box.read('notif_kerusakan_sekitar') ?? true;
    kerusakanPrioritas = box.read('notif_kerusakan_prioritas') ?? true;
    suaraNotifikasi = box.read('notif_suara') ?? true;
    getaran = box.read('notif_getaran') ?? true;
    radiusPeringatan = box.read('notif_radius') ?? '3 km';
  }

  void _ubahSemuaNotifikasi(bool value) {
    setState(() {
      semuaNotifikasi = value;
      perkembanganLaporan = value;
      laporanDikirim = value;
      kerusakanSekitar = value;
      kerusakanPrioritas = value;
    });

    box.write('notif_semua', value);
    box.write('notif_perkembangan', value);
    box.write('notif_laporan_dikirim', value);
    box.write('notif_kerusakan_sekitar', value);
    box.write('notif_kerusakan_prioritas', value);
  }

  void _showRadiusDialog() {
    final List<String> radius = ['1 km', '3 km', '5 km', '10 km'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Radius Peringatan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih jarak peringatan kerusakan dari lokasi kamu',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ...radius.map(
                  (item) => ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.lightIceBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.near_me_rounded,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    trailing: radiusPeringatan == item
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryColor,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        radiusPeringatan = item;
                      });
                      box.write('notif_radius', item);
                      Navigator.pop(sheetContext);
                      _showSuccessMessage(
                        'Radius peringatan diubah menjadi $item',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0E9F6E),
        elevation: 0,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Column(
          children: [
            _buildHeader(topInset),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _sectionLabel('Notifikasi'),
                  const SizedBox(height: 10),
                  _buildContainer(
                    children: [
                      _buildSwitchMenu(
                        icon: Icons.notifications_outlined,
                        title: 'Semua Notifikasi',
                        subtitle: 'Aktifkan atau nonaktifkan seluruh notifikasi',
                        value: semuaNotifikasi,
                        onChanged: _ubahSemuaNotifikasi,
                      ),
                      _divider(),
                      _buildSwitchMenu(
                        icon: Icons.autorenew_rounded,
                        title: 'Perkembangan Laporan',
                        subtitle: 'Notifikasi saat status laporan berubah',
                        value: perkembanganLaporan,
                        enabled: semuaNotifikasi,
                        onChanged: (value) {
                          setState(() => perkembanganLaporan = value);
                          box.write('notif_perkembangan', value);
                        },
                      ),
                      _divider(),
                      _buildSwitchMenu(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Laporan Berhasil Dikirim',
                        subtitle: 'Konfirmasi setelah laporan berhasil dikirim',
                        value: laporanDikirim,
                        enabled: semuaNotifikasi,
                        onChanged: (value) {
                          setState(() => laporanDikirim = value);
                          box.write('notif_laporan_dikirim', value);
                        },
                      ),
                    ],
                  ).animate().fadeIn(duration: 360.ms),
                  const SizedBox(height: 22),
                  _sectionLabel('Peringatan Kerusakan'),
                  const SizedBox(height: 10),
                  _buildContainer(
                    children: [
                      _buildSwitchMenu(
                        icon: Icons.location_on_outlined,
                        title: 'Kerusakan di Sekitar',
                        subtitle:
                            'Peringatan kerusakan jalan di sekitar lokasi kamu',
                        value: kerusakanSekitar,
                        enabled: semuaNotifikasi,
                        onChanged: (value) {
                          setState(() => kerusakanSekitar = value);
                          box.write('notif_kerusakan_sekitar', value);
                        },
                      ),
                      _divider(),
                      _buildSwitchMenu(
                        icon: Icons.warning_amber_rounded,
                        title: 'Kerusakan Prioritas',
                        subtitle:
                            'Peringatan untuk kerusakan jalan yang perlu perhatian',
                        value: kerusakanPrioritas,
                        enabled: semuaNotifikasi,
                        onChanged: (value) {
                          setState(() => kerusakanPrioritas = value);
                          box.write('notif_kerusakan_prioritas', value);
                        },
                      ),
                      _divider(),
                      _buildMenu(
                        icon: Icons.radar_rounded,
                        title: 'Radius Peringatan',
                        subtitle: radiusPeringatan,
                        enabled: semuaNotifikasi && kerusakanSekitar,
                        onTap: _showRadiusDialog,
                      ),
                    ],
                  ).animate().fadeIn(delay: 80.ms, duration: 360.ms),
                  const SizedBox(height: 22),
                  _sectionLabel('Preferensi'),
                  const SizedBox(height: 10),
                  _buildContainer(
                    children: [
                      _buildSwitchMenu(
                        icon: Icons.volume_up_outlined,
                        title: 'Suara Notifikasi',
                        subtitle: 'Putar suara saat notifikasi diterima',
                        value: suaraNotifikasi,
                        enabled: semuaNotifikasi,
                        onChanged: (value) {
                          setState(() => suaraNotifikasi = value);
                          box.write('notif_suara', value);
                        },
                      ),
                      _divider(),
                      _buildSwitchMenu(
                        icon: Icons.vibration_rounded,
                        title: 'Getaran',
                        subtitle: 'Aktifkan getaran saat notifikasi diterima',
                        value: getaran,
                        enabled: semuaNotifikasi,
                        onChanged: (value) {
                          setState(() => getaran = value);
                          box.write('notif_getaran', value);
                        },
                      ),
                    ],
                  ).animate().fadeIn(delay: 140.ms, duration: 360.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double topInset) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.midnightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Stack(
          children: [
            Positioned.fill(
              child: BatikPattern(
                color: Colors.white,
                opacity: 0.12,
                scale: 2.4,
                fadeOut: true,
              ),
            ),
            Positioned(
              top: -8,
              right: -15,
              width: 250,
              height: 230,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.28,
                  child: Image.asset(
                    'assets/images/burung_batik.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.30),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifikasi & Peringatan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Atur preferensi notifikasi & radius peringatan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.86),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: enabled ? AppColors.lightIceBlue : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primaryColor : const Color(0xFF94A3B8),
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: enabled ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          color: enabled ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppColors.primaryColor,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget _buildMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: enabled ? AppColors.lightIceBlue : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primaryColor : const Color(0xFF94A3B8),
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: enabled ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: enabled ? AppColors.primaryColor : const Color(0xFFCBD5E1),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: enabled ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
      ),
      onTap: enabled ? onTap : null,
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 72, right: 16),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
    );
  }
}
