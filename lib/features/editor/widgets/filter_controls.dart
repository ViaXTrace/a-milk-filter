import 'package:flutter/material.dart';
import 'package:a_milk_filter/core/filter/filter_options.dart';
import 'package:a_milk_filter/core/filter/milk_palette.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// Control panel for all filter parameters.
class FilterControls extends StatelessWidget {
  const FilterControls({
    super.key,
    required this.options,
    required this.onChanged,
    required this.enabled,
  });

  final FilterOptions options;
  final ValueChanged<FilterOptions> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'PALETTE MODE'),
        const SizedBox(height: 8),
        _PalettePicker(
          selected: options.palette,
          onChanged: enabled
              ? (p) => onChanged(options.copyWith(palette: p))
              : null,
        ),
        const SizedBox(height: 14),
        _ToggleRow(
          label: 'POINTILLISM',
          sublabel: '70% stochastic dithering at boundaries',
          value: options.pointillism,
          onChanged: enabled
              ? (v) => onChanged(options.copyWith(pointillism: v))
              : null,
        ),
        const SizedBox(height: 8),
        _CompressionSection(
          quality: options.compressionQuality,
          enabled: enabled,
          onChanged: (q) {
            if (q == null) {
              onChanged(options.copyWith(clearCompression: true));
            } else {
              onChanged(options.copyWith(compressionQuality: q));
            }
          },
        ),
        const SizedBox(height: 2),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: AppColors.ash, letterSpacing: 0.5,
    ),
  );
}

class _PalettePicker extends StatelessWidget {
  const _PalettePicker({required this.selected, required this.onChanged});
  final MilkPalette selected;
  final ValueChanged<MilkPalette>? onChanged;

  static const _palettes = <MilkPalette>[MilkPaletteOne(), MilkPaletteTwo()];

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (int i = 0; i < _palettes.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(child: _PaletteCard(
          palette: _palettes[i],
          isSelected: _palettes[i].runtimeType == selected.runtimeType,
          onTap: () => onChanged?.call(_palettes[i]),
        )),
      ],
    ],
  );
}

class _PaletteCard extends StatelessWidget {
  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });
  final MilkPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 50,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.maroon : AppColors.crypt,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isSelected ? AppColors.crimson : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ColorSwatches(palette: palette),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                palette.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? AppColors.chalk : AppColors.dust,
                ),
              ),
              Text(
                palette.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 7,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches({required this.palette});
  final MilkPalette palette;

  @override
  Widget build(BuildContext context) {
    final colors = switch (palette) {
      MilkPaletteOne() => const [
          Color(0xFF000000), Color(0xFF660020), Color(0xFF890092),
        ],
      MilkPaletteTwo() => const [
          Color(0xFF000000), Color(0xFF5C2420), Color(0xFFCB2B2B),
        ],
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(1),
      child: Row(
        children: colors
            .map((c) => Container(width: 5, height: 26, color: c))
            .toList(),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: AppColors.chalk)),
            Text(sublabel, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
      Switch(value: value, onChanged: onChanged),
    ],
  );
}

class _CompressionSection extends StatefulWidget {
  const _CompressionSection({
    required this.quality,
    required this.enabled,
    required this.onChanged,
  });
  final int? quality;
  final bool enabled;
  final ValueChanged<int?> onChanged;

  @override
  State<_CompressionSection> createState() => _CompressionSectionState();
}

class _CompressionSectionState extends State<_CompressionSection> {
  @override
  Widget build(BuildContext context) {
    final active = widget.quality != null;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('COMPRESSION PRE-PASS',
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: AppColors.chalk)),
                  Text('JPEG artifacts + palette quantization',
                    style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            Switch(
              value: active,
              onChanged: widget.enabled
                  ? (v) => widget.onChanged(v ? 50 : null)
                  : null,
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: active
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Text('QUALITY',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.ash)),
                      Expanded(
                        child: Slider(
                          value: (widget.quality ?? 50).toDouble(),
                          min: 0, max: 100, divisions: 20,
                          label: '${widget.quality ?? 50}',
                          onChanged: widget.enabled
                              ? (v) => widget.onChanged(v.round())
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${widget.quality ?? 50}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.dust),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
