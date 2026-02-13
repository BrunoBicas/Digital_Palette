import 'package:flutter/material.dart';
import '../../models/drawing_models.dart';
import 'layer_item_widget.dart';

class LayersPanelWidget extends StatelessWidget {
  final List<Layer> layers;
  final int currentLayerIndex;
  final VoidCallback onAddLayer;
  final VoidCallback onDeleteLayer;
  final Function(int, int) onReorderLayers;
  final Function(int) onLayerVisibilityChanged;
  final Function(int, double) onLayerOpacityChanged;
  final Function(int) onLayerSelected;
  final Function(int, String) onRenameLayer;
  final Function(int) onToggleGroupExpansion;
  final Function(int) onCreateGroupFromLayer;
  final Function(int) onRemoveLayerFromGroup;

  const LayersPanelWidget({
    super.key,
    required this.layers,
    required this.currentLayerIndex,
    required this.onAddLayer,
    required this.onDeleteLayer,
    required this.onReorderLayers,
    required this.onLayerVisibilityChanged,
    required this.onLayerOpacityChanged,
    required this.onLayerSelected,
    required this.onRenameLayer,
    required this.onToggleGroupExpansion,
    required this.onCreateGroupFromLayer,
    required this.onRemoveLayerFromGroup,
  });

  void _showRenameDialog(BuildContext context, int index) {
    final TextEditingController controller = TextEditingController(
      text: layers[index].name,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
             if (value.isNotEmpty) {
              onRenameLayer(index, value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onRenameLayer(index, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<int> _buildVisibleRealIndexes() {
    final visibleIndexes = <int>[];

    for (int visualIndex = 0; visualIndex < layers.length; visualIndex++) {
      final realIndex = layers.length - 1 - visualIndex;
      final layer = layers[realIndex];

      if (layer.groupId != null && !layer.isGroup) {
        final groupIndex = layers.indexWhere(
          (l) => l.isGroup && l.id.toString() == layer.groupId,
        );
        if (groupIndex != -1 && !layers[groupIndex].isExpanded) {
          continue;
        }
      }
      
      visibleIndexes.add(realIndex);
    }

    return visibleIndexes;
  }

  List<Widget> _buildLayersList(BuildContext context, List<int> visibleRealIndexes) {
    return visibleRealIndexes.map((realIndex) {
      final layer = layers[realIndex];
      final isSelected = realIndex == currentLayerIndex;
      final isInGroup = layer.groupId != null;


      return LayerItemWidget(
        key: ValueKey(layer.id),
        layer: layer,
        index: realIndex,
        isSelected: isSelected,
        isInGroup: isInGroup,
        onVisibilityToggle: () => onLayerVisibilityChanged(realIndex),
        onOpacityChanged: (opacity) => onLayerOpacityChanged(realIndex, opacity),
        onTap: () => onLayerSelected(realIndex),
        onRename: () => _showRenameDialog(context, realIndex),
        onToggleExpand: layer.isGroup ? () => onToggleGroupExpansion(realIndex) : null,
        onCreateGroup: !layer.isGroup && !isInGroup
            ? () => onCreateGroupFromLayer(realIndex)
            : null,
        onRemoveFromGroup: isInGroup && !layer.isGroup
    ? () => onRemoveLayerFromGroup(realIndex)
    : null,
      );

    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleRealIndexes = _buildVisibleRealIndexes();

    return Positioned(
      right: 0,
      top: 60,
      bottom: 0,
      child: Container(
        width: 250,
        color: Colors.grey[850],
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[800],
              child: Row(
                children: [
                  const Text(
                    'CAMADAS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: onAddLayer,
                    tooltip: 'Nova Camada',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: layers.length > 1 ? onDeleteLayer : null,
                    tooltip: 'Excluir',
                  ),
                ],
              ),
            ),            
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Dica: Arraste camadas sobre grupos para adicioná-las',
                style: TextStyle(fontSize: 10, color: Colors.white60),
                textAlign: TextAlign.center,
              ),
            ),            
            Expanded(
              child: ReorderableListView(
                onReorder: (int oldVisualIndex, int newVisualIndex) {
                  if (oldVisualIndex < 0 || oldVisualIndex >= visibleRealIndexes.length) {
                    return;
                  }
                  if (newVisualIndex < 0 || newVisualIndex > visibleRealIndexes.length) {
                    return;
                  }

                  final oldRealIndex = visibleRealIndexes[oldVisualIndex];

                  int adjustedVisualIndex = newVisualIndex;
                  if (newVisualIndex > oldVisualIndex) {
                    adjustedVisualIndex = newVisualIndex - 1;
                  } 

                  if (adjustedVisualIndex < 0) {
                    adjustedVisualIndex = 0;
                  }
                  if (adjustedVisualIndex >= visibleRealIndexes.length) {
                    adjustedVisualIndex = visibleRealIndexes.length - 1;
                  }

                  final newRealIndex = visibleRealIndexes[adjustedVisualIndex];
                  onReorderLayers(oldRealIndex, newRealIndex);
                },
                children: _buildLayersList(context, visibleRealIndexes),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
