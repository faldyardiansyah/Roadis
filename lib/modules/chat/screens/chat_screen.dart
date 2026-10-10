import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:roadis/utils/app_colors.dart';

import '../controllers/chat_controller.dart';
import '../models/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  final int laporanId;

  const ChatScreen({super.key, required this.laporanId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  late final String _tag;
  late final ChatController _controller;

  // Identitas ini hanya untuk membedakan bubble di tampilan.
  // Identitas akun sebenarnya tetap divalidasi oleh backend.
  final ChatUser _warga = ChatUser(id: 'warga', firstName: 'Kamu');

  final ChatUser _admin = ChatUser(id: 'admin', firstName: 'Admin ROADIS');

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
    if (value == null || value.isEmpty) {
      return DateTime.now();
    }

    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
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
      if (item.balasan != null && item.balasan!.trim().isNotEmpty) {
        result.add(
          ChatMessage(
            user: ChatUser(
              id: 'admin',
              firstName: item.namaAdmin ?? 'Admin ROADIS',
            ),
            createdAt: _parseDate(item.waktuBalas ?? item.waktuKirim),
            text: item.balasan!,
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
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
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
                    const Text(
                      'Layanan Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Laporan #${widget.laporanId}',
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
