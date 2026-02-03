import 'package:flutter/material.dart';
import '../models/drawing_models.dart';

class PaintUtils {
  // Cria um Paint baseado na ferramenta e configurações
  static Paint createPaint({
    required ToolType toolType,
    required Color color,
    required double strokeWidth,
  }) {
    if (toolType == ToolType.eraser) {
      return Paint()
        ..color = Colors.transparent
        ..isAntiAlias = true
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.clear;
    } else {
      return Paint()
        ..color = color
        ..isAntiAlias = true
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
    }
  }

  // Desenha um traço entre dois pontos
  static void drawStroke(Canvas canvas, DrawingPoint p1, DrawingPoint p2) {
    switch (p1.brushType) {
      case BrushType.normal:
        canvas.drawLine(p1.offset, p2.offset, p1.paint);
        break;
      case BrushType.soft:
        final paint = Paint()
          ..color = p1.paint.color
          ..strokeWidth = p1.paint.strokeWidth
          ..strokeCap = StrokeCap.round
          ..blendMode = p1.paint.blendMode
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawLine(p1.offset, p2.offset, paint);
        break;
      case BrushType.hard:
        final paint = Paint()
          ..color = p1.paint.color
          ..strokeWidth = p1.paint.strokeWidth
          ..strokeCap = StrokeCap.square
          ..blendMode = p1.paint.blendMode;
        canvas.drawLine(p1.offset, p2.offset, paint);
        break;
      case BrushType.spray:
        drawSpray(canvas, p1.offset, p1.paint);
        break;
    }
  }

  // Desenha efeito spray
  static void drawSpray(Canvas canvas, Offset center, Paint paint) {
    final random = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < 20; i++) {
      final radius = ((random + i * 7) % 100) / 100 * paint.strokeWidth * 2;
      final offset = Offset(
        center.dx + radius * (((random + i * 13) % 200 - 100) / 100),
        center.dy + radius * (((random + i * 17) % 200 - 100) / 100),
      );
      canvas.drawCircle(offset, 1, paint);
    }
  }

  // Desenha preenchimento
  static void drawFill(Canvas canvas, Size size, DrawingPoint point) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      point.paint,
    );
  }
}