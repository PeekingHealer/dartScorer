import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_config.dart';
import '../models/player.dart';

class SetupState {
  final GameConfig config;
  final List<Player> players;

  const SetupState({this.config = const GameConfig(), this.players = const []});

  SetupState copyWith({GameConfig? config, List<Player>? players}) =>
      SetupState(config: config ?? this.config, players: players ?? this.players);
}

class SetupNotifier extends Notifier<SetupState> {
  final _random = Random();
  int _nextId = 0;

  @override
  SetupState build() => const SetupState();

  void setGameType(GameType type) => state = state.copyWith(config: state.config.copyWith(type: type));

  void setDoubleOut(bool value) => state = state.copyWith(config: state.config.copyWith(doubleOut: value));

  void addPlayer(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final player = Player(id: 'p${_nextId++}', name: trimmed);
    state = state.copyWith(players: [...state.players, player]);
  }

  void removePlayer(String id) => state = state.copyWith(players: state.players.where((p) => p.id != id).toList());

  void reorder(int oldIndex, int newIndex) {
    final players = [...state.players];
    players.insert(newIndex, players.removeAt(oldIndex));
    state = state.copyWith(players: players);
  }

  /// Mélange l'ordre de passage (Fisher-Yates via List.shuffle).
  void shuffle() => state = state.copyWith(players: [...state.players]..shuffle(_random));
}

final setupProvider = NotifierProvider<SetupNotifier, SetupState>(SetupNotifier.new);
