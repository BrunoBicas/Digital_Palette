import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

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

  Layer({
    required this.name,
    required this.points,
    required this.id,
    this.isVisible = true,
    this.opacity = 1.0,
  });
}

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

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  List<Layer> layers = [];
  int currentLayerIndex = 0;
  int _nextLayerId = 1; // Contador de IDs de camadas
  
  List<List<Layer>> history = [];
  int historyIndex = -1;
  
  Color selectedColor = Colors.white;
  double strokeWidth = 4.0;
  ToolType currentTool = ToolType.brush;
  BrushType currentBrush = BrushType.normal;
  bool showLayersPanel = false;

  // Key para capturar o canvas
  final GlobalKey _canvasKey = GlobalKey();

  final List<Color> colorPalette = [
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

  @override
  void initState() {
    super.initState();
    layers.add(Layer(name: 'Camada 1', points: [], id: _nextLayerId++));
    _saveToHistory();
  }

  void _saveToHistory() {
    if (historyIndex < history.length - 1) {
      history = history.sublist(0, historyIndex + 1);
    }
    
    List<Layer> layersCopy = layers.map((layer) => Layer(
      name: layer.name,
      points: List.from(layer.points),
      id: layer.id,
      isVisible: layer.isVisible,
      opacity: layer.opacity,
    )).toList();
    
    history.add(layersCopy);
    historyIndex++;
    
    if (history.length > 50) {
      history.removeAt(0);
      historyIndex--;
    }
  }

  void _undo() {
    if (historyIndex > 0) {
      setState(() {
        historyIndex--;
        _loadHistoryState();
      });
    }
  }

  void _redo() {
    if (historyIndex < history.length - 1) {
      setState(() {
        historyIndex++;
        _loadHistoryState();
      });
    }
  }

  void _loadHistoryState() {
    layers = history[historyIndex].map((layer) => Layer(
      name: layer.name,
      points: List.from(layer.points),
      id: layer.id,
      isVisible: layer.isVisible,
      opacity: layer.opacity,
    )).toList();
    if (currentLayerIndex >= layers.length) {
      currentLayerIndex = layers.length - 1;
    }
  }

  void _addLayer() {
    setState(() {
      layers.add(Layer(
        name: 'Camada ${_nextLayerId}',
        points: [],
        id: _nextLayerId++,
      ));
      currentLayerIndex = layers.length - 1;
      _saveToHistory();
    });
  }

  void _deleteLayer() {
    if (layers.length > 1) {
      setState(() {
        layers.removeAt(currentLayerIndex);
        if (currentLayerIndex >= layers.length) {
          currentLayerIndex = layers.length - 1;
        }
        _saveToHistory();
      });
    }
  }

  Paint _createPaint() {
    if (currentTool == ToolType.eraser) {
      return Paint()
        ..color = Colors.transparent
        ..isAntiAlias = true
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.clear;
    } else {
      return Paint()
        ..color = selectedColor
        ..isAntiAlias = true
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (currentTool == ToolType.fill) return;
    
    setState(() {
      layers[currentLayerIndex].points.add(DrawingPoint(
        offset: details.localPosition,
        paint: _createPaint(),
        brushType: currentBrush,
      ));
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (currentTool == ToolType.fill) return;
    
    setState(() {
      layers[currentLayerIndex].points.add(DrawingPoint(
        offset: details.localPosition,
        paint: _createPaint(),
        brushType: currentBrush,
      ));
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (currentTool == ToolType.fill) return;
    
    setState(() {
      layers[currentLayerIndex].points.add(null);
      _saveToHistory();
    });
  }

  void _handleTap(TapDownDetails details) {
    if (currentTool == ToolType.fill) {
      setState(() {
        // Adiciona um ponto de preenchimento em toda a tela
        layers[currentLayerIndex].points.add(DrawingPoint(
          offset: details.localPosition,
          paint: Paint()
            ..color = selectedColor
            ..style = PaintingStyle.fill,
          brushType: BrushType.normal,
          isFillPoint: true,
        ));
        layers[currentLayerIndex].points.add(null);
        _saveToHistory();
      });
    }
  }

  Future<void> _saveImage() async {
    try {
      RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // Mostra diálogo de sucesso com informações
        if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          // Área de Desenho com RepaintBoundary para captura
          RepaintBoundary(
            key: _canvasKey,
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              onTapDown: _handleTap,
              child: Container(
                color: Colors.grey[900],
                child: CustomPaint(
                  painter: LayersPainter(layers),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // Barra de Ferramentas Lateral Esquerda
          ToolbarWidget(
            currentTool: currentTool,
            currentBrush: currentBrush,
            isEraser: currentTool == ToolType.eraser,
            strokeWidth: strokeWidth,
            selectedColor: selectedColor,
            colorPalette: colorPalette,
            onToolChanged: (tool) => setState(() => currentTool = tool),
            onBrushChanged: (brush) => setState(() => currentBrush = brush),
            onStrokeWidthChanged: (width) => setState(() => strokeWidth = width),
            onColorChanged: (color) => setState(() {
              selectedColor = color;
              currentTool = ToolType.brush;
            }),
          ),

          // Barra Superior
          TopBarWidget(
            historyIndex: historyIndex,
            historyLength: history.length,
            currentLayerIndex: currentLayerIndex,
            showLayersPanel: showLayersPanel,
            onUndo: _undo,
            onRedo: _redo,
            onClearLayer: () {
              setState(() {
                layers[currentLayerIndex].points.clear();
                _saveToHistory();
              });
            },
            onToggleLayersPanel: () => setState(() => showLayersPanel = !showLayersPanel),
            onSave: _saveImage,
          ),

          // Painel de Camadas
          if (showLayersPanel)
            LayersPanelWidget(
              layers: layers,
              currentLayerIndex: currentLayerIndex,
              onAddLayer: _addLayer,
              onDeleteLayer: _deleteLayer,
              onReorderLayers: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final layer = layers.removeAt(oldIndex);
                  layers.insert(newIndex, layer);
                  if (currentLayerIndex == oldIndex) {
                    currentLayerIndex = newIndex;
                  }
                  _saveToHistory();
                });
              },
              onLayerVisibilityChanged: (index) {
                setState(() {
                  layers[index].isVisible = !layers[index].isVisible;
                });
              },
              onLayerOpacityChanged: (index, opacity) {
                setState(() {
                  layers[index].opacity = opacity;
                });
              },
              onLayerSelected: (index) {
                setState(() {
                  currentLayerIndex = index;
                });
              },
            ),
        ],
      ),
    );
  }
}

// Widget da Barra de Ferramentas
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
              
              // Ferramentas
              ToolButton(
                icon: Icons.brush,
                isSelected: currentTool == ToolType.brush,
                onTap: () => onToolChanged(ToolType.brush),
                tooltip: 'Pincel',
              ),
              
              ToolButton(
                icon: Icons.auto_fix_high,
                isSelected: currentTool == ToolType.eraser,
                onTap: () => onToolChanged(ToolType.eraser),
                tooltip: 'Borracha',
              ),
              
              ToolButton(
                icon: Icons.format_color_fill,
                isSelected: currentTool == ToolType.fill,
                onTap: () => onToolChanged(ToolType.fill),
                tooltip: 'Preenchimento',
              ),
              
              const Divider(color: Colors.grey, height: 20),
              
              // Tipos de Pincel
              if (currentTool == ToolType.brush) ...[
                const Text(
                  'PINCEL',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                BrushButton(
                  icon: Icons.circle,
                  isSelected: currentBrush == BrushType.normal,
                  onTap: () => onBrushChanged(BrushType.normal),
                  tooltip: 'Normal',
                ),
                BrushButton(
                  icon: Icons.blur_on,
                  isSelected: currentBrush == BrushType.soft,
                  onTap: () => onBrushChanged(BrushType.soft),
                  tooltip: 'Suave',
                ),
                BrushButton(
                  icon: Icons.lens,
                  isSelected: currentBrush == BrushType.hard,
                  onTap: () => onBrushChanged(BrushType.hard),
                  tooltip: 'Duro',
                ),
                BrushButton(
                  icon: Icons.grain,
                  isSelected: currentBrush == BrushType.spray,
                  onTap: () => onBrushChanged(BrushType.spray),
                  tooltip: 'Spray',
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
              
              // Paleta de Cores
              ...colorPalette.map((color) => ColorButton(
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

// Widget Botão de Ferramenta
class ToolButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  const ToolButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[700] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

// Widget Botão de Pincel
class BrushButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  const BrushButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[700] : Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// Widget Botão de Cor
class ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorButton({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[700]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color.fromRGBO(
                (color.r * 255.0).round().clamp(0, 255),
                (color.g * 255.0).round().clamp(0, 255),
                (color.b * 255.0).round().clamp(0, 255),
                0.5,
              ),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : null,
        ),
      ),
    );
  }
}

// Widget Barra Superior
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

// Widget Painel de Camadas
class LayersPanelWidget extends StatelessWidget {
  final List<Layer> layers;
  final int currentLayerIndex;
  final VoidCallback onAddLayer;
  final VoidCallback onDeleteLayer;
  final Function(int, int) onReorderLayers;
  final Function(int) onLayerVisibilityChanged;
  final Function(int, double) onLayerOpacityChanged;
  final Function(int) onLayerSelected;

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
  });

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
                    tooltip: 'Excluir Camada',
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ReorderableListView.builder(
                itemCount: layers.length,
                onReorder: onReorderLayers,
                itemBuilder: (context, index) {
                  final reversedIndex = layers.length - 1 - index;
                  final layer = layers[reversedIndex];
                  final isSelected = reversedIndex == currentLayerIndex;
                  
                  return LayerItemWidget(
                    key: ValueKey(layer.id), // Usa ID único da camada
                    layer: layer,
                    index: reversedIndex,
                    isSelected: isSelected,
                    onVisibilityToggle: () => onLayerVisibilityChanged(reversedIndex),
                    onOpacityChanged: (opacity) => onLayerOpacityChanged(reversedIndex, opacity),
                    onTap: () => onLayerSelected(reversedIndex),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Item de Camada
class LayerItemWidget extends StatelessWidget {
  final Layer layer;
  final int index;
  final bool isSelected;
  final VoidCallback onVisibilityToggle;
  final Function(double) onOpacityChanged;
  final VoidCallback onTap;

  const LayerItemWidget({
    super.key,
    required this.layer,
    required this.index,
    required this.isSelected,
    required this.onVisibilityToggle,
    required this.onOpacityChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        leading: IconButton(
          icon: Icon(
            layer.isVisible ? Icons.visibility : Icons.visibility_off,
            size: 20,
          ),
          onPressed: onVisibilityToggle,
        ),
        title: Text(
          layer.name,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: SizedBox(
          width: 60,
          child: Slider(
            value: layer.opacity,
            min: 0.1,
            max: 1.0,
            onChanged: onOpacityChanged,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// Pintor que desenha todas as camadas
class LayersPainter extends CustomPainter {
  final List<Layer> layers;

  LayersPainter(this.layers);

  @override
  void paint(Canvas canvas, Size size) {
    // Desenha cada camada em ordem (de baixo para cima)
    for (var layer in layers) {
      if (!layer.isVisible) continue;
      
      // Aplica opacidade da camada se necessário
      if (layer.opacity < 1.0) {
        canvas.saveLayer(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = Color.fromRGBO(255, 255, 255, layer.opacity),
        );
      }
      
      final points = layer.points;
      for (int i = 0; i < points.length; i++) {
        if (points[i] == null) continue;
        
        if (i + 1 < points.length && points[i + 1] != null) {
          _drawStroke(canvas, points[i]!, points[i + 1]!);
        } else if (points[i]!.isFillPoint) {
          _drawFill(canvas, size, points[i]!);
        }
      }
      
      if (layer.opacity < 1.0) {
        canvas.restore();
      }
    }
  }

  void _drawStroke(Canvas canvas, DrawingPoint p1, DrawingPoint p2) {
    switch (p1.brushType) {
      case BrushType.normal:
        canvas.drawLine(p1.offset, p2.offset, p1.paint);
        break;
      case BrushType.soft:
        final paint = Paint()
          ..color = p1.paint.color
          ..strokeWidth = p1.paint.strokeWidth
          ..strokeCap = StrokeCap.round
          ..blendMode = p1.paint.blendMode
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawLine(p1.offset, p2.offset, paint);
        break;
      case BrushType.hard:
        final paint = Paint()
          ..color = p1.paint.color
          ..strokeWidth = p1.paint.strokeWidth
          ..strokeCap = StrokeCap.square
          ..blendMode = p1.paint.blendMode;
        canvas.drawLine(p1.offset, p2.offset, paint);
        break;
      case BrushType.spray:
        _drawSpray(canvas, p1.offset, p1.paint);
        break;
    }
  }

  void _drawFill(Canvas canvas, Size size, DrawingPoint point) {
    // Preenche toda a área visível com a cor
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      point.paint,
    );
  }

  void _drawSpray(Canvas canvas, Offset center, Paint paint) {
    final random = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < 20; i++) {
      final radius = ((random + i * 7) % 100) / 100 * paint.strokeWidth * 2;
      final offset = Offset(
        center.dx + radius * (((random + i * 13) % 200 - 100) / 100),
        center.dy + radius * (((random + i * 17) % 200 - 100) / 100),
      );
      canvas.drawCircle(offset, 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}