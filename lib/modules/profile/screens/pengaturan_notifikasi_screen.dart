import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

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

  // =========================================================
  // MASTER NOTIFIKASI
  // =========================================================

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

  // =========================================================
  // PILIH RADIUS
  // =========================================================

  void _showRadiusDialog() {
    final List<String> radius = ['1 km', '3 km', '5 km', '10 km'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Radius Peringatan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Pilih jarak peringatan kerusakan dari lokasi kamu',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                ...radius.map(
                  (item) => ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.near_me_outlined,
                        color: Color(0xFF1687C4),
                      ),
                    ),
                    title: Text(item),
                    trailing: radiusPeringatan == item
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF1687C4),
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

  // =========================================================
  // SUCCESS MESSAGE
  // =========================================================

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
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Notifikasi & Peringatan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ===================================================
          // NOTIFIKASI
          // ===================================================

          const Text(
            'Notifikasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

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
                  setState(() {
                    perkembanganLaporan = value;
                  });

                  box.write('notif_perkembangan', value);
                },
              ),

              _divider(),

              _buildSwitchMenu(
                icon: Icons.check_circle_outline,
                title: 'Laporan Berhasil Dikirim',
                subtitle: 'Konfirmasi setelah laporan berhasil dikirim',
                value: laporanDikirim,
                enabled: semuaNotifikasi,
                onChanged: (value) {
                  setState(() {
                    laporanDikirim = value;
                  });

                  box.write('notif_laporan_dikirim', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ===================================================
          // PERINGATAN KERUSAKAN
          // ===================================================
          const Text(
            'Peringatan Kerusakan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _buildContainer(
            children: [
              _buildSwitchMenu(
                icon: Icons.location_on_outlined,
                title: 'Kerusakan di Sekitar',
                subtitle: 'Peringatan kerusakan jalan di sekitar lokasi kamu',
                value: kerusakanSekitar,
                enabled: semuaNotifikasi,
                onChanged: (value) {
                  setState(() {
                    kerusakanSekitar = value;
                  });

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
                  setState(() {
                    kerusakanPrioritas = value;
                  });

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
          ),

          const SizedBox(height: 28),

          // ===================================================
          // PREFERENSI
          // ===================================================
          const Text(
            'Preferensi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _buildContainer(
            children: [
              _buildSwitchMenu(
                icon: Icons.volume_up_outlined,
                title: 'Suara Notifikasi',
                subtitle: 'Putar suara saat notifikasi diterima',
                value: suaraNotifikasi,
                enabled: semuaNotifikasi,
                onChanged: (value) {
                  setState(() {
                    suaraNotifikasi = value;
                  });

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
                  setState(() {
                    getaran = value;
                  });

                  box.write('notif_getaran', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =========================================================
  // CONTAINER
  // =========================================================

  Widget _buildContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  // =========================================================
  // SWITCH MENU
  // =========================================================

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
          color: enabled ? const Color(0xFFEAF2FF) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF1687C4) : Colors.grey,
          size: 22,
        ),
      ),

      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.black87 : Colors.grey,
        ),
      ),

      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: enabled ? Colors.grey : Colors.grey.shade400,
        ),
      ),

      trailing: Switch(
        value: value,
        activeThumbColor: const Color(0xFF1687C4),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  // =========================================================
  // NORMAL MENU
  // =========================================================

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
          color: enabled ? const Color(0xFFEAF2FF) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF1687C4) : Colors.grey,
          size: 22,
        ),
      ),

      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.black87 : Colors.grey,
        ),
      ),

      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: enabled ? Colors.grey : Colors.grey.shade400,
        ),
      ),

      trailing: Icon(
        Icons.chevron_right,
        color: enabled ? Colors.grey : Colors.grey.shade300,
      ),

      onTap: enabled ? onTap : null,
    );
  }

  // =========================================================
  // DIVIDER
  // =========================================================

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 72),
      child: Divider(height: 1, thickness: 0.6),
    );
  }
}
