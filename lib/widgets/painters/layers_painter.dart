import 'package:flutter/material.dart';
import '../../models/drawing_models.dart';
import '../../utils/paint_utils.dart';

// Pintor que desenha todas as camadas
class LayersPainter extends CustomPainter {
  final List<Layer> layers;

  LayersPainter(this.layers);

  @override
  void paint(Canvas canvas, Size size) {
    // Desenha cada camada em ordem (de baixo para cima)
    for (var layer in layers) {
      if (!layer.isVisible) continue;
      
      // Salva uma camada com opacidade aplicada
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Color.fromRGBO(255, 255, 255, layer.opacity),
      );
      
      final points = layer.points;
      for (int i = 0; i < points.length; i++) {
        if (points[i] == null) continue;
        
        if (i + 1 < points.length && points[i + 1] != null) {
          PaintUtils.drawStroke(canvas, points[i]!, points[i + 1]!);
        } else if (points[i]!.isFillPoint) {
          PaintUtils.drawFill(canvas, size, points[i]!);
        }
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}