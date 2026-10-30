import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:roadis/auth/services/session_storage.dart';
import 'package:roadis/modules/notification/services/notification_service.dart';
import 'package:roadis/modules/notification/services/local_notification_service.dart';

class NotificationPollingService with WidgetsBindingObserver {
  NotificationPollingService._();

  static final instance = NotificationPollingService._();

  final NotificationService _service = NotificationService();

  Timer? _timer;
  bool _requestBerjalan = false;
  bool _sudahAmbilDataAwal = false;
  String? _activeToken;

  final Set<int> _knownIds = {};

  void start() {
    if (_timer != null) return;

    WidgetsBinding.instance.addObserver(this);

    _check();

    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _check());
  }

  Future<void> _check() async {
    if (_requestBerjalan) return;

    final token = SessionStorage.getToken();

    if (token == null || token.isEmpty) {
      _resetSession();
      return;
    }

    if (_activeToken != token) {
      _activeToken = token;
      _knownIds.clear();
      _sudahAmbilDataAwal = false;
    }

    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    _requestBerjalan = true;

    try {
      final data = await _service.getNotifikasi();

      if (SessionStorage.getToken() != token) return;

      final currentIds = <int>{};

      for (final item in data) {
        final id = int.tryParse('${item['ID'] ?? item['id'] ?? ''}') ?? 0;

        if (id > 0) currentIds.add(id);
      }

      // Saat pertama kali, simpan notifikasi lama
      // tanpa menampilkannya kembali di HP.
      if (!_sudahAmbilDataAwal) {
        _knownIds.addAll(currentIds);
        _sudahAmbilDataAwal = true;
        return;
      }

      for (final item in data) {
        final id = int.tryParse('${item['ID'] ?? item['id'] ?? ''}') ?? 0;

        if (id == 0 || _knownIds.contains(id)) continue;

        _knownIds.add(id);

        await LocalNotificationService.showNotification(
          id: id,
          title: '${item['judul'] ?? 'ROADIS'}',
          body: '${item['pesan'] ?? ''}',
        );
      }
    } catch (e) {
      // Jika API gagal, polling akan mencoba lagi.
    } finally {
      _requestBerjalan = false;
    }
  }

  void _resetSession() {
    _activeToken = null;
    _knownIds.clear();
    _sudahAmbilDataAwal = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;

    WidgetsBinding.instance.removeObserver(this);
    _resetSession();
  }
}
