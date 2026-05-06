import 'dart:math' as math;

final _random = math.Random();

/// Sealed palette hierarchy. Each subclass encodes the brightness→color
/// mapping for one filter mode. [resolve] is isolate-safe (no Flutter deps).
sealed class MilkPalette {
  const MilkPalette();

  String get name;
  String get label;
  List<_Band> get _bands;

  /// Maps [brightness] (0–255, arithmetic mean of R G B) to an ARGB int.
  /// When [stochastic] is true (pointillism mode), boundary bands dither
  /// at 70 % primary / 30 % secondary probability — exact port of the
  /// original Python: punt = 70 if pointillism else 100.
  int resolve(double brightness, {required bool stochastic}) {
    final threshold = stochastic ? 0.70 : 1.00;
    for (final band in _bands) {
      if (brightness <= band.maxBrightness) {
        final secondary = band.secondary;
        if (secondary != null) {
          return _random.nextDouble() < threshold ? band.primary : secondary;
        }
        return band.primary;
      }
    }
    return _bands.last.primary;
  }
}

final class _Band {
  const _Band(this.maxBrightness, this.primary, {this.secondary});
  final double maxBrightness;
  final int primary;
  final int? secondary;
}

// ─────────────────────────────────────────────────────────────────────────────
// Milk I — black / crimson (102,0,31) / mauve (137,0,146)
// Exact Python thresholds and RGB values:
//   <= 25           → black
//   25 < b <= 70    → black (70%) / crimson (30%) [stochastic boundary]
//   70 < b < 120    → crimson (70%) / black (30%) [stochastic boundary]
//   120 <= b < 200  → crimson always
//   200 <= b < 230  → mauve (70%) / crimson (30%) [stochastic boundary]
//   >= 230          → mauve always
// ─────────────────────────────────────────────────────────────────────────────
final class MilkPaletteOne extends MilkPalette {
  const MilkPaletteOne();

  @override
  String get name => 'MILK I';
  @override
  String get label => 'Crimson · Mauve · Void';

  @override
  List<_Band> get _bands => const [
    _Band(25,  0xFF000000),                              // black
    _Band(70,  0xFF000000, secondary: 0xFF66001F),       // black / crimson
    _Band(119, 0xFF66001F, secondary: 0xFF000000),       // crimson / black  (< 120)
    _Band(199, 0xFF66001F),                              // crimson always (< 200)
    _Band(229, 0xFF890092, secondary: 0xFF66001F),       // mauve / crimson  (< 230)
    _Band(256, 0xFF890092),                              // mauve always
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Milk II — black / rust (92,36,60) / blood (203,43,43)
// Exact Python thresholds and RGB values:
//   <= 25           → black
//   25 < b <= 70    → black (70%) / rust (30%) [stochastic boundary]
//   70 < b < 90     → rust (70%) / black (30%) [stochastic boundary]
//   90 <= b < 150   → rust always
//   150 <= b < 200  → blood (70%) / rust (30%) [stochastic boundary]
//   >= 200          → blood always
// ─────────────────────────────────────────────────────────────────────────────
final class MilkPaletteTwo extends MilkPalette {
  const MilkPaletteTwo();

  @override
  String get name => 'MILK II';
  @override
  String get label => 'Blood · Rust · Void';

  @override
  List<_Band> get _bands => const [
    _Band(25,  0xFF000000),                              // black
    _Band(70,  0xFF000000, secondary: 0xFF5C243C),       // black / rust
    _Band(89,  0xFF5C243C, secondary: 0xFF000000),       // rust / black  (< 90)
    _Band(149, 0xFF5C243C),                              // rust always (< 150)
    _Band(199, 0xFFCB2B2B, secondary: 0xFF5C243C),       // blood / rust  (< 200)
    _Band(256, 0xFFCB2B2B),                              // blood always
  ];
}
