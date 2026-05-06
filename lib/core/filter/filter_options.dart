import 'package:a_milk_filter/core/filter/milk_palette.dart';

/// Immutable value object encoding all filter processing parameters.
final class FilterOptions {
  const FilterOptions({
    required this.palette,
    this.pointillism = false,
    this.compressionQuality,
    this.filmGrain = false,
  });

  final MilkPalette palette;

  /// Enables stochastic dithering at palette boundaries (70 % primary).
  final bool pointillism;

  /// When non-null, applies JPEG compression at this quality (0–100)
  /// before palette mapping. Lower values introduce DCT block artifacts.
  final int? compressionQuality;

  /// Adds ±10 luminance noise per pixel before palette lookup, simulating
  /// the CRT phosphor grain texture of the original game.
  final bool filmGrain;

  FilterOptions copyWith({
    MilkPalette? palette,
    bool? pointillism,
    int? compressionQuality,
    bool clearCompression = false,
    bool? filmGrain,
  }) => FilterOptions(
    palette: palette ?? this.palette,
    pointillism: pointillism ?? this.pointillism,
    compressionQuality:
        clearCompression ? null : compressionQuality ?? this.compressionQuality,
    filmGrain: filmGrain ?? this.filmGrain,
  );

  @override
  String toString() =>
      'FilterOptions(palette: ${palette.name}, '
      'pointillism: $pointillism, compression: $compressionQuality, '
      'grain: $filmGrain)';
}
