import 'dart:math' as math;

final _random = math.Random();

/// Sealed palette hierarchy. Each subclass encodes the brightness→color
/// mapping for one filter mode. [resolve] is isolate-safe (no Flutter deps).
sealed class MilkPalette {
  const MilkPalette();

  String get name;
  String get label;
  List<_Band> get bands;

  /// Maps [brightness] (0–255, arithmetic mean of R G B) to an ARGB int.
  /// When [stochastic] is true (pointillism mode), boundary bands dither
  /// at 70 % primary / 30 % secondary probability.
  int resolve(double brightness, {required bool stochastic}) {
    for (final band in bands) {
      if (brightness <= band.maxBrightness) {
        final secondary = band.secondary;
        if (secondary != null && stochastic) {
          return _random.nextDouble() < 0.7 ? band.primary : secondary;
        }
        return band.primary;
      }
    }
    return bands.last.primary;
  }
}

final class _Band {
  const _Band(this.maxBrightness, this.primary, {this.secondary});
  final double maxBrightness;
  final int primary;
  final int? secondary;
}

/// Milk I — black / crimson / mauve.
/// Direct port of the original Python palette table.
final class MilkPaletteOne extends MilkPalette {
  const MilkPaletteOne();

  @override String get name => 'MILK I';
  @override String get label => 'Crimson · Mauve · Void';

  @override
  List<_Band> get bands => const [
    _Band(25,  0xFF000000),
    _Band(70,  0xFF000000, secondary: 0xFF660020),
    _Band(120, 0xFF660020, secondary: 0xFF000000),
    _Band(200, 0xFF660020),
    _Band(230, 0xFF890092, secondary: 0xFF660020),
    _Band(256, 0xFF890092),
  ];
}

/// Milk II — black / rust / blood red.
final class MilkPaletteTwo extends MilkPalette {
  const MilkPaletteTwo();

  @override String get name => 'MILK II';
  @override String get label => 'Blood · Rust · Void';

  @override
  List<_Band> get bands => const [
    _Band(25,  0xFF000000),
    _Band(70,  0xFF000000, secondary: 0xFF5C2420),
    _Band(90,  0xFF5C2420, secondary: 0xFF000000),
    _Band(150, 0xFF5C2420),
    _Band(200, 0xFFCB2B2B, secondary: 0xFF5C2420),
    _Band(256, 0xFFCB2B2B),
  ];
}
