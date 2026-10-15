import 'dart_throw.dart';
import 'game_config.dart';
import 'player.dart';

/// Une volée (jusqu'à 3 fléchettes) jouée par un joueur.
class Turn {
  final int playerIndex;
  final List<DartThrow> darts;
  final bool bust;

  const Turn({required this.playerIndex, required this.darts, this.bust = false});

  int get total => bust ? 0 : darts.fold(0, (sum, d) => sum + d.score);
}

/// État immuable d'une partie de 301/501.
class GameState {
  final GameConfig config;
  final List<Player> players;

  /// Score restant de chaque joueur (même index que [players]).
  final List<int> scores;
  final int currentPlayerIndex;

  /// Fléchettes de la volée en cours (0 à 2 ; à 3 la volée est validée).
  final List<DartThrow> currentDarts;
  final List<Turn> history;
  final int? winnerIndex;

  const GameState({
    required this.config,
    required this.players,
    required this.scores,
    this.currentPlayerIndex = 0,
    this.currentDarts = const [],
    this.history = const [],
    this.winnerIndex,
  });

  factory GameState.start(GameConfig config, List<Player> players) => GameState(
    config: config,
    players: List.unmodifiable(players),
    scores: List.filled(players.length, config.type.startScore),
  );

  Player get currentPlayer => players[currentPlayerIndex];

  bool get isFinished => winnerIndex != null;

  int get currentTurnTotal => currentDarts.fold(0, (sum, d) => sum + d.score);

  /// Score restant du joueur courant en tenant compte de la volée en cours.
  int get currentRemaining => scores[currentPlayerIndex] - currentTurnTotal;

  GameState copyWith({
    List<int>? scores,
    int? currentPlayerIndex,
    List<DartThrow>? currentDarts,
    List<Turn>? history,
    int? winnerIndex,
  }) => GameState(
    config: config,
    players: players,
    scores: scores ?? this.scores,
    currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
    currentDarts: currentDarts ?? this.currentDarts,
    history: history ?? this.history,
    winnerIndex: winnerIndex ?? this.winnerIndex,
  );
}
