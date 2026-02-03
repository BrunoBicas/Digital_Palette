import 'package:flutter/material.dart';

class AppConstants {
  // Cores da paleta
  static final List<Color> colorPalette = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];

  // Configurações padrão
  static const double defaultStrokeWidth = 4.0;
  static const double minStrokeWidth = 1.0;
  static const double maxStrokeWidth = 30.0;
  static const int maxHistorySize = 50;

  // Dimensões da interface
  static const double toolbarWidth = 70.0;
  static const double layersPanelWidth = 250.0;
  static const double topBarHeight = 60.0;

  // Cores da interface
  static Color get backgroundColor => Colors.grey[900]!;
  static Color get toolbarColor => Colors.grey[850]!;
  static Color get selectedColor => Colors.blue[700]!;
}