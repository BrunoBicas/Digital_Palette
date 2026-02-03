import '../models/drawing_models.dart';
import '../utils/constants.dart';


class HistoryManager {
  List<List<Layer>> _history = [];
  int _historyIndex = -1;

  int get historyIndex => _historyIndex;
  int get historyLength => _history.length;

  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  // Salva estado atual no histórico
  void saveState(List<Layer> layers) {
    // Remove histórico futuro se estiver no meio
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }

    // Copia as camadas
    List<Layer> layersCopy = layers.map((layer) => layer.copy()).toList();

    _history.add(layersCopy);
    _historyIndex++;

    // Limita o tamanho do histórico
    if (_history.length > AppConstants.maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  // Desfazer
  List<Layer>? undo() {
    if (!canUndo) return null;
    _historyIndex--;
    return _getCurrentState();
  }

  // Refazer
  List<Layer>? redo() {
    if (!canRedo) return null;
    _historyIndex++;
    return _getCurrentState();
  }

  // Obtém estado atual
  List<Layer>? _getCurrentState() {
    if (_historyIndex >= 0 && _historyIndex < _history.length) {
      return _history[_historyIndex].map((layer) => layer.copy()).toList();
    }
    return null;
  }

  // Limpa histórico
  void clear() {
    _history.clear();
    _historyIndex = -1;
  }
}