import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.whiteColor,
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JALANKU INDRAMAYU',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Profil Pengguna',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TextColors.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        size: 18,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.blackColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Faldy Ardiansyah',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: TextColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 12,
                            color: AppColors.greenColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Warga Terverifikasi (KTP Indramayu)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 11,
                            color: AppColors.greyColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'budi.santoso@example.com',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 11,
                            color: AppColors.greyColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '+62 812-3456-7890',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildContribusi(
  String label,
  Color nilaiColor,
  int nilai,
  bool Iconbool
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color : AppColors.whiteColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TextColors.primaryTextColor,
          ),
        ),
        Row(
          children: [
            Text(
              nilai.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TextColors.primaryTextColor,
              ),
            ),
             const SizedBox(width: 5),
            Icon(
              Iconbool ? Icons.arrow_upward : Icons.arrow_downward,
              color: nilaiColor,
            ),
          ],
        ),
      ],
    ),
  );
}