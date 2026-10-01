import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/detection_result.dart';

class DetectionService {
  static const int inputSize = 800; // ini sesuai sama di trainignya
  static const double confThreshold = 0.35;
  static const double iouThreshold = 0.45;

  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/models/best.tflite');

    print('Model loaded successfully');
    print("Input shape: ${_interpreter!.getInputTensor(0).shape}");
    print("Output shape: ${_interpreter!.getOutputTensor(0).shape}");
  }

  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    if (_interpreter == null) {
      throw Exception(
        'Model belum dimuat. Panggil loadModel() terlebih dahulu.',
      );
    }

    final original = img.decodeImage(imageBytes);
    if (original == null) {
      throw Exception('Gagal mendekode gambar.');
    }

    // ini itu buat jaga aspek rasio, tambah padding abu"
    final scale = math.min(
      inputSize / original.width,
      inputSize / original.height,
    );

    final newWidth = (original.width * scale).round();
    final newHeight = (original.height * scale).round();

    final padX = ((inputSize - newWidth) / 2).round();
    final padY = ((inputSize - newHeight) / 2).round();

    final resized = img.copyResize(
      original,
      width: newWidth,
      height: newHeight,
    );

    final canvas = img.Image(width: inputSize, height: inputSize);

    img.fill(canvas, color: img.ColorRgb8(114, 114, 114));
    img.compositeImage(canvas, resized, dstX: padX, dstY: padY);

    // ini buat normalisasi ke [0.1] bentuk input [1,800,800,3]
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final pixel = canvas.getPixel(x, y);

          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );
    // output YOLO11: bentuk [1, 4+jumlah_kelas, 11625]
    final numClasses = kYoloClassNames.length;

    // YOLO input 800x800:
    // 100x100 + 50x50 + 25x25 = 11625
    final numBoxes = 11625;

    final output = List.generate(
      1,
      (_) => List.generate(4 + numClasses, (_) => List.filled(numBoxes, 0.0)),
    );

    _interpreter!.run(input, output);

    final raw = output[0];

    final candidates = <DetectionResult>[];

    for (int i = 0; i < numBoxes; i++) {
      // Cari skor kelas tertinggi untuk box ke-i
      double bestScore = 0;
      int bestClass = -1;

      for (int c = 0; c < numClasses; c++) {
        final score = raw[4 + c][i];

        if (score > bestScore) {
          bestScore = score;
          bestClass = c;
        }
      }

      if (bestScore < confThreshold || bestClass == -1) {
        continue;
      }

      // box dalam format cx, cy, w, h
      final cx = raw[0][i];
      final cy = raw[1][i];
      final w = raw[2][i];
      final h = raw[3][i];

      // buat konversi ke x1, y1, x2, y2
      double x1 = cx - w / 2;
      double y1 = cy - h / 2;
      double x2 = cx + w / 2;
      double y2 = cy + h / 2;

      //   buat balikin padding Letterbox lalu scale ke ukuran gambar asli
      x1 = (x1 - padX) / scale;
      y1 = (y1 - padY) / scale;
      x2 = (x2 - padX) / scale;
      y2 = (y2 - padY) / scale;

      final className = kYoloClassNames[bestClass];

      candidates.add(
        DetectionResult(
          classId: bestClass,
          className: className,
          displayName: kClassDisplayNames[className] ?? className,
          confidence: bestScore,
          x1: x1.clamp(0, original.width.toDouble()),
          y1: y1.clamp(0, original.height.toDouble()),
          x2: x2.clamp(0, original.width.toDouble()),
          y2: y2.clamp(0, original.height.toDouble()),
        ),
      );
    }
    return _nonMaxSuppression(candidates);
  }

  List<DetectionResult> _nonMaxSuppression(List<DetectionResult> boxes) {
    boxes.sort((a, b) => b.confidence.compareTo(a.confidence));

    final selected = <DetectionResult>[];

    while (boxes.isNotEmpty) {
      final current = boxes.removeAt(0);
      selected.add(current);

      boxes.removeWhere((box) {
        if (box.classId != current.classId) {
          return false;
        }

        return _iou(current, box) > iouThreshold;
      });
    }

    return selected;
  }

  double _iou(DetectionResult a, DetectionResult b) {
    final interX1 = math.max(a.x1, b.x1);
    final interY1 = math.max(a.y1, b.y1);
    final interX2 = math.min(a.x2, b.x2);
    final interY2 = math.min(a.y2, b.y2);

    final interArea =
        math.max(0, interX2 - interX1) * math.max(0, interY2 - interY1);

    final areaA = (a.x2 - a.x1) * (a.y2 - a.y1);

    final areaB = (b.x2 - b.x1) * (b.y2 - b.y1);

    final unionArea = areaA + areaB - interArea;

    if (unionArea <= 0) return 0;

    return interArea / unionArea;
  }

  void dispose() {
    _interpreter?.close();
  }
}
