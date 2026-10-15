enum GameType {
  x301(301),
  x501(501);

  final int startScore;
  const GameType(this.startScore);

  String get label => '$startScore';
}

class GameConfig {
  final GameType type;

  /// Si vrai, la partie doit se terminer sur un double (ou le bull).
  final bool doubleOut;

  const GameConfig({this.type = GameType.x501, this.doubleOut = true});

  GameConfig copyWith({GameType? type, bool? doubleOut}) =>
      GameConfig(type: type ?? this.type, doubleOut: doubleOut ?? this.doubleOut);
}
