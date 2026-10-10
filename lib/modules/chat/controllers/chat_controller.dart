
import 'dart:async';

import 'package:get/get.dart';
import 'package:roadis/utils/widgets/show_snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final int laporanId;
  final ChatService _service = ChatService();

  ChatController({required this.laporanId});

  final RxList<ChatMessageModel> messages =
      <ChatMessageModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;

  Timer? _timer;
  bool _requestBerjalan = false;

  @override
  void onInit() {
    super.onInit();

    muatChat();

    // Memeriksa balasan admin secara berkala.
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => muatChat(silent: true),
    );
  }

  Future<void> muatChat({bool silent = false}) async {
    if (_requestBerjalan) return;

    _requestBerjalan = true;

    if (!silent) {
      isLoading.value = true;
      errorMessage.value = '';
    }

    try {
      final hasil = await _service.getChatWarga(laporanId);

      messages.assignAll(hasil);
      errorMessage.value = '';
    } catch (e) {
      if (!silent) {
        errorMessage.value = e.toString();
      }
    } finally {
      _requestBerjalan = false;
      isLoading.value = false;
    }
  }

  Future<bool> kirimPesan(String teks) async {
    final pesan = teks.trim();

    if (pesan.isEmpty || isSending.value) {
      return false;
    }

    isSending.value = true;

    try {
      await _service.kirimPesanWarga(
        laporanId: laporanId,
        pesan: pesan,
      );

      await muatChat();
      return true;
    } catch (e) {
      showAwesomeSnackbar(title: 'Gagal', message: 'Pesan gagal di kirim', contentType: ContentType.failure);

      return false;
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
