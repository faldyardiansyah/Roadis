
class ChatMessageModel {
  final int id;
  final int laporanId;
  final int userId;
  final String? namaUser;
  final String pesan;
  final String waktuKirim;
  final int? adminId;
  final String? namaAdmin;
  final String? balasan;
  final String? waktuBalas;
  final String? lampiranBalasanUrl;

  ChatMessageModel({
    required this.id,
    required this.laporanId,
    required this.userId,
    this.namaUser,
    required this.pesan,
    required this.waktuKirim,
    this.adminId,
    this.namaAdmin,
    this.balasan,
    this.waktuBalas,
    this.lampiranBalasanUrl,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final admin = json['admin'];
    final lampiran = json['lampiran_balasan'];

    return ChatMessageModel(
      id: _toInt(json['id']),
      laporanId: _toInt(json['laporan_kerusakan_id']),
      userId: _toInt(json['user_id']),
      namaUser: user is Map
          ? (user['name'] ?? user['nama'])?.toString()
          : null,
      pesan: json['pesan']?.toString() ?? '',
      waktuKirim: json['waktu_kirim']?.toString() ?? '',
      adminId: json['admin_id'] == null
          ? null
          : _toInt(json['admin_id']),
      namaAdmin: admin is Map
          ? (admin['name'] ?? admin['nama'])?.toString()
          : null,
      balasan: json['balasan']?.toString(),
      waktuBalas: json['waktu_balas']?.toString(),
      lampiranBalasanUrl: json['lampiran_balasan_url']?.toString() ??
          (lampiran is Map ? lampiran['url']?.toString() : null),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
