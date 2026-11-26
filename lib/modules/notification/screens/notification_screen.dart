import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadis/modules/notification/services/notification_polling_service.dart';
import 'package:roadis/modules/notification/services/notification_service.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:roadis/utils/widgets/batik_patern.dart';
import 'package:roadis/utils/widgets/roadis_skeleton.dart';

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
      NotificationPollingService.instance.unreadCount.value = _unreadCount;
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

  int get _unreadCount =>
      _notifications.where((item) => !_isRead(item)).length;

  Future<void> _markRead(Map<String, dynamic> item) async {
    if (_busy || _isRead(item) || _id(item) == 0) return;
    HapticFeedback.selectionClick();
    setState(() => _busy = true);
    try {
      await _service.tandaiDibaca(_id(item));
      if (!mounted) return;
      setState(() => item['is_read'] = true);
      NotificationPollingService.instance.unreadCount.value = _unreadCount;
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _markAll() async {
    if (_busy || _notifications.isEmpty || _unreadCount == 0) return;
    HapticFeedback.lightImpact();
    setState(() => _busy = true);
    try {
      await _service.tandaiSemuaDibaca();
      if (!mounted) return;
      setState(() {
        for (final item in _notifications) {
          item['is_read'] = true;
        }
      });
      NotificationPollingService.instance.unreadCount.value = 0;
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
        color: const Color(0xFF16A34A),
        label: 'Selesai',
      );
    }
    if (lower.contains('proses') || lower.contains('tinjau')) {
      return (
        icon: Icons.sync_rounded,
        color: const Color(0xFFD97706),
        label: 'Diproses',
      );
    }
    if (lower.contains('chat') ||
        lower.contains('pesan') ||
        lower.contains('balasan')) {
      return (
        icon: Icons.chat_bubble_rounded,
        color: AppColors.primaryColor,
        label: 'Pesan',
      );
    }
    return (
      icon: Icons.notifications_rounded,
      color: AppColors.primaryColor,
      label: 'Info',
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
            _buildCurvedHeader(topInset),
            const SizedBox(height: 14),
            _buildFilterRow(),
            const SizedBox(height: 10),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedHeader(double topInset) {
    final hasUnread = _unreadCount > 0;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
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
                              'Notifikasi',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              hasUnread
                                  ? '$_unreadCount notifikasi belum dibaca'
                                  : 'Semua notifikasi sudah dibaca',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.86),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _busy || _loading || !hasUnread
                            ? null
                            : _markAll,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: hasUnread ? 1.0 : 0.45,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.done_all_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Baca Semua',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 360.ms).slideY(begin: -0.1, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    const filters = [
      (label: 'Semua', icon: Icons.all_inbox_rounded),
      (label: 'Hari Ini', icon: Icons.today_rounded),
      (label: 'Kemarin', icon: Icons.history_rounded),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final item = filters[index];
          final isSelected = _filter == item.label;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _filter = item.label);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 14,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 360.ms);
  }

  Widget _buildBody() {
    if (_loading) {
      return RoadisSkeleton(
        enabled: true,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          itemCount: 5,
          itemBuilder: (_, __) => _buildSkeletonCard(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 30,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Gagal memuat notifikasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 17,
                  color: Colors.white,
                ),
                label: Text(
                  'Coba Lagi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final items = _filtered;

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primaryColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 28, right: 28),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: AppColors.lightIceBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_off_outlined,
                      size: 32,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Belum ada notifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pembaruan status laporan dan pesan dari petugas akan tampil di sini.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final title =
              (item['judul'] ?? item['Judul'] ?? 'Notifikasi').toString();
          final message = (item['pesan'] ?? item['Pesan'] ?? '').toString();
          final style = _style(title);

          return _buildNotificationCard(
            index: index,
            icon: style.icon,
            title: title,
            subtitle: message,
            status: style.label,
            statusColor: style.color,
            time: _time(_date(item)),
            isRead: _isRead(item),
            onTap: () => _markRead(item),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required String time,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isRead ? const Color(0xFFF8FAFC) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isRead
                      ? const Color(0xFFE2E8F0)
                      : AppColors.primaryColor.withOpacity(0.28),
                ),
                boxShadow: isRead
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.06),
                          blurRadius: 12,
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
                      borderRadius: BorderRadius.circular(13),
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
                              child: Row(
                                children: [
                                  if (!isRead) ...[
                                    Container(
                                      width: 7,
                                      height: 7,
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: isRead
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.11),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
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
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
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
        .fadeIn(
          delay: Duration(milliseconds: 35 * index.clamp(0, 8)),
          duration: 340.ms,
        )
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 140, height: 14, color: Colors.grey.shade200),
                    const Spacer(),
                    Container(width: 50, height: 16, color: Colors.grey.shade200),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 6),
                Container(width: 100, height: 10, color: Colors.grey.shade200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
