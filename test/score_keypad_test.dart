import 'package:darts_scorer/models/dart_throw.dart';
import 'package:darts_scorer/widgets/score_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<DartThrow> hits;

  Future<void> pump(WidgetTester tester) async {
    hits = [];
    await tester.binding.setSurfaceSize(const Size(400, 600));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ScoreKeypad(onHit: hits.add)),
      ),
    );
  }

  testWidgets('un segment seul donne un simple', (tester) async {
    await pump(tester);
    await tester.tap(find.text('20'));
    expect(hits, [const DartThrow(20, 1)]);
  });

  testWidgets('Double / Triple s\'appliquent à la fléchette suivante puis se réinitialisent', (tester) async {
    await pump(tester);
    await tester.tap(find.text('TRIPLE'));
    await tester.pump();
    await tester.tap(find.text('T20'));
    await tester.pump();
    await tester.tap(find.text('DOUBLE'));
    await tester.pump();
    await tester.tap(find.text('BULL'));
    await tester.pump();
    await tester.tap(find.text('5'));
    expect(hits, [const DartThrow(20, 3), const DartThrow(25, 2), const DartThrow(5, 1)]);
  });

  testWidgets('re-toucher un modificateur l\'annule', (tester) async {
    await pump(tester);
    await tester.tap(find.text('DOUBLE'));
    await tester.pump();
    await tester.tap(find.text('DOUBLE'));
    await tester.pump();
    await tester.tap(find.text('18'));
    expect(hits, [const DartThrow(18, 1)]);
  });

  testWidgets('pas de triple 25, et Raté donne 0', (tester) async {
    await pump(tester);
    await tester.tap(find.text('TRIPLE'));
    await tester.pump();
    await tester.tap(find.text('25'));
    await tester.tap(find.text('Raté'));
    expect(hits, [const DartThrow.miss()]);
  });
}
