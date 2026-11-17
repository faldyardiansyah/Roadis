
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/detection_result.dart';

class GroqService {
  static const String _groqEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static const String modelName = 'qwen/qwen3.8-27b';

  // Mengambil API Key dari file .env
  static String get apiKey {
    return dotenv.env['GROQ_API_KEY']?.trim() ?? '';
  }

  /// Analisis kerusakan jalan menggunakan Groq Vision API.
  static Future<DetectionResult?> detectRoadDamage(
    Uint8List imageBytes,
  ) async {
    final key = apiKey;

    if (key.isEmpty) {
      throw Exception(
        'Groq API Key tidak ditemukan. Periksa file .env.',
      );
    }

    if (imageBytes.isEmpty) {
      throw Exception('Gambar tidak boleh kosong.');
    }

    final base64Image = base64Encode(imageBytes);

    final prompt = '''
Anda adalah sistem inspeksi dan klasifikasi kerusakan jalan pintar ROADIS.

Analisis gambar jalan yang diberikan. Tentukan satu jenis kerusakan
jalan yang paling dominan berdasarkan kondisi visual gambar.

Pilih SATU kategori berikut. Nama class_name HARUS PERSIS
sesuai daftar ini:

1. alligator cracking
   Nama: Retak Buaya
   Ciri: Retakan saling terhubung menyerupai kulit buaya.

2. edge cracking
   Nama: Retak Tepi
   Ciri: Retakan pada bagian pinggir jalan.

3. longitudinal cracking
   Nama: Retak Memanjang
   Ciri: Retakan memanjang sejajar arah jalan.

4. patching
   Nama: Tambalan
   Ciri: Bagian permukaan jalan yang pernah ditambal.

5. pothole
   Nama: Lubang Jalan
   Ciri: Lubang atau cekungan pada permukaan jalan.

6. rutting
   Nama: Jalan Bergelombang
   Ciri: Alur roda atau deformasi permukaan jalan.

7. transverse cracking
   Nama: Retak Melintang
   Ciri: Retakan melintang memotong arah jalan.

ATURAN:
- Pilih hanya satu kategori yang paling dominan.
- Jangan mengarang kerusakan yang tidak terlihat.
- Gunakan nama class_name persis seperti daftar di atas.
- Jika gambar bukan jalan atau tidak ditemukan kerusakan,
  gunakan class_name "none".
- Confidence berupa angka antara 0.0 sampai 1.0.
- Keterangan menggunakan bahasa Indonesia.

Kembalikan HANYA JSON valid dengan format:

{
  "class_name": "pothole",
  "display_name": "Lubang Jalan",
  "confidence": 0.92,
  "keterangan": "Terlihat lubang pada permukaan jalan."
}

Jika tidak ditemukan kerusakan:

{
  "class_name": "none",
  "display_name": "Tidak Terdeteksi Kerusakan",
  "confidence": 0.0,
  "keterangan": "Tidak ditemukan kerusakan jalan."
}
''';

    final body = {
      'model': modelName,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': prompt,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'temperature': 0.1,
      'max_completion_tokens': 500,
      'response_format': {
        'type': 'json_object',
      },
    };

    try {
      final response = await http
          .post(
            Uri.parse(_groqEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $key',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        String errorMessage = response.body;

        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['error']?['message']?.toString() ??
              response.body;
        } catch (_) {}

        throw Exception(
          'Groq API Error (${response.statusCode}): $errorMessage',
        );
      }

      final data = jsonDecode(response.body);

      final content = data['choices']?[0]?['message']?['content']
              ?.toString()
              .trim() ??
          '';

      if (content.isEmpty) {
        throw Exception('Groq tidak memberikan hasil analisis.');
      }

      final cleanedContent = content
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final jsonResult = jsonDecode(cleanedContent);

      final className =
          jsonResult['class_name']?.toString().trim() ?? 'none';

      // Tidak ada kerusakan jalan.
      if (className == 'none') {
        return null;
      }

      // Mencocokkan kelas Groq dengan kelas YOLO.
      final classId = kYoloClassNames.indexOf(className);

      if (classId == -1) {
        throw Exception(
          'Kategori Groq tidak cocok dengan kelas YOLO: $className',
        );
      }

      final displayName =
          kClassDisplayNames[className] ??
          jsonResult['display_name']?.toString() ??
          className;

      final confidenceValue = jsonResult['confidence'];

      final confidence = confidenceValue is num
          ? confidenceValue.toDouble()
          : double.tryParse(
                confidenceValue?.toString() ?? '',
              ) ??
              0.0;

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
    } on http.ClientException catch (e) {
      throw Exception('Koneksi Groq gagal: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Format respons Groq tidak valid: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
