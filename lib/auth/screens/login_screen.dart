import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/auth/controllers/auth_controller.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _c = Get.find<AuthController>();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // LOGO
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.alt_route_rounded,
                    size: 40,
                    color: AppColors.primaryColor,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(.75, .75),
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 16),

              // BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Roadis Developer',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 450.ms)
                  .slideY(begin: -.4),

              const SizedBox(height: 28),

              // TITLE
              RichText(
                text: const TextSpan(
                  text: 'Selamat datang di ',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: 'Roadis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: 350.ms)
                  .fadeIn()
                  .moveY(begin: 15),

              const SizedBox(height: 10),

              Text(
                'Laporkan dan pantau kerusakan serta perbaikan jalan di Indramayu dengan mudah dan transparan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              )
                  .animate(delay: 450.ms)
                  .fadeIn()
                  .moveY(begin: 12),

              const SizedBox(height: 34),

              // EMAIL
              _buildInputField(
                label: 'Email',
                hintText: 'Masukkan email Anda',
                prefixIcon: Icons.alternate_email_outlined,
                controller: _c.loginEmailC,
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 450.ms)
                  .slideX(begin: -.08),

              const SizedBox(height: 16),

              // PASSWORD
              _buildInputField(
                label: 'Kata Sandi',
                hintText: 'Masukkan kata sandi Anda',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _c.loginPassC,
                isPassword: true,
              )
                  .animate(delay: 750.ms)
                  .fadeIn(duration: 450.ms)
                  .slideX(begin: .08),

              const SizedBox(height: 16),

              // REMEMBER
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.primaryColor,
                    onChanged: (v) {
                      setState(() => _rememberMe = v ?? false);
                    },
                  ),
                  Text(
                    'Ingat saya',
                    style: GoogleFonts.plusJakartaSans(),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Lupa Kata Sandi?',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
                  .animate(delay: 900.ms)
                  .fadeIn()
                  .moveY(begin: 8),

              const SizedBox(height: 18),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    _c.login(_rememberMe);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Masuk Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: 1050.ms)
                  .fadeIn()
                  .scale(begin: const Offset(.95, .95)),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'ATAU MASUK DENGAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              )
                  .animate(delay: 1150.ms)
                  .fadeIn(),

              const SizedBox(height: 22),

              // GOOGLE
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google.png',
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Masuk dengan Google',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: 1250.ms)
                  .fadeIn()
                  .moveY(begin: 12),

              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.black54,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.register),
                    child: Text(
                      'Daftar Sekarang',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
                  .animate(delay: 1400.ms)
                  .fadeIn()
                  .moveY(begin: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isPassword
              ? TextInputType.text
              : TextInputType.emailAddress,
          obscureText: isPassword ? _obscurePassword : false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.grey.shade500,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}