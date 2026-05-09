import 'package:flutter/material.dart';

class CrtOverlay extends StatelessWidget {
  final Widget child;
  const CrtOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        IgnorePointer(
          child: CustomPaint(
            painter: _CrtPainter(),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _CrtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scanlines — horizontal line every 4px
    final linePaint = Paint()
      ..color = const Color(0x1A001E0A)
      ..strokeWidth = 1.0
      ..blendMode = BlendMode.multiply;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Vignette — radial gradient from transparent center to dark edges
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Colors.transparent,
          const Color(0x55000000),
          const Color(0xAA000000),
        ],
        stops: const [0.5, 0.82, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.multiply;

    canvas.drawRect(rect, vignettePaint);
  }

  @override
  bool shouldRepaint(_CrtPainter oldDelegate) => false;
}
