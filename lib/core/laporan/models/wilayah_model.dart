class WilayahModel {
  final int id;
  final String nama;

  WilayahModel({
    required this.id,
    required this.nama,
  });

   factory WilayahModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WilayahModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nama: json['nama']?.toString() ??
          json['name']?.toString() ??
          '',
    );
  }
}