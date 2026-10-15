/// Une fléchette lancée : un segment (0 = raté, 1-20, 25 = bull) et un multiplicateur.
class DartThrow {
  final int segment;
  final int multiplier;

  const DartThrow(this.segment, this.multiplier)
    : assert(segment == 0 || segment == 25 || (segment >= 1 && segment <= 20)),
      assert(multiplier >= 1 && multiplier <= 3),
      assert(segment != 25 || multiplier <= 2);

  const DartThrow.miss() : this(0, 1);

  int get score => segment * multiplier;

  bool get isMiss => segment == 0;

  /// Le bull (50) compte comme un double pour la finition.
  bool get isDouble => multiplier == 2;

  String get label {
    if (isMiss) return 'Raté';
    if (segment == 25) return multiplier == 2 ? 'BULL' : '25';
    return switch (multiplier) {
      2 => 'D$segment',
      3 => 'T$segment',
      _ => '$segment',
    };
  }

  @override
  bool operator ==(Object other) => other is DartThrow && other.segment == segment && other.multiplier == multiplier;

  @override
  int get hashCode => Object.hash(segment, multiplier);

  @override
  String toString() => label;
}
