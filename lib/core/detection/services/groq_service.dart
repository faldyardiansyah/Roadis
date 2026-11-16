import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/detection_result.dart';

class GroqService {
  // Masukkan API key Groq Anda di sini atau lewat environment
  static const String _defaultApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '', // Masukkan API Key Groq Anda di sini
  );

  static String apiKey = _defaultApiKey;

  static const String _groqEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  // Model multimodal Groq Vision
  static const String modelName = 'llama-3.2-11b-vision-preview';

  /// Menganalisis gambar kerusakan jalan menggunakan Groq Vision API
  static Future<DetectionResult?> detectRoadDamage(Uint8List imageBytes) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw Exception(
        'Groq API Key belum diisi. Silakan masukkan Groq API Key di lib/core/detection/services/groq_service.dart.',
      );
    }

    final base64Image = base64Encode(imageBytes);

    final prompt = '''
Anda adalah sistem inspeksi dan klasifikasi kerusakan jalan pintar.
Analisis gambar jalan ini dan tentukan jenis kerusakan jalan yang paling dominan.

Pilih PERSIS satu kategori kerusakan dari daftar berikut:
1. Retak Buaya (alligator cracking / retak menyerupai kulit buaya)
2. Retak Tepi (edge cracking / retak di bagian pinggir/tepi aspal)
3. Retak Memanjang (longitudinal cracking / retak memanjang searah jalan)
4. Retak Melintang (transverse cracking / retak melintang memotong jalan)
5. Tambalan (patching / bekas tambalan aspal)
6. Lubang Jalan (pothole / cekungan atau lubang jalan)
7. Jalan Bergelombang (rutting / alur roda atau permukaan bergelombang)

Format respons HANYA berupa JSON valid tanpa markdown, contoh:
{
  "class_name": "pothole",
  "display_name": "Lubang Jalan",
  "confidence": 0.92,
  "keterangan": "Terlihat lubang jalan berukuran cukup dalam pada badan jalan."
}

Jika gambar bukan jalan atau tidak terdapat kerusakan jalan, kembalikan:
{
  "class_name": "none",
  "display_name": "Tidak Terdeteksi Kerusakan",
  "confidence": 0.0,
  "keterangan": "Tidak ditemukan kerusakan jalan pada gambar."
}
''';

    final body = {
      'model': modelName,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
            },
          ],
        },
      ],
      'temperature': 0.1,
      'max_tokens': 300,
      'response_format': {'type': 'json_object'},
    };

    final response = await http
        .post(
          Uri.parse(_groqEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $key',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      final msg = response.body;
      throw Exception('Groq API Error (${response.statusCode}): $msg');
    }

    final data = jsonDecode(response.body);
    final content = data['choices']?[0]?['message']?['content']?.toString() ?? '';

    if (content.isEmpty) {
      throw Exception('Tidak mendapatkan respons dari Groq.');
    }

    final jsonResult = jsonDecode(content);
    final className = jsonResult['class_name']?.toString() ?? 'none';
    if (className == 'none') {
      return null;
    }

    final displayName =
        jsonResult['display_name']?.toString() ??
        kClassDisplayNames[className] ??
        'Lubang Jalan';

    final confNum = jsonResult['confidence'];
    final double confidence = confNum is num
        ? confNum.toDouble()
        : double.tryParse(confNum?.toString() ?? '') ?? 0.85;

    int classId = kYoloClassNames.indexOf(className);
    if (classId < 0) classId = 4; // default ke pothole

    return DetectionResult(
      classId: classId,
      className: className,
      displayName: displayName,
      confidence: confidence.clamp(0.0, 1.0),
      x1: 0.1,
      y1: 0.1,
      x2: 0.9,
      y2: 0.9,
    );
  }
}
