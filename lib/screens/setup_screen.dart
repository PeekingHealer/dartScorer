import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_config.dart';
import '../providers/game_provider.dart';
import '../providers/setup_provider.dart';
import 'game_screen.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    ref.read(setupProvider.notifier).addPlayer(_nameController.text);
    _nameController.clear();
  }

  void _startGame() {
    final setup = ref.read(setupProvider);
    ref.read(gameProvider.notifier).start(setup.config, setup.players);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final setup = ref.watch(setupProvider);
    final notifier = ref.read(setupProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle partie')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<GameType>(
              segments: [for (final type in GameType.values) ButtonSegment(value: type, label: Text(type.label))],
              selected: {setup.config.type},
              onSelectionChanged: (s) => notifier.setGameType(s.first),
            ),
            SwitchListTile(
              title: const Text('Finir sur un double'),
              value: setup.config.doubleOut,
              onChanged: notifier.setDoubleOut,
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom du joueur'),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                IconButton.filled(icon: const Icon(Icons.person_add), onPressed: _addPlayer),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Joueurs (${setup.players.length})', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Ordre aléatoire'),
                  onPressed: setup.players.length > 1 ? notifier.shuffle : null,
                ),
              ],
            ),
            Expanded(
              child: ReorderableListView(
                onReorderItem: notifier.reorder,
                children: [
                  for (final (i, player) in setup.players.indexed)
                    ListTile(
                      key: ValueKey(player.id),
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(player.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => notifier.removePlayer(player.id),
                      ),
                    ),
                ],
              ),
            ),
            FilledButton(
              onPressed: setup.players.isEmpty ? null : _startGame,
              child: const Padding(padding: EdgeInsets.all(12), child: Text('Commencer')),
            ),
          ],
        ),
      ),
    );
  }
}
