
class ChatMessageModel {
  final int id;
  final String pesan;
  final String? balasan;
  final String waktuKirim;
  final String? waktuBalas;
  final String? lampiranBalasanUrl;

  ChatMessageModel({
    required this.id,
    required this.pesan,
    this.balasan,
    required this.waktuKirim,
    this.waktuBalas,
    this.lampiranBalasanUrl,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final lampiran = json['lampiran_balasan'];

    return ChatMessageModel(
      id: int.tryParse('${json['id']}') ?? 0,
      pesan: json['pesan']?.toString() ?? '',
      balasan: json['balasan']?.toString(),
      waktuKirim: json['waktu_kirim']?.toString() ?? '',
      waktuBalas: json['waktu_balas']?.toString(),
      lampiranBalasanUrl:
          json['lampiran_balasan_url']?.toString() ??
          (lampiran is Map ? lampiran['url']?.toString() : null),
    );
  }

  DateTime get tanggalKirim {
    return DateTime.tryParse(waktuKirim)?.toLocal() ?? DateTime.now();
  }

  DateTime? get tanggalBalas {
    if (waktuBalas == null || waktuBalas!.isEmpty) return null;
    return DateTime.tryParse(waktuBalas!)?.toLocal();
  }
}