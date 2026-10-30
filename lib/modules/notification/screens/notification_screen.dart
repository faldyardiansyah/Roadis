import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/modules/notification/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _service = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  String _filter = 'Semua';
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getNotifikasi();
      if (!mounted) return;
      setState(() {
        _notifications = data;
        _notifications.sort((a, b) => _date(b).compareTo(_date(a)));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  DateTime _date(Map<String, dynamic> item) {
    final raw = item['CreatedAt'] ?? item['created_at'] ?? item['createdAt'];
    return DateTime.tryParse(raw?.toString() ?? '')?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Map<String, dynamic>> get _filtered {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return _notifications.where((item) {
      if (_filter == 'Hari Ini') return _sameDay(_date(item), now);
      if (_filter == 'Kemarin') return _sameDay(_date(item), yesterday);
      return true;
    }).toList();
  }

  int _id(Map<String, dynamic> item) =>
      int.tryParse('${item['ID'] ?? item['id'] ?? ''}') ?? 0;

  bool _isRead(Map<String, dynamic> item) {
    final value = item['is_read'] ?? item['IsRead'] ?? false;
    return value == true || value == 1 || value == 'true';
  }

  Future<void> _markRead(Map<String, dynamic> item) async {
    if (_busy || _isRead(item) || _id(item) == 0) return;
    setState(() => _busy = true);
    try {
      await _service.tandaiDibaca(_id(item));
      if (!mounted) return;
      setState(() => item['is_read'] = true);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _markAll() async {
    if (_busy || _notifications.isEmpty) return;
    setState(() => _busy = true);
    try {
      await _service.tandaiSemuaDibaca();
      if (!mounted) return;
      setState(() {
        for (final item in _notifications) {
          item['is_read'] = true;
        }
      });
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memperbarui notifikasi: $error')),
    );
  }

  String _time(DateTime date) {
    if (date.year == 1970) return '-';
    final diff = DateTime.now().difference(date);
    if (diff.isNegative) return 'Baru saja';
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  ({IconData icon, Color color, String label}) _style(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('selesai') || lower.contains('diperbaiki')) {
      return (
        icon: Icons.verified_rounded,
        color: Colors.green,
        label: 'Selesai',
      );
    }
    if (lower.contains('proses') || lower.contains('tinjau')) {
      return (
        icon: Icons.sync_rounded,
        color: Colors.orange,
        label: 'Diproses',
      );
    }
    if (lower.contains('chat') ||
        lower.contains('pesan') ||
        lower.contains('balasan')) {
      return (
        icon: Icons.chat_bubble_rounded,
        color: Colors.blue,
        label: 'Pesan',
      );
    }
    return (
      icon: Icons.notifications_rounded,
      color: Colors.blue,
      label: 'Info',
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: Get.back,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notifikasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.checklist_sharp,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fade(duration: 400.ms)
                .slideY(begin: -0.2, end: 0, duration: 400.ms),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Notifikasi Terbaru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _busy || _loading || _notifications.isEmpty
                        ? null
                        : _markAll,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    icon: const Icon(
                      Icons.checklist_sharp,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    label: Text(
                      'Tandai Semua Dibaca',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 500.ms, delay: 150.ms),
            const SizedBox(height: 8),
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButtonFilter(
                      Icons.all_inbox,
                      'Semua',
                      _filter == 'Semua',
                      () => setState(() => _filter = 'Semua'),
                    ),
                    _buildButtonFilter(
                      Icons.calendar_month,
                      'Hari Ini',
                      _filter == 'Hari Ini',
                      () => setState(() => _filter = 'Hari Ini'),
                    ),
                    _buildButtonFilter(
                      Icons.calendar_month,
                      'Kemarin',
                      _filter == 'Kemarin',
                      () => setState(() => _filter = 'Kemarin'),
                    ),
                  ],
                )
                .animate()
                .fade(duration: 500.ms, delay: 250.ms)
                .slideX(begin: 0.1, end: 0, duration: 500.ms),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 40,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Gagal memuat notifikasi',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            TextButton(
                              onPressed: _load,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 20,
                        ),
                        itemCount: _filtered.isEmpty ? 1 : _filtered.length,
                        itemBuilder: (context, index) {
                          final items = _filtered;
                          if (items.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 90),
                              child: Center(
                                child: Text(
                                  'Belum ada notifikasi',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          }
                          final item = items[index];
                          final title =
                              (item['judul'] ?? item['Judul'] ?? 'Notifikasi')
                                  .toString();
                          final message = (item['pesan'] ?? item['Pesan'] ?? '')
                              .toString();
                          final style = _style(title);
                          return _buildListNotifikasi(
                            style.icon,
                            title,
                            message,
                            style.label,
                            style.color,
                            _time(_date(item)),
                            () => _markRead(item),
                            isRead: _isRead(item),
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Center(
                  child: Text(
                    '$currentYear Developer Roadis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                )
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// --- HELPER METHODS ---

Widget _buildButtonFilter(
  IconData icon,
  String label,
  bool isSelected,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black54,
            size: 12,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildListNotifikasi(
  IconData icon,
  String title,
  String subtitle,
  String status,
  Color statusColor,
  String time,
  VoidCallback onTap, {
  bool isRead = false,
}) {
  return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isRead ? const Color(0xFFF2F5F8) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9EEF3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
      .animate()
      .fade(duration: 500.ms)
      .slideY(begin: 0.15, end: 0, duration: 500.ms);
}
