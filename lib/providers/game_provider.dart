import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/x01_engine.dart';
import '../models/dart_throw.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';
import '../models/player.dart';

class GameNotifier extends Notifier<GameState?> {
  final List<GameState> _undoStack = [];

  @override
  GameState? build() => null;

  void start(GameConfig config, List<Player> players) {
    _undoStack.clear();
    state = GameState.start(config, players);
  }

  void throwDart(DartThrow dart) {
    final current = state;
    if (current == null || current.isFinished) return;
    _undoStack.add(current);
    state = X01Engine.throwDart(current, dart);
  }

  bool get canUndo => _undoStack.isNotEmpty;

  /// Annule la dernière fléchette saisie (y compris à travers un changement de joueur).
  void undo() {
    if (_undoStack.isEmpty) return;
    state = _undoStack.removeLast();
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState?>(GameNotifier.new);
