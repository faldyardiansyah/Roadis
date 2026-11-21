import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/modules/home/controllers/home_controller.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/roadis_skeleton.dart';
import 'package:skeletonizer/skeletonizer.dart';

const _amber = Color(0xFFF59E0B);
const _green = Color(0xFF22C55E);

int _toInt(Object? v) => v is int ? v : int.tryParse('$v') ?? 0;

class ReportStats extends StatelessWidget {
  const ReportStats({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Obx(() {
      final loading = c.isLoadingStats.value;
      final error = c.errorStats.value;

      if (error != null) {
        return _ErrorRow(message: error, onRetry: c.fetchRiwayat);
      }

      final total = loading ? 0 : _toInt(c.totalLaporan);
      final diproses = loading ? 0 : _toInt(c.totalDiproses);
      final selesai = loading ? 0 : _toInt(c.totalSelesai);
      final persen = total == 0 ? 0 : (selesai * 100 / total).round();

      return RoadisSkeleton(
        enabled: loading,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.14),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      size: 17,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Total laporan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$persen% selesai',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                loading ? '000' : '$total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: TextColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'laporan jalan rusak yang kamu kirim',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: AppColors.greyColor,
                ),
              ),
              const SizedBox(height: 16),
              Skeleton.leaf(
                child: _ProgressBar(
                  total: total,
                  diproses: diproses,
                  selesai: selesai,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.hourglass_bottom_rounded,
                      value: loading ? '00' : '$diproses',
                      label: 'Diproses',
                      color: _amber,
                    ),
                  ),
                  Container(width: 1, height: 36, color: Colors.grey.shade200),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.check_circle_rounded,
                      value: loading ? '00' : '$selesai',
                      label: 'Selesai',
                      color: _green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ProgressBar extends StatelessWidget {
  final int total;
  final int diproses;
  final int selesai;

  const _ProgressBar({
    required this.total,
    required this.diproses,
    required this.selesai,
  });

  @override
  Widget build(BuildContext context) {
    final lain = total - diproses - selesai;
    final segs = <Widget>[];

    void add(int value, Color color) {
      if (value <= 0) return;
      if (segs.isNotEmpty) segs.add(const SizedBox(width: 3));
      segs.add(
        Expanded(
          flex: value,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }

    add(selesai, _green);
    add(diproses, _amber);
    add(lain, AppColors.primaryColor.withOpacity(0.25));

    if (segs.isEmpty) {
      segs.add(
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }

    return SizedBox(height: 8, child: Row(children: segs));
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: TextColors.primaryTextColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRow({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.redAccent,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
