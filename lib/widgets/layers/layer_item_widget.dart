import 'package:flutter/material.dart';
import '../../models/drawing_models.dart';

class LayerItemWidget extends StatelessWidget {
  final Layer layer;
  final int index;
  final bool isSelected;
  final VoidCallback onVisibilityToggle;
  final Function(double) onOpacityChanged;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onCreateGroup;
  final VoidCallback? onRemoveFromGroup;
  final bool isInGroup;

  const LayerItemWidget({
    super.key,
    required this.layer,
    required this.index,
    required this.isSelected,
    required this.onVisibilityToggle,
    required this.onOpacityChanged,
    required this.onTap,
    this.onRename,
    this.onToggleExpand,
    this.onCreateGroup,
    this.onRemoveFromGroup,
    this.isInGroup = false,
  });

  void _showContextMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(200, 100, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Renomear'),
            ],
          ),
        ),
        if (!layer.isGroup && !isInGroup)
          const PopupMenuItem(
            value: 'create_group',
            child: Row(
              children: [
                Icon(Icons.create_new_folder, size: 18),
                SizedBox(width: 8),
                Text('Criar Grupo com Esta Camada'),
              ],
            ),
          ),
        if (isInGroup && !layer.isGroup)
          const PopupMenuItem(
            value: 'remove_from_group',
            child: Row(
              children: [
                Icon(Icons.drive_file_move, size: 18),
                SizedBox(width: 8),
                Text('Remover do Grupo'),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value == 'rename') {
        onRename?.call();
      } else if (value == 'create_group') {
        onCreateGroup?.call();
      } else if (value == 'remove_from_group') {
        onRemoveFromGroup?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isInGroup ? 20 : 8,
        right: 8,
        top: 4,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[700] : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão de expandir/colapsar para grupos
            if (layer.isGroup)
              IconButton(
                icon: Icon(
                  layer.isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                ),
                onPressed: onToggleExpand,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            // Botão de visibilidade
            IconButton(
              icon: Icon(
                layer.isVisible ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: onVisibilityToggle,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        title: Row(
          children: [
            if (layer.isGroup)
              const Icon(Icons.folder, size: 16, color: Colors.amber),
            if (layer.isGroup) const SizedBox(width: 4),
            Expanded(
              child: Text(
                layer.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: layer.isGroup ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // Botão de menu contextual
            IconButton(
              icon: const Icon(Icons.more_vert, size: 16),
              onPressed: () => _showContextMenu(context),
              tooltip: 'Opções',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        trailing: layer.isGroup 
          ? null
          : SizedBox(
              width: 60,
              child: Slider(
                value: layer.opacity,
                min: 0.1,
                max: 1.0,
                onChanged: onOpacityChanged,
              ),
            ),
        onTap: layer.isGroup ? onToggleExpand : onTap,
      ),
    );
  }
}