import '../models/dart_throw.dart';
import '../models/game_state.dart';

/// Règles du 301 / 501. Fonctions pures : un état entre, un nouvel état sort.
class X01Engine {
  const X01Engine._();

  static const dartsPerTurn = 3;

  static GameState throwDart(GameState state, DartThrow dart) {
    if (state.isFinished) return state;

    final darts = [...state.currentDarts, dart];
    final remaining = state.currentRemaining - dart.score;

    if (_isBust(state, remaining, dart)) {
      return _endTurn(state, darts, bust: true);
    }

    if (remaining == 0) {
      final scores = [...state.scores]..[state.currentPlayerIndex] = 0;
      return state.copyWith(
        scores: scores,
        currentDarts: const [],
        history: [
          ...state.history,
          Turn(playerIndex: state.currentPlayerIndex, darts: darts),
        ],
        winnerIndex: state.currentPlayerIndex,
      );
    }

    if (darts.length == dartsPerTurn) {
      return _endTurn(state, darts);
    }

    return state.copyWith(currentDarts: darts);
  }

  static bool _isBust(GameState state, int remaining, DartThrow lastDart) {
    if (remaining < 0) return true;
    if (state.config.doubleOut) {
      if (remaining == 1) return true;
      if (remaining == 0 && !lastDart.isDouble) return true;
    }
    return false;
  }

  /// Valide la volée (ou l'annule en cas de bust) et passe au joueur suivant.
  static GameState _endTurn(GameState state, List<DartThrow> darts, {bool bust = false}) {
    final turn = Turn(playerIndex: state.currentPlayerIndex, darts: darts, bust: bust);
    final scores = [...state.scores];
    if (!bust) scores[state.currentPlayerIndex] -= turn.total;

    return state.copyWith(
      scores: scores,
      currentPlayerIndex: (state.currentPlayerIndex + 1) % state.players.length,
      currentDarts: const [],
      history: [...state.history, turn],
    );
  }
}
