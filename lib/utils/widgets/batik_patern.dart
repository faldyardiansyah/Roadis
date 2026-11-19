import 'package:flutter/material.dart';
class BatikPattern extends StatelessWidget {
  final Widget? child;
  final String asset;
  final Color color;
  final double opacity;
  final double scale;
  final double? height;
  final double? width;

  /// Pola memudar ke arah bawah.
  final bool fadeOut;
  final BorderRadius? borderRadius;

  const BatikPattern({
    super.key,
    this.child,
    this.asset = 'assets/images/batik.png',
    this.color = Colors.white,
    this.opacity = 0.14,
    this.scale = 2.2,
    this.height,
    this.width,
    this.fadeOut = true,
    this.borderRadius,
  });

  // Piksel gelap jadi [color] solid, piksel terang jadi transparan
  ColorFilter get _tint => ColorFilter.matrix(<double>[
    0,
    0,
    0,
    0,
    color.red.toDouble(),
    0,
    0,
    0,
    0,
    color.green.toDouble(),
    0,
    0,
    0,
    0,
    color.blue.toDouble(),
    -0.2126,
    -0.7152,
    -0.0722,
    0,
    255,
  ]);

  Widget _buildPattern() {
    Widget pattern = Opacity(
      opacity: opacity,
      child: ColorFiltered(
        colorFilter: _tint,
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(asset),
              repeat: ImageRepeat.repeat,
              scale: scale,
            ),
          ),
        ),
      ),
    );

    if (fadeOut) {
      pattern = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.transparent],
        ).createShader(rect),
        child: pattern,
      );
    }
    return IgnorePointer(child: pattern);
  }

  @override
  Widget build(BuildContext context) {
    Widget result;

    if (child != null) {
      // Mode bungkus: ukuran ikut child, batik di belakangnya.
      result = Stack(
        children: [
          Positioned.fill(child: _buildPattern()),
          child!,
        ],
      );
      if (height != null || width != null) {
        result = SizedBox(height: height, width: width, child: result);
      }
    } else if (height != null || width != null) {
      result = SizedBox(height: height, width: width, child: _buildPattern());
    } else {
      // Tanpa child & ukuran: mengisi parent (Positioned.fill / Expanded).
      result = SizedBox.expand(child: _buildPattern());
    }

    if (borderRadius != null) {
      result = ClipRRect(borderRadius: borderRadius!, child: result);
    }
    return result;
  }
}
