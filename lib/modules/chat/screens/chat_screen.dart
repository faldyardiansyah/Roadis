import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:roadis/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  final int laporanId;
  final String? jenisJalan;
  final String? kewenanganJalan;
  final String? wilayahNama;

  const ChatScreen({
    super.key,
    required this.laporanId,
    this.jenisJalan,
    this.kewenanganJalan,
    this.wilayahNama,
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
                  currentUserContainerColor: const Color(0xFF0284C7),
                  containerColor: Colors.white,
                  currentUserTextColor: Colors.white,
                  textColor: const Color(0xFF1E293B),
                  showTime: true,
                  timeFontSize: 10,
                  messagePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  borderRadius: 18,
                  showOtherUsersAvatar: true,
                  showCurrentUserAvatar: false,
                  avatarBuilder: (user, onPressAvatar, onLongPressAvatar) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 18,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    );
                  },
                ),

                inputOptions: InputOptions(
                  inputDecoration: InputDecoration(
                    hintText: 'Tulis pesan Anda untuk admin...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                    ),
                  ),
                  sendButtonBuilder: (send) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 4,
                        bottom: 2,
                      ),
                      child:
                          IconButton(
                                onPressed: send,
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(44, 44),
                                  elevation: 2,
                                  shadowColor: const Color(0x400284C7),
                                ),
                                icon: const Icon(Icons.send_rounded, size: 20),
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
    String adminSubtitle = 'Laporan #JK-${widget.laporanId}';

    // Cari tahu nama admin spesifik dari pesan balasan yang sudah masuk (jika ada)
    String? namaAdminDariPesan;
    for (final m in _controller.messages) {
      if (m.namaAdmin != null && m.namaAdmin!.trim().isNotEmpty) {
        namaAdminDariPesan = m.namaAdmin!.trim();
        break;
      }
    }

    final jj = (widget.jenisJalan ?? '').toLowerCase().trim();
    final kw = (widget.kewenanganJalan ?? '').toLowerCase().trim();
    final wilayah = (widget.wilayahNama ?? '').trim();

    if (namaAdminDariPesan != null) {
      adminTitle = namaAdminDariPesan;
      if (jj == 'desa' || kw.contains('pemdes') || kw.contains('desa')) {
        adminSubtitle = wilayah.isNotEmpty ? 'Pemerintah Desa $wilayah' : 'Admin Pemdes';
      } else if (jj == 'kabupaten' || kw.contains('kabupaten') || kw.contains('pu')) {
        adminSubtitle = 'Dinas PUPR Kab. Indramayu';
      } else {
        adminSubtitle = 'Admin Pengelola Laporan';
      }
    } else {
      if (jj == 'desa' || kw.contains('pemdes') || kw.contains('desa')) {
        adminTitle = wilayah.isNotEmpty ? 'Admin Desa $wilayah' : 'Admin Pemdes';
        adminSubtitle = 'Pemerintah Desa • #JK-${widget.laporanId}';
      } else if (jj == 'kabupaten' || kw.contains('kabupaten') || kw.contains('pu')) {
        adminTitle = 'Admin Dinas PU Kab. Indramayu';
        adminSubtitle = 'DPUPR Indramayu • #JK-${widget.laporanId}';
      } else if (jj == 'provinsi' || kw.contains('provinsi')) {
        adminTitle = 'Admin Dinas PU / Provinsi';
        adminSubtitle = 'Koordinasi Wilayah • #JK-${widget.laporanId}';
      } else if (jj == 'nasional' || kw.contains('nasional') || kw.contains('pusat')) {
        adminTitle = 'Admin Dinas PU / Nasional';
        adminSubtitle = 'Pusat & Kabupaten • #JK-${widget.laporanId}';
      }
    }

    return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 18,
            left: 14,
            right: 14,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x300284C7),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: Get.back,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                ),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adminTitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            adminSubtitle,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFE0F2FE),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _controller.muatChat(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                ),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: -0.12, end: 0, curve: Curves.easeOutCubic);
  }
}
