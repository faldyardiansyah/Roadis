import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:roadis/utils/app_colors.dart';

import '../controllers/chat_controller.dart';
import '../models/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  final int laporanId;
  final String? jenisJalan;
  final String? kewenanganJalan;

  const ChatScreen({
    super.key,
    required this.laporanId,
    this.jenisJalan,
    this.kewenanganJalan,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String _tag;
  late final ChatController _controller;

  // Identitas ini hanya untuk membedakan bubble di tampilan.
  // Identitas akun sebenarnya tetap divalidasi oleh backend.
  final ChatUser _warga = ChatUser(id: 'warga', firstName: 'Kamu');

  @override
  void initState() {
    super.initState();

    _tag = 'chat_laporan_${widget.laporanId}';

    _controller = Get.put(
      ChatController(laporanId: widget.laporanId),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<ChatController>(tag: _tag)) {
      Get.delete<ChatController>(tag: _tag);
    }

    super.dispose();
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return DateTime(1970);
    }

    final text = value.trim();

    // Format standar dari database/API
    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      return parsed.toLocal();
    }

    final match = RegExp(
      r'^\w+,\s*(\d{1,2})\s+(\w+)\s+(\d{4})\s+jam\s+(\d{1,2}):(\d{2})(?:\s+([A-Za-z]+))?$',
      caseSensitive: false,
    ).firstMatch(text);

    if (match != null) {
      const bulan = {
        'januari': 1,
        'jan': 1,
        'februari': 2,
        'feb': 2,
        'maret': 3,
        'mar': 3,
        'april': 4,
        'apr': 4,
        'mei': 5,
        'juni': 6,
        'jun': 6,
        'juli': 7,
        'jul': 7,
        'agustus': 8,
        'agu': 8,
        'ags': 8,
        'september': 9,
        'sep': 9,
        'oktober': 10,
        'okt': 10,
        'november': 11,
        'nov': 11,
        'desember': 12,
        'des': 12,
      };

      final namaBulan = match.group(2)!.toLowerCase();
      final nomorBulan = bulan[namaBulan];

      if (nomorBulan != null) {
        return DateTime(
          int.parse(match.group(3)!),
          nomorBulan,
          int.parse(match.group(1)!),
          int.parse(match.group(4)!),
          int.parse(match.group(5)!),
        );
      }
    }

    debugPrint('GAGAL PARSE WAKTU CHAT: $value');
    return DateTime(1970);
  }

  // Mengubah data dari API menjadi pesan milik DashChat.
  List<ChatMessage> _convertMessages(List<ChatMessageModel> data) {
    final result = <ChatMessage>[];

    for (final item in data) {
      // Pesan dari warga.
      result.add(
        ChatMessage(
          user: _warga,
          createdAt: _parseDate(item.waktuKirim),
          text: item.pesan,
        ),
      );

      // Balasan admin ditampilkan sebagai pesan terpisah.
      final balasanText = item.balasan?.trim();
      final lampiranUrl = item.lampiranBalasanUrl?.trim();
      final hasBalasan = (balasanText != null && balasanText.isNotEmpty) ||
          (lampiranUrl != null && lampiranUrl.isNotEmpty);

      if (hasBalasan) {
        final medias = <ChatMedia>[];
        if (lampiranUrl != null && lampiranUrl.isNotEmpty) {
          medias.add(
            ChatMedia(
              url: lampiranUrl,
              fileName: 'Lampiran Admin',
              type: MediaType.image,
            ),
          );
        }

        result.add(
          ChatMessage(
            user: ChatUser(
              id: 'admin',
              firstName: item.namaAdmin ?? 'Admin ROADIS',
            ),
            createdAt: _parseDate(item.waktuBalas ?? item.waktuKirim),
            text: balasanText ?? '',
            medias: medias.isNotEmpty ? medias : null,
          ),
        );
      }
    }

    // DashChat menampilkan pesan terbaru di bagian atas
    // daftar internalnya; urutkan dari terbaru ke terlama.
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return result;
  }

  Future<void> _kirimPesan(ChatMessage message) async {
    final teks = message.text.trim();

    if (teks.isEmpty) return;

    await _controller.kirimPesan(teks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (_controller.errorMessage.value.isNotEmpty &&
                  _controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _controller.errorMessage.value,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _controller.muatChat(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return DashChat(
                currentUser: _warga,
                messages: _convertMessages(_controller.messages.toList()),
                onSend: _kirimPesan,

                messageOptions: MessageOptions(
                  currentUserContainerColor: AppColors.primaryColor,
                  containerColor: Colors.white,
                  currentUserTextColor: Colors.white,
                  textColor: const Color(0xFF1E293B),
                  showTime: true,
                  messagePadding: const EdgeInsets.all(12),
                  borderRadius: 18,
                ),

                inputOptions: InputOptions(
                  inputDecoration: InputDecoration(
                    hintText: 'Tulis pesan di sini...',
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  sendButtonBuilder: (send) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 4,
                        bottom: 4,
                      ),
                      child:
                          IconButton(
                                onPressed: send,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(48, 48),
                                ),
                                icon: const Icon(Icons.send_rounded),
                              )
                              .animate()
                              .fadeIn(duration: 250.ms)
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                duration: 250.ms,
                              ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String adminTitle = 'Layanan Admin';
    final jj = (widget.jenisJalan ?? '').toLowerCase().trim();
    final kw = (widget.kewenanganJalan ?? '').toLowerCase().trim();
    if (jj == 'desa' || kw.contains('pemdes') || kw.contains('desa')) {
      adminTitle = 'Admin Pemdes';
    } else if (jj == 'kabupaten' || kw.contains('kabupaten') || kw.contains('pu')) {
      adminTitle = 'Admin Dinas PU';
    } else if (jj == 'provinsi' || kw.contains('provinsi')) {
      adminTitle = 'Admin Dinas PU / Superadmin';
    } else if (jj == 'nasional' || kw.contains('nasional') || kw.contains('pusat')) {
      adminTitle = 'Admin Dinas PU / Superadmin';
    }

    return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 22,
            left: 18,
            right: 18,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x260284C7),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adminTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Laporan #JK-${widget.laporanId}',
                      style: const TextStyle(
                        color: Color(0xFFDCEFFE),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _controller.muatChat(),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: -0.12, end: 0, curve: Curves.easeOutCubic);
  }
}
