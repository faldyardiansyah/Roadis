import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Halo, Faldy Ardiansyah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TextColors.primaryTextColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text('👋', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.greyColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Lobener, Indramayu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: AppColors.blackColor,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.redColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
