import 'package:flutter/material.dart';
import 'package:a_milk_filter/core/filter/filter_options.dart';
import 'package:a_milk_filter/core/filter/milk_palette.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// Scrollable filter configuration panel.
/// All controls are disabled while the filter is processing.
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
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.zero,
    physics: const NeverScrollableScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Palette Mode ─────────────────────────────────────────────────
        const _SectionLabel(label: 'PALETTE MODE', top: 18, bottom: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _PalettePicker(
            selected: options.palette,
            onChanged: enabled
                ? (p) => onChanged(options.copyWith(palette: p))
                : null,
          ),
        ),

        // ── Divider ──────────────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Divider(height: 1, thickness: 1, color: AppColors.divider),
        ),

        // ── Effects ──────────────────────────────────────────────────────
        const _SectionLabel(label: 'EFFECTS', top: 14, bottom: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _ToggleRow(
            icon: Icons.grain_rounded,
            label: 'Pointillism',
            sublabel: '70 % stochastic dithering at palette transitions',
            value: options.pointillism,
            accentColor: AppColors.mauve,
            onChanged: enabled
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
        const SizedBox(height: 8),
      ],
    ),
  );
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    this.top = 16,
    this.bottom = 8,
  });

  final String label;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, top, 20, bottom),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.crimson, AppColors.mauve],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.ash,
            letterSpacing: 1.6,
            fontSize: 8,
          ),
        ),
      ],
    ),
  );
}

// ── Palette picker ────────────────────────────────────────────────────────────

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
            disabled: onChanged == null,
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
    required this.disabled,
  });

  final MilkPalette palette;
  final bool isSelected;
  final VoidCallback onTap;
  final bool disabled;

  @override
  State<_PaletteCard> createState() => _PaletteCardState();
}

class _PaletteCardState extends State<_PaletteCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.isSelected;
    return Semantics(
      button: true,
      selected: sel,
      label: widget.palette.name,
      child: GestureDetector(
        onTap: widget.disabled ? null : widget.onTap,
        onTapDown: widget.disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.vessel
                : sel
                    ? AppColors.maroon
                    : AppColors.crypt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? AppColors.crimson : AppColors.border,
              width: sel ? 1.5 : 1,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: AppColors.crimson.withOpacity(0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: widget.disabled ? 0.5 : 1.0,
            child: Row(
              children: [
                _ColorSwatch(palette: widget.palette),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.palette.name,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: sel ? AppColors.chalk : AppColors.dust,
                          letterSpacing: 0.7,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.palette.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: sel ? AppColors.dust : AppColors.ash,
                          fontSize: 8,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (sel)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.crimson,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.crimson.withOpacity(0.75),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.palette});
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
        children: colors.map((c) => Container(width: 9, height: 11, color: c)).toList(),
      ),
    );
  }
}

// ── Toggle row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.accentColor,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final bool value;
  final Color accentColor;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 160),
    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
    decoration: BoxDecoration(
      color: value ? AppColors.vessel : AppColors.crypt,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: value ? accentColor.withOpacity(0.45) : AppColors.border,
      ),
    ),
    child: Row(
      children: [
        Icon(icon, size: 15, color: value ? accentColor : AppColors.ash),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

// ── Compression section ───────────────────────────────────────────────────────

class _CompressionSection extends StatelessWidget {
  const _CompressionSection({
    required this.quality,
    required this.enabled,
    required this.onChanged,
  });

  final int? quality;
  final bool enabled;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = quality != null;
    final q = quality ?? 50;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: active ? AppColors.vessel : AppColors.crypt,
            borderRadius: active
                ? const BorderRadius.vertical(top: Radius.circular(10))
                : BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? AppColors.crimson.withOpacity(0.45)
                  : AppColors.border,
            ),
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
                onChanged: enabled ? (v) => onChanged(v ? 50 : null) : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        // Quality slider — expands/collapses
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: active
              ? Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 16, 12),
                  decoration: BoxDecoration(
                    color: AppColors.abyss,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    border: Border(
                      left: BorderSide(
                        color: AppColors.crimson.withOpacity(0.35),
                      ),
                      right: BorderSide(
                        color: AppColors.crimson.withOpacity(0.35),
                      ),
                      bottom: BorderSide(
                        color: AppColors.crimson.withOpacity(0.35),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QUALITY',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.ash,
                              fontSize: 8,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _qualityLabel(q),
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _qualityColor(q),
                              fontSize: 7,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Slider(
                          value: q.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '$q',
                          onChanged: enabled ? (v) => onChanged(v.round()) : null,
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '$q',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _qualityColor(q),
                            fontSize: 11,
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

  static String _qualityLabel(int q) {
    if (q <= 20) return 'heavy degradation';
    if (q <= 50) return 'moderate artifacts';
    if (q <= 80) return 'light compression';
    return 'minimal effect';
  }

  static Color _qualityColor(int q) {
    if (q <= 30) return AppColors.blood;
    if (q <= 60) return AppColors.crimson;
    return AppColors.dust;
  }
}
