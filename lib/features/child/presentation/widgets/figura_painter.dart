import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/child_grid_games.dart';

/// Muestra una [FigureSpec] como silueta rellena, aplicándole el giro y el
/// espejo. Las siluetas son asimétricas a propósito: así el espejo o el giro
/// se notan y hay algo que discriminar.
class FiguraView extends StatelessWidget {
  final FigureSpec figura;
  final Color? color;
  const FiguraView({super.key, required this.figura, this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FiguraPainter(figura, color ?? AppTheme.onSurface),
    );
  }
}

class FiguraPainter extends CustomPainter {
  final FigureSpec figura;
  final Color color;
  FiguraPainter(this.figura, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    if (figura.espejada) canvas.scale(-1, 1);
    canvas.rotate(figura.cuartosDeGiro * pi / 2);
    canvas.translate(-size.width / 2, -size.height / 2);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(_path(figura.forma, size), paint);
    canvas.restore();
  }

  /// Todas las formas se definen en coordenadas relativas (0..1) y se escalan
  /// al tamaño de la casilla.
  Path _path(FiguraForma forma, Size s) {
    final w = s.width, h = s.height;
    Offset p(double x, double y) => Offset(x * w, y * h);
    final path = Path();
    switch (forma) {
      case FiguraForma.pez:
        // Pez con la nariz a la derecha y la cola bífida a la izquierda.
        path.moveTo(p(0.90, 0.50).dx, p(0.90, 0.50).dy);
        path.lineTo(p(0.45, 0.22).dx, p(0.45, 0.22).dy);
        path.lineTo(p(0.18, 0.34).dx, p(0.18, 0.34).dy);
        path.lineTo(p(0.32, 0.50).dx, p(0.32, 0.50).dy);
        path.lineTo(p(0.18, 0.66).dx, p(0.18, 0.66).dy);
        path.lineTo(p(0.45, 0.78).dx, p(0.45, 0.78).dy);
        path.close();
      case FiguraForma.banderin:
        // Asta vertical a la izquierda y banderín triangular a la derecha.
        path.addRect(Rect.fromLTRB(p(0.18, 0.10).dx, p(0.18, 0.10).dy,
            p(0.24, 0.90).dx, p(0.24, 0.90).dy));
        path.moveTo(p(0.24, 0.12).dx, p(0.24, 0.12).dy);
        path.lineTo(p(0.82, 0.26).dx, p(0.82, 0.26).dy);
        path.lineTo(p(0.24, 0.40).dx, p(0.24, 0.40).dy);
        path.close();
      case FiguraForma.botita:
        // Bota con la punta a la derecha.
        path.moveTo(p(0.36, 0.15).dx, p(0.36, 0.15).dy);
        path.lineTo(p(0.56, 0.15).dx, p(0.56, 0.15).dy);
        path.lineTo(p(0.56, 0.58).dx, p(0.56, 0.58).dy);
        path.lineTo(p(0.82, 0.58).dx, p(0.82, 0.58).dy);
        path.lineTo(p(0.82, 0.82).dx, p(0.82, 0.82).dy);
        path.lineTo(p(0.36, 0.82).dx, p(0.36, 0.82).dy);
        path.close();
    }
    return path;
  }

  @override
  bool shouldRepaint(FiguraPainter old) =>
      old.figura != figura || old.color != color;
}
