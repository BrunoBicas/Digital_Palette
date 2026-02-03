import 'package:flutter/material.dart';
import '../../models/drawing_models.dart';
import '../common/icon_button_widget.dart';
import '../common/circle_button_widget.dart';

class ToolbarWidget extends StatelessWidget {
  final ToolType currentTool;
  final BrushType currentBrush;
  final bool isEraser;
  final double strokeWidth;
  final Color selectedColor;
  final List<Color> colorPalette;
  final Function(ToolType) onToolChanged;
  final Function(BrushType) onBrushChanged;
  final Function(double) onStrokeWidthChanged;
  final Function(Color) onColorChanged;

  const ToolbarWidget({
    super.key,
    required this.currentTool,
    required this.currentBrush,
    required this.isEraser,
    required this.strokeWidth,
    required this.selectedColor,
    required this.colorPalette,
    required this.onToolChanged,
    required this.onBrushChanged,
    required this.onStrokeWidthChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 70,
        color: Colors.grey[850],
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Ferramentas - Usando componente genérico
              IconButtonWidget(
                icon: Icons.brush,
                isSelected: currentTool == ToolType.brush,
                onTap: () => onToolChanged(ToolType.brush),
                tooltip: 'Pincel',
              ),
              
              IconButtonWidget(
                icon: Icons.auto_fix_high,
                isSelected: currentTool == ToolType.eraser,
                onTap: () => onToolChanged(ToolType.eraser),
                tooltip: 'Borracha',
              ),
              
              IconButtonWidget(
                icon: Icons.format_color_fill,
                isSelected: currentTool == ToolType.fill,
                onTap: () => onToolChanged(ToolType.fill),
                tooltip: 'Preenchimento',
              ),
              
              const Divider(color: Colors.grey, height: 20),
              
              // Tipos de Pincel - Usando componente genérico
              if (currentTool == ToolType.brush) ...[
                const Text(
                  'PINCEL',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                
                IconButtonWidget(
                  icon: Icons.circle,
                  isSelected: currentBrush == BrushType.normal,
                  onTap: () => onBrushChanged(BrushType.normal),
                  tooltip: 'Normal',
                  size: 40,
                  iconSize: 20,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  borderRadius: 6,
                  backgroundColor: Colors.grey[800],
                ),
                
                IconButtonWidget(
                  icon: Icons.blur_on,
                  isSelected: currentBrush == BrushType.soft,
                  onTap: () => onBrushChanged(BrushType.soft),
                  tooltip: 'Suave',
                  size: 40,
                  iconSize: 20,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  borderRadius: 6,
                  backgroundColor: Colors.grey[800],
                ),
                
                IconButtonWidget(
                  icon: Icons.lens,
                  isSelected: currentBrush == BrushType.hard,
                  onTap: () => onBrushChanged(BrushType.hard),
                  tooltip: 'Duro',
                  size: 40,
                  iconSize: 20,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  borderRadius: 6,
                  backgroundColor: Colors.grey[800],
                ),
                
                IconButtonWidget(
                  icon: Icons.grain,
                  isSelected: currentBrush == BrushType.spray,
                  onTap: () => onBrushChanged(BrushType.spray),
                  tooltip: 'Spray',
                  size: 40,
                  iconSize: 20,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  borderRadius: 6,
                  backgroundColor: Colors.grey[800],
                ),
                
                const Divider(color: Colors.grey, height: 20),
              ],
              
              // Controle de Espessura
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const Icon(Icons.line_weight, color: Colors.white70, size: 20),
                    RotatedBox(
                      quarterTurns: 3,
                      child: SizedBox(
                        width: 120,
                        child: Slider(
                          value: strokeWidth,
                          min: 1,
                          max: 30,
                          activeColor: Colors.grey,
                          onChanged: onStrokeWidthChanged,
                        ),
                      ),
                    ),
                    Text(
                      '${strokeWidth.toInt()}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.grey, height: 20),
              
              // Paleta de Cores - Usando componente genérico
              ...colorPalette.map((color) => CircleButtonWidget(
                color: color,
                isSelected: selectedColor == color && !isEraser,
                onTap: () => onColorChanged(color),
              )),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}