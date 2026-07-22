import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CircuitBackground extends StatelessWidget {
  const CircuitBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _CircuitPainter()),
    );
  }
}

class _CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final dot = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    void line(List<Offset> pts) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
      canvas.drawPath(path, paint);
      for (final p in pts) canvas.drawCircle(p, 3, dot);
    }

    line([Offset(0, size.height * 0.08), Offset(size.width * 0.15, size.height * 0.08), Offset(size.width * 0.15, size.height * 0.05), Offset(size.width * 0.3, size.height * 0.05)]);
    line([Offset(size.width * 0.05, 0), Offset(size.width * 0.05, size.height * 0.12), Offset(size.width * 0.1, size.height * 0.12)]);
    line([Offset(size.width * 0.6, 0), Offset(size.width * 0.6, size.height * 0.06), Offset(size.width * 0.75, size.height * 0.06), Offset(size.width * 0.75, size.height * 0.02), Offset(size.width, size.height * 0.02)]);
    line([Offset(size.width * 0.85, 0), Offset(size.width * 0.85, size.height * 0.1), Offset(size.width, size.height * 0.1)]);
    line([Offset(0, size.height * 0.9), Offset(size.width * 0.2, size.height * 0.9), Offset(size.width * 0.2, size.height * 0.95), Offset(size.width * 0.4, size.height * 0.95)]);
    line([Offset(size.width * 0.7, size.height), Offset(size.width * 0.7, size.height * 0.94), Offset(size.width * 0.9, size.height * 0.94), Offset(size.width * 0.9, size.height * 0.97)]);

    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 4; j++) {
        canvas.drawCircle(Offset(size.width * 0.65 + i * 10, size.height * 0.03 + j * 10), 1.5, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
