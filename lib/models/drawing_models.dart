import 'package:flutter/material.dart';

// Enum para tipos de ferramentas
enum ToolType { brush, eraser, fill }

// Enum para tipos de pincel
enum BrushType { normal, soft, hard, spray }

// Classe que representa uma camada
class Layer {
  String name;
  List<DrawingPoint?> points;
  bool isVisible;
  double opacity;
  int id; // ID único para cada camada
  String? groupId; // ID do grupo (null se não estiver em grupo)
  bool isGroup; // Se é um grupo
  bool isExpanded; // Se o grupo está expandido (apenas para grupos)

  Layer({
    required this.name,
    required this.points,
    required this.id,
    this.isVisible = true,
    this.opacity = 1.0,
    this.groupId,
    this.isGroup = false,
    this.isExpanded = true,
  });

  // Método para copiar a camada
  Layer copy() {
    return Layer(
      name: name,
      points: List.from(points),
      id: id,
      isVisible: isVisible,
      opacity: opacity,
      groupId: groupId,
      isGroup: isGroup,
      isExpanded: isExpanded,
    );
  }
}

// Classe que representa um ponto de desenho
class DrawingPoint {
  Offset offset;
  Paint paint;
  BrushType brushType;
  bool isFillPoint;
  
  DrawingPoint({
    required this.offset,
    required this.paint,
    this.brushType = BrushType.normal,
    this.isFillPoint = false,
  });
}