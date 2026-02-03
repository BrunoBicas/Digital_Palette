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

  List<Widget> _buildLayersList(BuildContext context) {
    List<Widget> widgets = [];
    
    for (int visualIndex = 0; visualIndex < layers.length; visualIndex++) {
      final realIndex = layers.length - 1 - visualIndex;
      final layer = layers[realIndex];
      
      // Se a camada está em um grupo e o grupo não está expandido, pula
      if (layer.groupId != null && !layer.isGroup) {
        final groupIndex = layers.indexWhere((l) => 
          l.isGroup && l.id.toString() == layer.groupId
        );
        if (groupIndex != -1 && !layers[groupIndex].isExpanded) {
          continue;
        }
      }
      
      final isSelected = realIndex == currentLayerIndex;
      final isInGroup = layer.groupId != null;
      
      widgets.add(
        LayerItemWidget(
          key: ValueKey(layer.id),
          layer: layer,
          index: realIndex,
          isSelected: isSelected,
          isInGroup: isInGroup,
          onVisibilityToggle: () => onLayerVisibilityChanged(realIndex),
          onOpacityChanged: (opacity) => onLayerOpacityChanged(realIndex, opacity),
          onTap: () => onLayerSelected(realIndex),
          onRename: () => _showRenameDialog(context, realIndex),
          onToggleExpand: layer.isGroup 
            ? () => onToggleGroupExpansion(realIndex)
            : null,
          onCreateGroup: !layer.isGroup && !isInGroup
            ? () => onCreateGroupFromLayer(realIndex)
            : null,
          onRemoveFromGroup: isInGroup && !layer.isGroup
            ? () => onRemoveLayerFromGroup(realIndex)
            : null,
        ),
      );
    }
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
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
                  // Validação básica
                  if (oldVisualIndex < 0 || oldVisualIndex >= layers.length) return;
                  if (newVisualIndex < 0 || newVisualIndex > layers.length) return;
                  
                  // Converter índices visuais (invertidos) para índices reais
                  final oldRealIndex = layers.length - 1 - oldVisualIndex;
                  
                  // Ajustar newVisualIndex de acordo com o padrão do ReorderableListView
                  int adjustedVisualIndex = newVisualIndex;
                  if (newVisualIndex > oldVisualIndex) {
                    adjustedVisualIndex = newVisualIndex - 1;
                  }
                  
                  // Converter para índice real
                  final newRealIndex = layers.length - 1 - adjustedVisualIndex;
                  
                  // Validação final
                  if (newRealIndex < 0 || newRealIndex >= layers.length) return;
                  
                  onReorderLayers(oldRealIndex, newRealIndex);
                },
                children: _buildLayersList(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}