import 'package:flutter_test/flutter_test.dart';
import 'package:a_milk_filter/core/filter/filter_options.dart';
import 'package:a_milk_filter/core/filter/milk_palette.dart';

void main() {
  group('MilkPaletteOne', () {
    const palette = MilkPaletteOne();

    test('maps void brightness (0) to black', () {
      expect(palette.resolve(0, stochastic: false), equals(0xFF000000));
    });

    test('maps low brightness (20) to black', () {
      expect(palette.resolve(20, stochastic: false), equals(0xFF000000));
    });

    test('maps mid brightness (150) to crimson', () {
      // Pixel-exact: Python (102,0,31) → 0xFF66001F
      expect(palette.resolve(150, stochastic: false), equals(0xFF66001F));
    });

    test('maps high brightness (235) to mauve', () {
      expect(palette.resolve(235, stochastic: false), equals(0xFF890092));
    });
  });

  group('MilkPaletteTwo', () {
    const palette = MilkPaletteTwo();

    test('maps void brightness (0) to black', () {
      expect(palette.resolve(0, stochastic: false), equals(0xFF000000));
    });

    test('maps mid brightness (120) to rust', () {
      // Pixel-exact: Python (92,36,60) → 0xFF5C243C
      expect(palette.resolve(120, stochastic: false), equals(0xFF5C243C));
    });

    test('maps high brightness (210) to blood red', () {
      expect(palette.resolve(210, stochastic: false), equals(0xFFCB2B2B));
    });
  });

  group('FilterOptions', () {
    test('defaults: no pointillism, no compression', () {
      const opts = FilterOptions(palette: MilkPaletteOne());
      expect(opts.pointillism, isFalse);
      expect(opts.compressionQuality, isNull);
    });

    test('copyWith updates palette', () {
      const opts = FilterOptions(palette: MilkPaletteOne());
      final updated = opts.copyWith(palette: const MilkPaletteTwo());
      expect(updated.palette, isA<MilkPaletteTwo>());
      expect(updated.pointillism, isFalse);
    });

    test('copyWith toggles pointillism', () {
      const opts = FilterOptions(palette: MilkPaletteOne());
      final updated = opts.copyWith(pointillism: true);
      expect(updated.pointillism, isTrue);
      expect(updated.palette, isA<MilkPaletteOne>());
    });

    test('copyWith sets compression quality', () {
      const opts = FilterOptions(palette: MilkPaletteOne());
      final updated = opts.copyWith(compressionQuality: 42);
      expect(updated.compressionQuality, equals(42));
    });

    test('copyWith clears compression with clearCompression flag', () {
      const opts = FilterOptions(
        palette: MilkPaletteOne(),
        compressionQuality: 50,
      );
      final updated = opts.copyWith(clearCompression: true);
      expect(updated.compressionQuality, isNull);
    });
  });
}
