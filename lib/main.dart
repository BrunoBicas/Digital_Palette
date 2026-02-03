
import 'package:flutter/material.dart';
import 'screens/canvas_screen.dart';

void main() {
  runApp(const PhotoTabletApp());
}

class PhotoTabletApp extends StatelessWidget {
  const PhotoTabletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CanvasScreen(),
    );
  }
}