import 'package:flutter/material.dart';
import '../models/drawing_models.dart';
import '../services/layer_manager.dart';
import '../services/history_manager.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';
import '../utils/paint_utils.dart';
import '../widgets/painters/layers_painter.dart';
import '../widgets/toolbar/toolbar_widget.dart';
import '../widgets/topbar/top_bar_widget.dart';
import '../widgets/layers/layers_panel_widget.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  // Gerenciadores
  late LayerManager layerManager;
  late HistoryManager historyManager;
  
  // Configurações de desenho
  Color selectedColor = Colors.white;
  double strokeWidth = AppConstants.defaultStrokeWidth;
  ToolType currentTool = ToolType.brush;
  BrushType currentBrush = BrushType.normal;
  bool showLayersPanel = false;

  // Key para capturar o canvas
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    layerManager = LayerManager();
    historyManager = HistoryManager();
    historyManager.saveState(layerManager.layers);
  }

  // ========== MÉTODOS DE HISTÓRICO ==========
  
  void _saveToHistory() {
    historyManager.saveState(layerManager.layers);
  }

  void _undo() {
    final layers = historyManager.undo();
    if (layers != null) {
      setState(() {
        layerManager.loadLayers(layers);
      });
    }
  }

  void _redo() {
    final layers = historyManager.redo();
    if (layers != null) {
      setState(() {
        layerManager.loadLayers(layers);
      });
    }
  }

  // ========== MÉTODOS DE CAMADAS ==========
  
  void _addLayer() {
    setState(() {
      layerManager.addLayer();
      _saveToHistory();
    });
  }

  void _deleteLayer() {
    setState(() {
      if (layerManager.deleteCurrentLayer()) {
        _saveToHistory();
      }
    });
  }

  void _renameLayer(int index, String newName) {
    setState(() {
      layerManager.renameLayer(index, newName);
      _saveToHistory();
    });
  }

  void _toggleGroupExpansion(int index) {
    setState(() {
      layerManager.toggleGroupExpansion(index);
      // Não salva no histórico para expansão de grupo
    });
  }

  void _createGroupFromLayer(int index) {
    setState(() {
      layerManager.createGroupFromLayer(index);
      _saveToHistory();
    });
  }

  void _removeLayerFromGroup(int index) {
    setState(() {
      layerManager.removeLayerFromGroup(index);
      _saveToHistory();
    });
  }

  void _clearCurrentLayer() {
    setState(() {
      layerManager.clearCurrentLayer();
      _saveToHistory();
    });
  }

  // ========== MÉTODOS DE DESENHO ==========
  
  Paint _createPaint() {
    return PaintUtils.createPaint(
      toolType: currentTool,
      color: selectedColor,
      strokeWidth: strokeWidth,
    );
  }

  void _handlePanStart(DragStartDetails details) {
    if (currentTool == ToolType.fill) return;
    
    setState(() {
      layerManager.currentLayer.points.add(DrawingPoint(
        offset: details.localPosition,
        paint: _createPaint(),
        brushType: currentBrush,
      ));
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (currentTool == ToolType.fill) return;
    
    setState(() {
      layerManager.currentLayer.points.add(DrawingPoint(
        offset: details.localPosition,
        paint: _createPaint(),
        brushType: currentBrush,
      ));
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (currentTool == ToolType.fill) return;
    
    setState(() {
      layerManager.currentLayer.points.add(null);
      _saveToHistory();
    });
  }

  void _handleTap(TapDownDetails details) {
    if (currentTool == ToolType.fill) {
      setState(() {
        layerManager.currentLayer.points.add(DrawingPoint(
          offset: details.localPosition,
          paint: Paint()
            ..color = selectedColor
            ..style = PaintingStyle.fill,
          brushType: BrushType.normal,
          isFillPoint: true,
        ));
        layerManager.currentLayer.points.add(null);
        _saveToHistory();
      });
    }
  }

  // ========== SALVAR IMAGEM ==========
  
  Future<void> _saveImage() async {
    final pngBytes = await ImageService.saveCanvasAsImage(_canvasKey);
    
    if (pngBytes != null && mounted) {
      ImageService.showSaveSuccessDialog(context, pngBytes);
    } else if (mounted) {
      ImageService.showErrorMessage(context, 'Erro ao salvar imagem');
    }
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Área de Desenho
          RepaintBoundary(
            key: _canvasKey,
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              onTapDown: _handleTap,
              child: Container(
                color: AppConstants.backgroundColor,
                child: CustomPaint(
                  painter: LayersPainter(layerManager.layers),
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
            colorPalette: AppConstants.colorPalette,
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
            historyIndex: historyManager.historyIndex,
            historyLength: historyManager.historyLength,
            currentLayerIndex: layerManager.currentLayerDisplayIndex,
            showLayersPanel: showLayersPanel,
            onUndo: _undo,
            onRedo: _redo,
            onClearLayer: _clearCurrentLayer,
            onToggleLayersPanel: () => setState(() => showLayersPanel = !showLayersPanel),
            onSave: _saveImage,
          ),

          // Painel de Camadas
          if (showLayersPanel)
            LayersPanelWidget(
              layers: layerManager.layers,
              currentLayerIndex: layerManager.currentLayerIndex,
              onAddLayer: _addLayer,
              onDeleteLayer: _deleteLayer,
              onReorderLayers: (oldIndex, newIndex) {
                setState(() {
                  layerManager.reorderLayers(oldIndex, newIndex);
                  _saveToHistory();
                });
              },
              onLayerVisibilityChanged: (index) {
                setState(() {
                  layerManager.toggleLayerVisibility(index);
                  // Não salva no histórico para mudanças de visibilidade
                });
              },
              onLayerOpacityChanged: (index, opacity) {
                setState(() {
                  layerManager.setLayerOpacity(index, opacity);
                  // Não salva no histórico para mudanças de opacidade
                });
              },
              onLayerSelected: (index) {
                setState(() {
                  layerManager.selectLayer(index);
                  // Não salva no histórico ao selecionar camada
                });
              },
              onRenameLayer: _renameLayer,
              onToggleGroupExpansion: _toggleGroupExpansion,
              onCreateGroupFromLayer: _createGroupFromLayer,
              onRemoveLayerFromGroup: _removeLayerFromGroup,
            ),
        ],
      ),
    );
  }
}