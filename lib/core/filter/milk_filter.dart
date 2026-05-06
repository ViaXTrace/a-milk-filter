import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:a_milk_filter/core/filter/filter_options.dart';

/// Isolate-safe pixel filter engine. No Flutter dependencies.
///
/// Invoke via [compute] or [Isolate.run]:
///   final result = await compute(applyFilter, FilterPayload(...));
///
/// Pipeline (each pass is optional):
///   1. JPEG pre-pass  — DCT artifacts interact with band boundaries
///   2. Film grain     — ±10 luminance noise before palette lookup
///   3. Palette map    — brightness → Milk palette color (+ optional dither)
Future<Uint8List> applyFilter(FilterPayload payload) async {
  var image = img.decodeImage(payload.sourceBytes);
  if (image == null) {
    throw const FilterException('Could not decode source image.');
  }

  // ── Pass 1: JPEG compression pre-pass ─────────────────────────────────
  final q = payload.options.compressionQuality;
  if (q != null) {
    final compressed = img.encodeJpg(image, quality: 100 - q);
    image = img.decodeJpg(Uint8List.fromList(compressed));
    if (image == null) {
      throw const FilterException('Compression pre-pass failed.');
    }
  }

  final stochastic = payload.options.pointillism;
  final palette = payload.options.palette;
  final grain = payload.options.filmGrain;
  // One RNG per call — isolate-safe, no shared state.
  final rng = grain ? math.Random() : null;

  // ── Pass 2 + 3: Optional grain → palette map ──────────────────────────
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      double r = pixel.r.toDouble();
      double g = pixel.g.toDouble();
      double b = pixel.b.toDouble();

      // Film grain: identical luminance offset for all three channels
      // so hue is preserved while brightness shifts — matches CRT phosphor noise.
      if (rng != null) {
        final n = (rng.nextDouble() - 0.5) * 20.0; // ±10 range
        r = (r + n).clamp(0.0, 255.0);
        g = (g + n).clamp(0.0, 255.0);
        b = (b + n).clamp(0.0, 255.0);
      }

      final brightness = (r + g + b) / 3.0;
      final argb = palette.resolve(brightness, stochastic: stochastic);
      image.setPixelRgb(
        x,
        y,
        (argb >> 16) & 0xFF,
        (argb >> 8) & 0xFF,
        argb & 0xFF,
      );
    }
  }

  return Uint8List.fromList(img.encodePng(image));
}

/// Typed payload for [compute] — serialisable across isolate boundaries.
final class FilterPayload {
  const FilterPayload({required this.sourceBytes, required this.options});
  final Uint8List sourceBytes;
  final FilterOptions options;
}

/// Thrown when the filter engine encounters an unrecoverable error.
final class FilterException implements Exception {
  const FilterException(this.message);
  final String message;
  @override
  String toString() => 'FilterException: $message';
}
