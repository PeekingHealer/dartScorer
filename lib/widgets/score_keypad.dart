import 'package:flutter/material.dart';

import '../models/dart_throw.dart';

/// Pavé de saisie : un bouton par segment, avec des modificateurs Double / Triple
/// qui s'appliquent à la prochaine fléchette puis se désactivent.
class ScoreKeypad extends StatefulWidget {
  final ValueChanged<DartThrow> onHit;
  final bool enabled;

  const ScoreKeypad({super.key, required this.onHit, this.enabled = true});

  @override
  State<ScoreKeypad> createState() => _ScoreKeypadState();
}

class _ScoreKeypadState extends State<ScoreKeypad> {
  int _multiplier = 1;

  void _toggle(int multiplier) => setState(() => _multiplier = _multiplier == multiplier ? 1 : multiplier);

  void _hit(int segment) {
    widget.onHit(segment == 0 ? const DartThrow.miss() : DartThrow(segment, _multiplier));
    setState(() => _multiplier = 1);
  }

  String _label(int segment) {
    if (segment == 25) return _multiplier == 2 ? 'BULL' : '25';
    return switch (_multiplier) {
      2 => 'D$segment',
      3 => 'T$segment',
      _ => '$segment',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.enabled;

    Widget key(int segment, {Color? background, Color? foreground}) => Padding(
      padding: const EdgeInsets.all(3),
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Le triple 25 n'existe pas.
        onPressed: !enabled || (segment == 25 && _multiplier == 3) ? null : () => _hit(segment),
        child: Text(segment == 0 ? 'Raté' : _label(segment)),
      ),
    );

    Widget modifier(int multiplier, String text, Color color) {
      final active = _multiplier == multiplier;
      return Padding(
        padding: const EdgeInsets.all(3),
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: active ? color : colors.surfaceContainerHighest,
            foregroundColor: active ? Colors.white : color,
            side: BorderSide(color: color, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: enabled ? () => _toggle(multiplier) : null,
          child: Text(text),
        ),
      );
    }

    Widget row(List<Widget> children) => Expanded(
      child: Row(children: [for (final c in children) Expanded(child: SizedBox.expand(child: c))]),
    );

    return Column(
      children: [
        row([modifier(2, 'DOUBLE', const Color(0xFF2E7D32)), modifier(3, 'TRIPLE', const Color(0xFFD32F2F))]),
        for (var start = 1; start <= 20; start += 5) row([for (var s = start; s < start + 5; s++) key(s)]),
        row([key(25), key(0, background: colors.errorContainer, foreground: colors.onErrorContainer)]),
      ],
    );
  }
}
