import 'package:a_milk_filter/core/filter/milk_palette.dart';

/// Immutable value object encoding all filter processing parameters.
final class FilterOptions {
  const FilterOptions({
    required this.palette,
    this.pointillism = false,
    this.compressionQuality,
  });

  final MilkPalette palette;

  /// Enables stochastic dithering at palette boundaries (70 % primary).
  final bool pointillism;

  /// When non-null, applies JPEG compression at this quality (0–100)
  /// before palette mapping. Lower values introduce DCT block artifacts.
  final int? compressionQuality;

  FilterOptions copyWith({
    MilkPalette? palette,
    bool? pointillism,
    int? compressionQuality,
    bool clearCompression = false,
  }) => FilterOptions(
    palette: palette ?? this.palette,
    pointillism: pointillism ?? this.pointillism,
    compressionQuality:
        clearCompression ? null : compressionQuality ?? this.compressionQuality,
  );

  @override
  String toString() =>
      'FilterOptions(palette: ${palette.name}, '
      'pointillism: $pointillism, compression: $compressionQuality)';
}
