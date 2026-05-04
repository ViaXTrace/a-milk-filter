import 'package:flutter/material.dart';
import 'package:a_milk_filter/core/filter/filter_options.dart';
import 'package:a_milk_filter/core/filter/milk_palette.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      // ── Section: Palette Mode ───────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: _SectionLabel(label: 'PALETTE MODE'),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _PalettePicker(
          selected: options.palette,
          onChanged:
              enabled ? (p) => onChanged(options.copyWith(palette: p)) : null,
        ),
      ),

      // ── Divider ─────────────────────────────────────────────────────────
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Divider(height: 1, thickness: 1, color: AppColors.divider),
      ),

      // ── Section: Effects ────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: _SectionLabel(label: 'EFFECTS'),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _ToggleRow(
          icon: Icons.grain_rounded,
          label: 'Pointillism',
          sublabel: '70% stochastic dithering at transitions',
          value: options.pointillism,
          onChanged:
              enabled
                  ? (v) => onChanged(options.copyWith(pointillism: v))
                  : null,
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _CompressionSection(
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
      ),
      const SizedBox(height: 6),
    ],
  );
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.ash,
      letterSpacing: 1.4,
      fontSize: 9,
    ),
  );
}

// ── Palette Picker ────────────────────────────────────────────────────────────

class _PalettePicker extends StatelessWidget {
  const _PalettePicker({required this.selected, required this.onChanged});
  final MilkPalette selected;
  final ValueChanged<MilkPalette>? onChanged;

  static const _palettes = <MilkPalette>[MilkPaletteOne(), MilkPaletteTwo()];

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (int i = 0; i < _palettes.length; i++) ...[
        if (i > 0) const SizedBox(width: 10),
        Expanded(
          child: _PaletteCard(
            palette: _palettes[i],
            isSelected: _palettes[i].runtimeType == selected.runtimeType,
            onTap: () => onChanged?.call(_palettes[i]),
          ),
        ),
      ],
    ],
  );
}

class _PaletteCard extends StatefulWidget {
  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });
  final MilkPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_PaletteCard> createState() => _PaletteCardState();
}

class _PaletteCardState extends State<_PaletteCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              _pressed
                  ? AppColors.vessel
                  : selected
                  ? AppColors.maroon
                  : AppColors.crypt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.crimson : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: AppColors.crimson.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            _ColorPill(palette: widget.palette),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.palette.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? AppColors.chalk : AppColors.dust,
                      letterSpacing: 0.6,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.palette.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? AppColors.dust : AppColors.ash,
                      fontSize: 8,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.crimson,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crimson.withOpacity(0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorPill extends StatelessWidget {
  const _ColorPill({required this.palette});
  final MilkPalette palette;

  @override
  Widget build(BuildContext context) {
    final colors = switch (palette) {
      MilkPaletteOne() => const [
        Color(0xFF000000),
        Color(0xFF660020),
        Color(0xFF890092),
      ],
      MilkPaletteTwo() => const [
        Color(0xFF000000),
        Color(0xFF5C2420),
        Color(0xFFCB2B2B),
      ],
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            colors
                .map((c) => Container(width: 8, height: 10, color: c))
                .toList(),
      ),
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
    decoration: BoxDecoration(
      color: AppColors.crypt,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(icon, size: 15, color: value ? AppColors.mauve : AppColors.ash),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: value ? AppColors.chalk : AppColors.dust,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  color: AppColors.ash,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    ),
  );
}

// ── Compression Section ───────────────────────────────────────────────────────

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
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: AppColors.crypt,
            borderRadius:
                active
                    ? const BorderRadius.vertical(top: Radius.circular(10))
                    : BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.compress_rounded,
                size: 15,
                color: active ? AppColors.crimson : AppColors.ash,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compression Pre-Pass',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: active ? AppColors.chalk : AppColors.dust,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'JPEG artifacts + palette quantization',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        color: AppColors.ash,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: active,
                onChanged:
                    widget.enabled
                        ? (v) => widget.onChanged(v ? 50 : null)
                        : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child:
              active
                  ? Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
                    decoration: BoxDecoration(
                      color: AppColors.abyss,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                      border: Border(
                        left: BorderSide(color: AppColors.border),
                        right: BorderSide(color: AppColors.border),
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'QUALITY',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: AppColors.ash,
                            fontSize: 9,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbRadius: 6,
                              overlayRadius: 14,
                            ),
                            child: Slider(
                              value: (widget.quality ?? 50).toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 20,
                              label: '${widget.quality ?? 50}',
                              onChanged:
                                  widget.enabled
                                      ? (v) => widget.onChanged(v.round())
                                      : null,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 26,
                          child: Text(
                            '${widget.quality ?? 50}',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: AppColors.crimson,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
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
