import 'dart:async';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roadis/modules/chat/models/chat_message_model.dart';
import 'package:roadis/modules/chat/services/chat_service.dart';

class ChatController extends GetxController {
  final int laporanId;
  final ChatService _service = ChatService();

  ChatController({required this.laporanId});

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;

  Timer? _timer;
  bool _isFetching = false;

  final ChatUser currentUser = ChatUser(id: 'warga', firstName: 'Kamu');

  final ChatUser adminUser = ChatUser(id: 'admin', firstName: 'Admin ROADIS');

  @override
  void onInit() {
    super.onInit();
    loadMessages();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadMessages(showLoading: false),
    );
  }

  Future<void> loadMessages({bool showLoading = true}) async {
    if (_isFetching) return;

    _isFetching = true;

    if (showLoading) isLoading.value = true;

    try {
      final data = await _service.getChat(laporanId);
      final List<ChatMessage> converted = [];

      for (final ChatMessageModel item in data) {
        if (item.pesan.trim().isNotEmpty) {
          converted.add(
            ChatMessage(
              text: item.pesan,
              user: currentUser,
              createdAt: item.tanggalKirim,
            ),
          );
        }

        if (item.balasan != null && item.balasan!.trim().isNotEmpty) {
          converted.add(
            ChatMessage(
              text: item.balasan!,
              user: adminUser,
              createdAt: item.tanggalBalas ?? item.tanggalKirim,
            ),
          );
        }
      }

      // DashChat menampilkan pesan terbaru di urutan pertama.
      converted.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      messages.assignAll(converted);
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  Future<void> sendMessage(ChatMessage message) async {
    final text = message.text.trim();

    if (text.isEmpty || isSending.value) return;

    isSending.value = true;

    try {
      await _service.sendMessage(laporanId, text);
      await loadMessages();

      errorMessage.value = '';
    } catch (e) {
      Get.snackbar(
        'Gagal mengirim pesan',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
