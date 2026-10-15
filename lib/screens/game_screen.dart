import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/x01_engine.dart';
import '../models/dart_throw.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/dartboard.dart';
import '../widgets/score_keypad.dart';

enum InputMode { board, keypad }

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  InputMode _inputMode = InputMode.board;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    ref.listen(gameProvider, (previous, next) {
      if (next != null && next.isFinished && !(previous?.isFinished ?? false)) {
        _showWinner(context, next);
      }
      final lastTurn = next?.history.lastOrNull;
      if (lastTurn != null && lastTurn.bust && previous?.history.length != next!.history.length) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Bust ! ${next.players[lastTurn.playerIndex].name} ne marque rien.')));
      }
    });

    if (game == null) return const Scaffold(body: Center(child: Text('Aucune partie en cours')));

    return Scaffold(
      appBar: AppBar(
        title: Text('${game.config.type.label}${game.config.doubleOut ? ' · Double out' : ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Annuler la dernière fléchette',
            onPressed: notifier.canUndo ? notifier.undo : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Scoreboard(game: game),
            _CurrentTurn(game: game),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SegmentedButton<InputMode>(
                segments: const [
                  ButtonSegment(value: InputMode.board, icon: Icon(Icons.track_changes), label: Text('Cible')),
                  ButtonSegment(value: InputMode.keypad, icon: Icon(Icons.dialpad), label: Text('Pavé')),
                ],
                selected: {_inputMode},
                onSelectionChanged: (s) => setState(() => _inputMode = s.first),
              ),
            ),
            if (_inputMode == InputMode.board) ...[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Dartboard(onHit: notifier.throwDart),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Fléchette ratée'),
                    onPressed: game.isFinished ? null : () => notifier.throwDart(const DartThrow.miss()),
                  ),
                ),
              ),
            ] else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: ScoreKeypad(onHit: notifier.throwDart, enabled: !game.isFinished),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showWinner(BuildContext context, GameState game) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Victoire ! 🎯'),
        content: Text('${game.players[game.winnerIndex!].name} remporte la partie.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Nouvelle partie'),
          ),
        ],
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  final GameState game;

  const _Scoreboard({required this.game});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: game.players.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == game.currentPlayerIndex && !game.isFinished;
          final score = active ? game.currentRemaining : game.scores[i];
          return Container(
            width: 110,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active ? colors.primaryContainer : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: active ? Border.all(color: colors.primary, width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(game.players[i].name, overflow: TextOverflow.ellipsis),
                Text('$score', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CurrentTurn extends StatelessWidget {
  final GameState game;

  const _CurrentTurn({required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text('À ${game.currentPlayer.name} de jouer', style: Theme.of(context).textTheme.titleMedium),
          ),
          for (var i = 0; i < X01Engine.dartsPerTurn; i++)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Chip(label: Text(i < game.currentDarts.length ? game.currentDarts[i].label : '–')),
            ),
          const SizedBox(width: 8),
          Text('= ${game.currentTurnTotal}', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
