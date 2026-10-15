import 'package:darts_scorer/logic/x01_engine.dart';
import 'package:darts_scorer/models/dart_throw.dart';
import 'package:darts_scorer/models/game_config.dart';
import 'package:darts_scorer/models/game_state.dart';
import 'package:darts_scorer/models/player.dart';
import 'package:flutter_test/flutter_test.dart';

GameState _game({bool doubleOut = true, List<int>? scores}) {
  final state = GameState.start(GameConfig(type: GameType.x501, doubleOut: doubleOut), const [
    Player(id: 'a', name: 'Alice'),
    Player(id: 'b', name: 'Bob'),
  ]);
  return scores == null ? state : state.copyWith(scores: scores);
}

GameState _throwAll(GameState s, List<DartThrow> darts) => darts.fold(s, X01Engine.throwDart);

void main() {
  test('trois fléchettes décomptent le score et passent au joueur suivant', () {
    final s = _throwAll(_game(), const [DartThrow(20, 3), DartThrow(20, 3), DartThrow(20, 3)]);
    expect(s.scores, [321, 501]);
    expect(s.currentPlayerIndex, 1);
    expect(s.currentDarts, isEmpty);
  });

  test('le joueur reste actif tant que la volée n\'est pas complète', () {
    final s = _throwAll(_game(), const [DartThrow(20, 1), DartThrow(5, 1)]);
    expect(s.currentPlayerIndex, 0);
    expect(s.currentRemaining, 476);
    expect(s.scores[0], 501);
  });

  test('bust si le score passe sous zéro : score restauré', () {
    final s = _throwAll(_game(scores: [40, 501]), const [DartThrow(10, 1), DartThrow(20, 3)]);
    expect(s.scores[0], 40);
    expect(s.currentPlayerIndex, 1);
    expect(s.history.last.bust, isTrue);
  });

  test('double out : finir sur un simple est un bust', () {
    final s = X01Engine.throwDart(_game(scores: [20, 501]), const DartThrow(20, 1));
    expect(s.isFinished, isFalse);
    expect(s.scores[0], 20);
  });

  test('double out : rester à 1 est un bust', () {
    final s = X01Engine.throwDart(_game(scores: [21, 501]), const DartThrow(20, 1));
    expect(s.scores[0], 21);
    expect(s.currentPlayerIndex, 1);
  });

  test('double out : finir sur un double ou le bull gagne', () {
    expect(X01Engine.throwDart(_game(scores: [40, 501]), const DartThrow(20, 2)).winnerIndex, 0);
    expect(X01Engine.throwDart(_game(scores: [50, 501]), const DartThrow(25, 2)).winnerIndex, 0);
  });

  test('sans double out, un simple suffit pour finir', () {
    final s = X01Engine.throwDart(_game(doubleOut: false, scores: [20, 501]), const DartThrow(20, 1));
    expect(s.winnerIndex, 0);
  });
}
