import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class ImageService {
  // Salva a imagem do canvas
  static Future<Uint8List?> saveCanvasAsImage(GlobalKey canvasKey) async {
    try {
      RenderRepaintBoundary boundary = canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao salvar imagem: $e');
      return null;
    }
  }

  // Mostra diálogo de sucesso
  static void showSaveSuccessDialog(
    BuildContext context,
    Uint8List pngBytes,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imagem Pronta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A imagem foi renderizada com sucesso!'),
            const SizedBox(height: 16),
            Text('Tamanho: ${pngBytes.length} bytes'),
            const SizedBox(height: 8),
            const Text(
              'Nota: Em um app completo, aqui seria feito o download do arquivo.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Mostra mensagem de erro
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}