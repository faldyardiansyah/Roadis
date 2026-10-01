import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:roadis/auth/controllers/auth_controller.dart';
import 'package:roadis/modules/profile/screens/keamanan_akun_screen.dart';

class PengaturanAkunScreen extends StatefulWidget {
  const PengaturanAkunScreen({super.key});

  @override
  State<PengaturanAkunScreen> createState() => _PengaturanAkunScreenState();
}

class _PengaturanAkunScreenState extends State<PengaturanAkunScreen> {
  final GetStorage box = GetStorage();

  late String nama;
  late String email;
  late String wilayah;

  @override
  void initState() {
    super.initState();

    // Ambil data yang sebelumnya sudah disimpan
    final authController = Get.find<AuthController>();
    final currentUser = authController.user.value;

    nama = currentUser?.nama ?? '';
    email = currentUser?.email ?? '';
    wilayah = box.read('profile_wilayah') ?? 'Indramayu';

    _loadWilayah();
  }

  Future<void> _loadWilayah() async {
    final authController = Get.find<AuthController>();
    final namaWilayah = await authController.getProfileWilayah();

    if (!mounted) return;

    if (namaWilayah != null && namaWilayah.isNotEmpty) {
      setState(() {
        wilayah = namaWilayah;
      });
    }
  }
  // =========================================================
  // PESAN BERHASIL
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
  // PESAN ERROR
  // =========================================================

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
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
  // EDIT NAMA / EMAIL
  // =========================================================

  void _showEditDialog({
    required String title,
    required String value,
    required Future<void> Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Ubah $title',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            autofocus: true,
            decoration: InputDecoration(
              labelText: title,
              hintText: 'Masukkan $title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final newValue = controller.text.trim();

                if (newValue.isEmpty) {
                  _showErrorMessage('$title tidak boleh kosong');
                  return;
                }

                // Validasi sederhana email
                if (title == 'Email' &&
                    (!newValue.contains('@') || !newValue.contains('.'))) {
                  _showErrorMessage('Format email tidak valid');
                  return;
                }

                await onSave(newValue);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // PILIH WILAYAH
  // =========================================================

  void _showWilayahDialog() {
    final List<String> daftarWilayah = [
      'Indramayu',
      'Jatibarang',
      'Karangampel',
      'Haurgeulis',
      'Losarang',
      'Kandanghaur',
      'Sindang',
      'Sliyeg',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
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
                  'Pilih Wilayah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Pilih wilayah tempat tinggal kamu',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: daftarWilayah.length,
                    itemBuilder: (context, index) {
                      final item = daftarWilayah[index];

                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF2563EB),
                            size: 21,
                          ),
                        ),
                        title: Text(
                          item,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: wilayah == item
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF2563EB),
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            wilayah = item;
                          });

                          // SIMPAN PERMANEN LOKAL
                          box.write('profile_wilayah', item);

                          Navigator.pop(sheetContext);

                          _showSuccessMessage('Wilayah berhasil diperbarui');
                        },
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
  // UBAH KATA SANDI
  // =========================================================

  void _showPasswordDialog() {
    final passwordLamaController = TextEditingController();
    final passwordBaruController = TextEditingController();
    final konfirmasiController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Ubah Kata Sandi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordLamaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi Lama',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: passwordBaruController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi Baru',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: konfirmasiController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi',
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final passwordLama = passwordLamaController.text.trim();
                final passwordBaru = passwordBaruController.text.trim();
                final konfirmasi = konfirmasiController.text.trim();

                if (passwordLama.isEmpty ||
                    passwordBaru.isEmpty ||
                    konfirmasi.isEmpty) {
                  _showErrorMessage('Semua kolom kata sandi harus diisi');
                  return;
                }

                if (passwordBaru.length < 6) {
                  _showErrorMessage('Kata sandi baru minimal 6 karakter');
                  return;
                }

                if (passwordBaru != konfirmasi) {
                  _showErrorMessage('Konfirmasi kata sandi tidak sama');
                  return;
                }

                final authController = Get.find<AuthController>();

                final error = await authController.changePassword(
                  currentPassword: passwordLama,
                  newPassword: passwordBaru,
                );

                if (error != null) {
                  _showErrorMessage(error);
                  return;
                }

                if (!mounted) return;

                Navigator.pop(dialogContext);

                _showSuccessMessage('Kata sandi berhasil diperbarui');
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // HAPUS AKUN
  // =========================================================

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEEEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 28,
            ),
          ),
          title: const Text(
            'Hapus Akun?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            'Akun dan data yang terkait dengan akun kamu akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                // Belum benar-benar menghapus akun
                // karena membutuhkan backend.
                Navigator.pop(dialogContext);
              },
              child: const Text('Hapus Akun'),
            ),
          ],
        );
      },
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
          'Pengaturan Akun',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ================= INFORMASI AKUN =================

          const Text(
            'Informasi Akun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                // NAMA
                _buildMenu(
                  icon: Icons.person_outline,
                  title: 'Nama Lengkap',
                  subtitle: nama,
                  onTap: () {
                    _showEditDialog(
                      title: 'Nama Lengkap',
                      value: nama,
                      onSave: (value) async {
                        final authController = Get.find<AuthController>();

                        final error = await authController.updateName(value);

                        if (error != null) {
                          _showErrorMessage(error);
                          return;
                        }

                        if (!mounted) return;

                        setState(() {
                          nama = value;
                        });

                        // Tetap simpan lokal seperti sebelumnya
                        box.write('profile_nama', value);

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        _showSuccessMessage('Nama Lengkap berhasil diperbarui');
                      },
                    );
                  },
                ),

                _divider(),

                // EMAIL
                _buildMenu(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: email,
                  onTap: () {},
                  showArrow: false,
                ),

                // WILAYAH
                _buildMenu(
                  icon: Icons.location_on_outlined,
                  title: 'Wilayah',
                  subtitle: wilayah,
                  onTap: () {},
                  showArrow: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ================= KEAMANAN =================
          const Text(
            'Keamanan Akun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildMenu(
                  icon: Icons.lock_outline,
                  title: 'Ubah Kata Sandi',
                  subtitle: 'Perbarui kata sandi akun',
                  onTap: _showPasswordDialog,
                ),

                _divider(),

                _buildMenu(
                  icon: Icons.security_outlined,
                  title: 'Keamanan Akun',
                  subtitle: 'Kelola keamanan akun ROADIS',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KeamananAkunScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ================= AKUN =================
          const Text(
            'Akun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: _buildMenu(
              icon: Icons.delete_outline,
              title: 'Hapus Akun',
              subtitle: 'Hapus akun ROADIS secara permanen',
              isDanger: true,
              onTap: _showDeleteAccountDialog,
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =========================================================
  // MENU
  // =========================================================

  Widget _buildMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFFEEEE) : const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          color: isDanger ? Colors.red : const Color(0xFF2563EB),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDanger ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: showArrow
          ? Icon(
              Icons.chevron_right,
              color: isDanger ? Colors.red : Colors.grey,
            )
          : null,
      onTap: onTap,
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
