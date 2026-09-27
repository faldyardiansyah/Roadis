import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';

void showPhotoOptionsSheet(ProfileController c) {
  Get.bottomSheet(
    const _PhotoOptionsContent(),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
  ).then((source) {
    if (source is ImageSource) {
      c.pickAndUploadPhoto(source);
    }
  });
}

class _PhotoOptionsContent extends StatelessWidget {
  const _PhotoOptionsContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF007BFF)),
            title: Text(
              'Ambil Foto',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            onTap: () => Get.back(result: ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF007BFF)),
            title: Text(
              'Pilih dari Galeri',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            onTap: () => Get.back(result: ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}