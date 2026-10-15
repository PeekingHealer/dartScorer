import 'package:darts_scorer/models/dart_throw.dart';
import 'package:darts_scorer/widgets/dartboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Rayon total 200 → zone de score de 168 (0.84).
  const radius = 200.0;
  const board = radius * 0.84;

  test('centre = bull, anneau suivant = 25', () {
    expect(hitTest(Offset.zero, radius), const DartThrow(25, 2));
    expect(hitTest(const Offset(0, -board * 12 / 170), radius), const DartThrow(25, 1));
  });

  test('en haut : simple, triple et double 20', () {
    expect(hitTest(const Offset(0, -board * 0.4), radius), const DartThrow(20, 1));
    expect(hitTest(const Offset(0, -board * 103 / 170), radius), const DartThrow(20, 3));
    expect(hitTest(const Offset(0, -board * 166 / 170), radius), const DartThrow(20, 2));
  });

  test('à droite = 6, en bas = 3, à gauche = 11', () {
    expect(hitTest(const Offset(board * 0.4, 0), radius), const DartThrow(6, 1));
    expect(hitTest(const Offset(0, board * 0.4), radius), const DartThrow(3, 1));
    expect(hitTest(const Offset(-board * 0.4, 0), radius), const DartThrow(11, 1));
  });

  test('hors de la cible = raté', () {
    expect(hitTest(const Offset(0, -board * 1.05), radius).isMiss, isTrue);
  });
}
