import 'dart:math';

import 'package:flutter/material.dart';

import '../models/dart_throw.dart';

/// Ordre des segments dans le sens horaire, en partant du haut.
const List<int> kBoardOrder = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5];

/// Rayons officiels (en mm) rapportés au bord extérieur du double (170 mm).
class _Rings {
  static const double bull = 6.35 / 170;
  static const double outerBull = 15.9 / 170;
  static const double tripleInner = 99 / 170;
  static const double tripleOuter = 107 / 170;
  static const double doubleInner = 162 / 170;
  static const double doubleOuter = 1.0;
}

/// Part du rayon total occupée par la zone de score (le reste affiche les numéros).
const double _scoringFraction = 0.84;

/// Convertit une position relative au centre en fléchette.
/// [radius] est le rayon total du widget (numéros compris).
DartThrow hitTest(Offset fromCenter, double radius) {
  final r = fromCenter.distance / (radius * _scoringFraction);
  if (r > _Rings.doubleOuter) return const DartThrow.miss();
  if (r <= _Rings.bull) return const DartThrow(25, 2);
  if (r <= _Rings.outerBull) return const DartThrow(25, 1);

  // Angle en degrés, 0 en haut, croissant dans le sens horaire.
  final angle = (atan2(fromCenter.dx, -fromCenter.dy) * 180 / pi + 360) % 360;
  final segment = kBoardOrder[((angle + 9) % 360 ~/ 18)];

  if (r >= _Rings.doubleInner) return DartThrow(segment, 2);
  if (r >= _Rings.tripleInner && r <= _Rings.tripleOuter) return DartThrow(segment, 3);
  return DartThrow(segment, 1);
}

class Dartboard extends StatefulWidget {
  final ValueChanged<DartThrow> onHit;

  const Dartboard({super.key, required this.onHit});

  @override
  State<Dartboard> createState() => _DartboardState();
}

class _DartboardState extends State<Dartboard> {
  DartThrow? _highlight;

  void _handleTap(Offset local, double size) {
    final center = Offset(size / 2, size / 2);
    final dart = hitTest(local - center, size / 2);
    setState(() => _highlight = dart);
    widget.onHit(dart);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _handleTap(details.localPosition, size),
            child: CustomPaint(
              size: Size.square(size),
              painter: _DartboardPainter(highlight: _highlight),
            ),
          );
        },
      ),
    );
  }
}

class _DartboardPainter extends CustomPainter {
  final DartThrow? highlight;

  _DartboardPainter({this.highlight});

  static const _black = Color(0xFF1B1B1B);
  static const _cream = Color(0xFFF3E5C3);
  static const _red = Color(0xFFD32F2F);
  static const _green = Color(0xFF2E7D32);
  static const _highlightColor = Color(0xCCFFC107);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final board = outer * _scoringFraction;
    final paint = Paint()..style = PaintingStyle.fill;

    // Fond (anneau des numéros).
    canvas.drawCircle(center, outer, paint..color = _black);

    const sweep = 2 * pi / 20;
    for (var i = 0; i < 20; i++) {
      final segment = kBoardOrder[i];
      // -pi/2 = haut ; chaque segment est centré sur son angle.
      final start = -pi / 2 + i * sweep - sweep / 2;
      final even = i.isEven;

      void ring(double inner, double outerR, Color color, int multiplier) {
        final isHit = highlight == DartThrow(segment, multiplier);
        paint.color = isHit ? _highlightColor : color;
        canvas.drawPath(_arcPath(center, board * inner, board * outerR, start, sweep), paint);
      }

      ring(_Rings.tripleOuter, _Rings.doubleInner, even ? _black : _cream, 1);
      ring(_Rings.outerBull, _Rings.tripleInner, even ? _black : _cream, 1);
      ring(_Rings.doubleInner, _Rings.doubleOuter, even ? _red : _green, 2);
      ring(_Rings.tripleInner, _Rings.tripleOuter, even ? _red : _green, 3);

      _drawNumber(canvas, center, (board + outer) / 2, -pi / 2 + i * sweep, '$segment', outer);
    }

    // Fils entre les segments.
    final wire = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (final r in [
      _Rings.outerBull,
      _Rings.tripleInner,
      _Rings.tripleOuter,
      _Rings.doubleInner,
      _Rings.doubleOuter,
    ]) {
      canvas.drawCircle(center, board * r, wire);
    }

    final outerBullHit = highlight == const DartThrow(25, 1);
    final bullHit = highlight == const DartThrow(25, 2);
    canvas.drawCircle(center, board * _Rings.outerBull, paint..color = outerBullHit ? _highlightColor : _green);
    canvas.drawCircle(center, board * _Rings.bull, paint..color = bullHit ? _highlightColor : _red);
  }

  Path _arcPath(Offset c, double r1, double r2, double start, double sweep) {
    return Path()
      ..arcTo(Rect.fromCircle(center: c, radius: r2), start, sweep, true)
      ..arcTo(Rect.fromCircle(center: c, radius: r1), start + sweep, -sweep, false)
      ..close();
  }

  void _drawNumber(Canvas canvas, Offset c, double r, double angle, String text, double outer) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.white, fontSize: outer * 0.09, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pos = c + Offset(cos(angle), sin(angle)) * r;
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_DartboardPainter old) => old.highlight != highlight;
}
