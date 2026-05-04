import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:a_milk_filter/core/filter/filter_options.dart';

/// Isolate-safe pixel filter engine. No Flutter dependencies.
///
/// Invoke via [compute] or [Isolate.run]:
///   final result = await compute(applyFilter, FilterPayload(...));
///
/// The algorithm is a faithful Dart port of the original Python implementation.
/// Brightness is computed as the arithmetic mean of R, G, B channels
/// (no gamma correction), matching the original behaviour exactly.
Future<Uint8List> applyFilter(FilterPayload payload) async {
  var image = img.decodeImage(payload.sourceBytes);
  if (image == null) {
    throw const FilterException('Could not decode source image.');
  }

  // Optional JPEG pre-pass — DCT compression artifacts interact with
  // palette band boundaries, creating a distinctive degraded aesthetic.
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

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final brightness = (pixel.r + pixel.g + pixel.b) / 3.0;
      final argb = palette.resolve(brightness, stochastic: stochastic);
      image.setPixelRgb(
        x, y,
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
