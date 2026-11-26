import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/auth/controllers/auth_controller.dart';
import 'package:roadis/modules/profile/screens/keamanan_akun_screen.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';

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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFDC2626),
        elevation: 0,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Ubah $title',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            autofocus: true,
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
            decoration: InputDecoration(
              labelText: title,
              hintText: 'Masukkan $title',
              labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
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

                if (title == 'Email' &&
                    (!newValue.contains('@') || !newValue.contains('.'))) {
                  _showErrorMessage('Format email tidak valid');
                  return;
                }

                await onSave(newValue);
              },
              child: Text(
                'Simpan',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordDialog() {
    final passwordLamaController = TextEditingController();
    final passwordBaruController = TextEditingController();
    final konfirmasiController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Ubah Kata Sandi',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordLamaController,
                  obscureText: true,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi Lama',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordBaruController,
                  obscureText: true,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi Baru',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: konfirmasiController,
                  obscureText: true,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi',
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
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
              child: Text(
                'Simpan',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hapus Akun?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Akun dan data yang terkait dengan akun kamu akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Hapus Akun',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                  _sectionLabel('Informasi Akun'),
                  const SizedBox(height: 10),
                  _buildCard(
                    children: [
                      _buildMenu(
                        icon: Icons.person_outline_rounded,
                        title: 'Nama Lengkap',
                        subtitle: nama,
                        onTap: () {
                          _showEditDialog(
                            title: 'Nama Lengkap',
                            value: nama,
                            onSave: (value) async {
                              final authController = Get.find<AuthController>();
                              final error = await authController.updateName(
                                value,
                              );

                              if (error != null) {
                                _showErrorMessage(error);
                                return;
                              }

                              if (!mounted) return;

                              setState(() {
                                nama = value;
                              });

                              box.write('profile_nama', value);

                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }

                              _showSuccessMessage(
                                'Nama Lengkap berhasil diperbarui',
                              );
                            },
                          );
                        },
                      ),
                      _divider(),
                      _buildMenu(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: email,
                        onTap: () {},
                        showArrow: false,
                      ),
                      _divider(),
                      _buildMenu(
                        icon: Icons.location_on_outlined,
                        title: 'Wilayah',
                        subtitle: wilayah,
                        onTap: () {},
                        showArrow: false,
                      ),
                    ],
                  ).animate().fadeIn(duration: 360.ms),
                  const SizedBox(height: 22),
                  _sectionLabel('Keamanan Akun'),
                  const SizedBox(height: 10),
                  _buildCard(
                    children: [
                      _buildMenu(
                        icon: Icons.lock_outline_rounded,
                        title: 'Ubah Kata Sandi',
                        subtitle: 'Perbarui kata sandi akun secara berkala',
                        onTap: _showPasswordDialog,
                      ),
                      _divider(),
                      _buildMenu(
                        icon: Icons.security_rounded,
                        title: 'Keamanan Akun',
                        subtitle: 'Kelola keamanan dan riwayat akses akun',
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
                  ).animate().fadeIn(delay: 80.ms, duration: 360.ms),
                  const SizedBox(height: 22),
                  _sectionLabel('Zona Berbahaya'),
                  const SizedBox(height: 10),
                  _buildCard(
                    children: [
                      _buildMenu(
                        icon: Icons.delete_outline_rounded,
                        title: 'Hapus Akun',
                        subtitle: 'Hapus akun ROADIS secara permanen',
                        isDanger: true,
                        onTap: _showDeleteAccountDialog,
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
                          'Pengaturan Akun',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Kelola profil, kata sandi & keamanan',
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

  Widget _buildCard({required List<Widget> children}) {
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

  Widget _buildMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDanger
              ? const Color(0xFFFEE2E2)
              : AppColors.lightIceBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDanger ? const Color(0xFFDC2626) : AppColors.primaryColor,
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: isDanger ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: showArrow
          ? Icon(
              Icons.chevron_right_rounded,
              color: isDanger
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF94A3B8),
            )
          : null,
      onTap: showArrow ? onTap : null,
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 72, right: 16),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
    );
  }
}
