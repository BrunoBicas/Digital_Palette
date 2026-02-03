import '../models/drawing_models.dart';

class LayerManager {
  List<Layer> layers = [];
  int currentLayerIndex = 0;
  int _nextLayerId = 1;

  LayerManager() {
    addLayer();
  }

  // Adiciona uma nova camada
  void addLayer({String? groupId}) {
    layers.add(Layer(
      name: 'Camada $_nextLayerId',
      points: [],
      id: _nextLayerId++,
      groupId: groupId,
    ));
    currentLayerIndex = layers.length - 1;
  }

  // Cria um grupo a partir de uma camada existente
  void createGroupFromLayer(int layerIndex) {
    if (layerIndex < 0 || layerIndex >= layers.length) return;
    if (layers[layerIndex].isGroup) return; // Não criar grupo de grupo
    if (layers[layerIndex].groupId != null) return; // Já está em grupo
    
    final layer = layers[layerIndex];
    final groupId = _nextLayerId++;
    
    // Criar o grupo
    final group = Layer(
      name: 'Grupo ${layer.name}',
      points: [],
      id: groupId,
      isGroup: true,
      isExpanded: true,
    );
    
    // Adicionar a camada ao grupo
    layer.groupId = groupId.toString();
    
    // Inserir o grupo na posição acima da camada
    layers.insert(layerIndex + 1, group);
    
    // Atualizar currentLayerIndex se necessário
    if (currentLayerIndex >= layerIndex + 1) {
      currentLayerIndex++;
    }
  }

  // Adiciona camada a um grupo (quando arrasta)
  void addLayerToGroup(int layerIndex, int groupIndex) {
    if (layerIndex < 0 || layerIndex >= layers.length) return;
    if (groupIndex < 0 || groupIndex >= layers.length) return;
    if (!layers[groupIndex].isGroup) return;
    if (layers[layerIndex].isGroup) return; // Não adicionar grupo em grupo
    
    final groupId = layers[groupIndex].id.toString();
    layers[layerIndex].groupId = groupId;
  }

  // Remove camada de um grupo
  void removeLayerFromGroup(int layerIndex) {
    if (layerIndex >= 0 && layerIndex < layers.length) {
      final oldGroupId = layers[layerIndex].groupId;
      layers[layerIndex].groupId = null;
      
      // Se o grupo ficou vazio, remove o grupo
      if (oldGroupId != null) {
        final hasLayersInGroup = layers.any((l) => 
          l.groupId == oldGroupId && !l.isGroup
        );
        
        if (!hasLayersInGroup) {
          final groupIndex = layers.indexWhere((l) => 
            l.isGroup && l.id.toString() == oldGroupId
          );
          if (groupIndex != -1) {
            layers.removeAt(groupIndex);
            if (currentLayerIndex >= groupIndex) {
              currentLayerIndex = (currentLayerIndex - 1).clamp(0, layers.length - 1);
            }
          }
        }
      }
    }
  }

  // Renomeia uma camada ou grupo
  void renameLayer(int index, String newName) {
    if (index >= 0 && index < layers.length && newName.isNotEmpty) {
      layers[index].name = newName;
    }
  }

  // Toggle expansão do grupo
  void toggleGroupExpansion(int index) {
    if (index >= 0 && index < layers.length && layers[index].isGroup) {
      layers[index].isExpanded = !layers[index].isExpanded;
    }
  }

  // Verifica se pode adicionar camada ao grupo (ao arrastar)
  bool canAddToGroup(int layerIndex, int targetIndex) {
    if (layerIndex < 0 || layerIndex >= layers.length) return false;
    if (targetIndex < 0 || targetIndex >= layers.length) return false;
    if (layers[layerIndex].isGroup) return false; // Grupo não pode entrar em grupo
    if (!layers[targetIndex].isGroup) return false; // Target deve ser grupo
    
    return true;
  }

  // Verifica se uma camada está em um grupo
  bool isInGroup(int index) {
    if (index >= 0 && index < layers.length) {
      return layers[index].groupId != null;
    }
    return false;
  }

  // Remove a camada atual
  bool deleteCurrentLayer() {
    if (layers.length <= 1) return false;
    
    final layerToDelete = layers[currentLayerIndex];
    
    // Se for um grupo, remove também as camadas do grupo
    if (layerToDelete.isGroup) {
      final groupId = layerToDelete.id.toString();
      layers.removeWhere((layer) => layer.groupId == groupId);
    }
    
    layers.removeAt(currentLayerIndex);
    if (currentLayerIndex >= layers.length) {
      currentLayerIndex = layers.length - 1;
    }
    return true;
  }

  // Limpa os pontos da camada atual
  void clearCurrentLayer() {
    if (currentLayerIndex < layers.length && !layers[currentLayerIndex].isGroup) {
      layers[currentLayerIndex].points.clear();
    }
  }

  // Reordena as camadas com suporte a grupos
  void reorderLayers(int oldIndex, int newIndex) {
    // Validação de índices
    if (oldIndex < 0 || oldIndex >= layers.length) return;
    if (newIndex < 0 || newIndex >= layers.length) return;
    if (oldIndex == newIndex) return;
    
    final movingLayer = layers[oldIndex];
    
    // Verificar se está tentando adicionar a um grupo
    if (!movingLayer.isGroup && layers[newIndex].isGroup) {
      // Adicionar ao grupo
      addLayerToGroup(oldIndex, newIndex);
      return;
    }
    
    // Reordenação normal
    final layer = layers.removeAt(oldIndex);
    layers.insert(newIndex, layer);
    
    // Atualiza o índice da camada atual
    if (currentLayerIndex == oldIndex) {
      currentLayerIndex = newIndex;
    } else if (oldIndex < currentLayerIndex && newIndex >= currentLayerIndex) {
      currentLayerIndex--;
    } else if (oldIndex > currentLayerIndex && newIndex <= currentLayerIndex) {
      currentLayerIndex++;
    }
    
    currentLayerIndex = currentLayerIndex.clamp(0, layers.length - 1);
  }

  // Alterna visibilidade da camada
  void toggleLayerVisibility(int index) {
    if (index >= 0 && index < layers.length) {
      final layer = layers[index];
      layer.isVisible = !layer.isVisible;
      
      // Se for um grupo, alterna visibilidade de todas as camadas do grupo
      if (layer.isGroup) {
        final groupId = layer.id.toString();
        for (var l in layers) {
          if (l.groupId == groupId) {
            l.isVisible = layer.isVisible;
          }
        }
      }
    }
  }

  // Define opacidade da camada
  void setLayerOpacity(int index, double opacity) {
    if (index >= 0 && index < layers.length) {
      layers[index].opacity = opacity;
    }
  }

  // Seleciona uma camada
  void selectLayer(int index) {
    if (index >= 0 && index < layers.length) {
      // Não permite selecionar grupos, apenas camadas
      if (!layers[index].isGroup) {
        currentLayerIndex = index;
      }
    }
  }

  // Obtém a camada atual
  Layer get currentLayer => layers[currentLayerIndex];

  // Cria cópia de todas as camadas
  List<Layer> copyLayers() {
    return layers.map((layer) => layer.copy()).toList();
  }

  // Carrega estado das camadas
  void loadLayers(List<Layer> newLayers) {
    layers = newLayers.map((layer) => layer.copy()).toList();
    if (currentLayerIndex >= layers.length) {
      currentLayerIndex = layers.length - 1;
    }
  }
}