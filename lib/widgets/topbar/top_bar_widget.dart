import 'package:flutter/material.dart';

class TopBarWidget extends StatelessWidget {
  final int historyIndex;
  final int historyLength;
  final int currentLayerIndex;
  final bool showLayersPanel;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClearLayer;
  final VoidCallback onToggleLayersPanel;
  final VoidCallback onSave;

  const TopBarWidget({
    super.key,
    required this.historyIndex,
    required this.historyLength,
    required this.currentLayerIndex,
    required this.showLayersPanel,
    required this.onUndo,
    required this.onRedo,
    required this.onClearLayer,
    required this.onToggleLayersPanel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 70,
      right: showLayersPanel ? 250 : 0,
      top: 0,
      child: Container(
        height: 60,
        color: Colors.grey[850],
        child: Row(
          children: [
            const SizedBox(width: 20),
            
            IconButton(
              icon: Icon(
                Icons.undo,
                color: historyIndex > 0 ? Colors.white : Colors.grey[600],
              ),
              onPressed: historyIndex > 0 ? onUndo : null,
              tooltip: 'Desfazer',
            ),
            
            IconButton(
              icon: Icon(
                Icons.redo,
                color: historyIndex < historyLength - 1 ? Colors.white : Colors.grey[600],
              ),
              onPressed: historyIndex < historyLength - 1 ? onRedo : null,
              tooltip: 'Refazer',
            ),
            
            const VerticalDivider(),
            
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: onClearLayer,
              tooltip: 'Limpar Camada',
            ),
            
            IconButton(
              icon: const Icon(Icons.save, color: Colors.green),
              onPressed: onSave,
              tooltip: 'Salvar Imagem',
            ),
            
            const Spacer(),
            
            TextButton.icon(
              icon: const Icon(Icons.layers),
              label: Text('Camada ${currentLayerIndex + 1}'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: onToggleLayersPanel,
            ),
            
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}