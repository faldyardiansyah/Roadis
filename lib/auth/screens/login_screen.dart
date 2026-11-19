import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/auth/controllers/auth_controller.dart';
import 'package:roadis/routes/app_routes.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Stack(
          children: [
            // Batik putih tipis di header
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BatikPattern(height: 320, opacity: 0.16),
            ),

            SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        // HEADER
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Halo,\nselamat datang.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 32,
                                        height: 1.12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Masuk untuk melapor dan memantau perbaikan jalan di Indramayu.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        height: 1.5,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.alt_route_rounded,
                                  size: 30,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms),

                        // LEMBARAN PUTIH
                        Expanded(
                          child:
                              Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      32,
                                      24,
                                      24,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(28),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildInputField(
                                          label: 'Email',
                                          hint: 'nama@email.com',
                                          prefixIcon:
                                              Icons.mail_outline_rounded,
                                          controller: _c.loginEmailC,
                                        ),

                                        const SizedBox(height: 18),

                                        _buildInputField(
                                          label: 'Kata sandi',
                                          hint: 'Masukkan kata sandi',
                                          prefixIcon:
                                              Icons.lock_outline_rounded,
                                          controller: _c.loginPassC,
                                          isPassword: true,
                                        ),

                                        const SizedBox(height: 10),

                                        Row(
                                          children: [
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              onTap: () => setState(
                                                () =>
                                                    _rememberMe = !_rememberMe,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child: Checkbox(
                                                        value: _rememberMe,
                                                        activeColor: AppColors
                                                            .primaryColor,
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                5,
                                                              ),
                                                        ),
                                                        onChanged: (v) =>
                                                            setState(
                                                              () =>
                                                                  _rememberMe =
                                                                      v ??
                                                                      false,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Ingat saya',
                                                      style:
                                                          GoogleFonts.plusJakartaSans(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            TextButton(
                                              onPressed: () {},
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                minimumSize: const Size(0, 32),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                'Lupa kata sandi?',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 22),

                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _c.login(_rememberMe),
                                            child: Text(
                                              'Masuk',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 22),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                  ),
                                              child: Text(
                                                'atau',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      color: Colors.black45,
                                                    ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 22),

                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            onPressed: () {},
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/images/google.png',
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Lanjut dengan Google',
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),

                                        Center(
                                          child: GestureDetector(
                                            onTap: () =>
                                                Get.toNamed(AppRoutes.register),
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'Belum punya akun? ',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                    ),
                                                children: [
                                                  TextSpan(
                                                    text: 'Daftar',
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColors
                                                              .primaryColor,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 150.ms, duration: 500.ms)
                                  .slideY(
                                    begin: 0.08,
                                    end: 0,
                                    duration: 500.ms,
                                    curve: Curves.easeOutCubic,
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isPassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          obscureText: isPassword ? _obscurePassword : false,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: Colors.black87,
          ),
          cursorColor: AppColors.primaryColor,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: Icon(prefixIcon, size: 22, color: Colors.grey.shade500),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 22,
                      color: Colors.grey.shade500,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: border(Colors.grey.shade200),
            enabledBorder: border(Colors.grey.shade200),
            focusedBorder: border(AppColors.primaryColor, 1.5),
          ),
        ),
      ],
    );
  }
}
