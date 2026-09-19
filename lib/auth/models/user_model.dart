class UserModel {
  final int id;
  final String nama;
  final String email;
  final int? wilayahId;
  final String? profilPhoto;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.wilayahId,
    this.profilPhoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: (json['nama'] ?? json['name'] ?? '') as String,
      email: json['email'],
      wilayahId: json['wilayah_id'],
      profilPhoto: (json['profil_photo'] ?? json['profile_photo']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'wilayah_id': wilayahId,
      'profil_photo': profilPhoto,
    };
  }
}