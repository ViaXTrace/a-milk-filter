import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';
import 'package:a_milk_filter/features/editor/editor_screen.dart';
import 'package:a_milk_filter/shared/widgets/scanline_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _picker = ImagePicker();
  bool _isPickingFile = false;
  bool _dropZonePressed = false;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;
  late final AnimationController _entryController;
  late final Animation<double> _entryAnim;
  late final AnimationController _bagController;
  late final Animation<double> _bagAnim;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    )..forward();
    _entryAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic);

    _bagController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _bagAnim = CurvedAnimation(parent: _bagController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _entryController.dispose();
    _bagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingFile) return;
    HapticFeedback.lightImpact();
    setState(() => _isPickingFile = true);
    try {
      final xFile = await _picker.pickImage(source: source);
      if (xFile != null && mounted) {
        await Navigator.of(context).push(_buildRoute(EditorScreen(imageFile: File(xFile.path))));
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  PageRoute<void> _buildRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (_, animation, __, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: animation.drive(offset), child: child),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Scanline texture ────────────────────────────────────────────
          const Positioned.fill(child: ScanlineOverlay(opacity: 0.032)),

          // ── Atmospheric glows ───────────────────────────────────────────
          _AtmosphericGlow(
            controller: _glowAnim,
            top: -screenH * 0.15,
            right: -90.0,
            color: AppColors.mauve,
            size: 360,
            minOpacity: 0.07,
            opacityRange: 0.06,
          ),
          _AtmosphericGlow(
            controller: _glowAnim,
            bottom: -screenH * 0.08,
            left: -70.0,
            color: AppColors.crimson,
            size: 300,
            minOpacity: 0.06,
            opacityRange: 0.07,
          ),

          // ── Main content ────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _entryAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(),
                  _PaletteStrip(),
                  Expanded(
                    child: _DropZone(
                      glowAnim: _glowAnim,
                      bagAnim: _bagAnim,
                      isLoading: _isPickingFile,
                      isPressed: _dropZonePressed,
                      onTap: () => _pickImage(ImageSource.gallery),
                      onPressChanged: (v) => setState(() => _dropZonePressed = v),
                    ),
                  ),
                  _ActionRow(
                    disabled: _isPickingFile,
                    onGallery: () => _pickImage(ImageSource.gallery),
                    onCamera: () => _pickImage(ImageSource.camera),
                  ),
                  _Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Atmospheric glow blob ─────────────────────────────────────────────────────

class _AtmosphericGlow extends StatelessWidget {
  const _AtmosphericGlow({
    required this.controller,
    required this.color,
    required this.size,
    required this.minOpacity,
    required this.opacityRange,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  final Animation<double> controller;
  final Color color;
  final double size;
  final double minOpacity;
  final double opacityRange;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    child: IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(minOpacity + controller.value * opacityRange),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _TitleBlock()),
          const SizedBox(width: 20),
          const _PaletteStamps(),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Accent eyebrow
        Row(
          children: [
            Container(
              width: 22,
              height: 1.5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.crimson, AppColors.mauve],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'IMAGE  FILTER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.ash,
                letterSpacing: 2.0,
                fontSize: 8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Main wordmark
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Courier New',
              fontWeight: FontWeight.w900,
              height: 0.9,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'A MILK\n',
                style: TextStyle(
                  fontSize: 46,
                  color: AppColors.chalk,
                  shadows: [
                    Shadow(
                      color: AppColors.crimson.withOpacity(0.5),
                      blurRadius: 28,
                    ),
                  ],
                ),
              ),
              TextSpan(
                text: 'FILTER',
                style: TextStyle(
                  fontSize: 46,
                  color: AppColors.crimson,
                  shadows: [
                    Shadow(
                      color: AppColors.crimson.withOpacity(0.6),
                      blurRadius: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'outside the bag of milk',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.mauve.withOpacity(0.65),
            letterSpacing: 1.0,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

class _PaletteStamps extends StatelessWidget {
  const _PaletteStamps();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        SizedBox(height: 6),
        _PaletteStamp(
          label: 'MILK I',
          colors: [Color(0xFF000000), Color(0xFF660020), Color(0xFF890092)],
        ),
        SizedBox(height: 8),
        _PaletteStamp(
          label: 'MILK II',
          colors: [Color(0xFF000000), Color(0xFF5C2420), Color(0xFFCB2B2B)],
        ),
      ],
    );
  }
}

class _PaletteStamp extends StatelessWidget {
  const _PaletteStamp({required this.label, required this.colors});
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.ash,
          fontSize: 7,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(width: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Row(
          children: colors
              .map((c) => Container(width: 9, height: 24, color: c))
              .toList(),
        ),
      ),
    ],
  );
}

// ── Palette strip (decorative ticker) ─────────────────────────────────────────

class _PaletteStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Container(
        height: 1,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.crimson,
              AppColors.mauve,
              AppColors.crimson,
              Colors.transparent,
            ],
            stops: [0.0, 0.2, 0.5, 0.8, 1.0],
          ),
        ),
      ),
    );
  }
}

// ── Drop zone ─────────────────────────────────────────────────────────────────

class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.glowAnim,
    required this.bagAnim,
    required this.isLoading,
    required this.isPressed,
    required this.onTap,
    required this.onPressChanged,
  });

  final Animation<double> glowAnim;
  final Animation<double> bagAnim;
  final bool isLoading;
  final bool isPressed;
  final VoidCallback onTap;
  final ValueChanged<bool> onPressChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Semantics(
        button: true,
        label: 'Select image from gallery',
        child: GestureDetector(
          onTap: isLoading ? null : onTap,
          onTapDown: isLoading ? null : (_) => onPressChanged(true),
          onTapUp: (_) => onPressChanged(false),
          onTapCancel: () => onPressChanged(false),
          child: AnimatedBuilder(
            animation: glowAnim,
            builder: (context, child) {
              final pulse = isPressed ? 1.0 : glowAnim.value;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                decoration: BoxDecoration(
                  color: isPressed ? AppColors.crypt : AppColors.abyss,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.crimson.withOpacity(
                      isPressed ? 0.55 : 0.16 + pulse * 0.24,
                    ),
                    width: isPressed ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crimson.withOpacity(0.05 + pulse * 0.09),
                      blurRadius: 36,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.mauve.withOpacity(0.03 + pulse * 0.05),
                      blurRadius: 56,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: isLoading
                      ? const _SpinnerWidget(key: ValueKey('spinner'))
                      : _MilkBagWidget(key: const ValueKey('bag'), floatAnim: bagAnim),
                ),
                const SizedBox(height: 24),
                _DropZoneLabel(),
                const SizedBox(height: 12),
                _SupportedFormats(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerWidget extends StatelessWidget {
  const _SpinnerWidget({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 32,
    height: 32,
    child: CircularProgressIndicator(
      color: AppColors.crimson,
      strokeWidth: 1.5,
    ),
  );
}

class _MilkBagWidget extends StatelessWidget {
  const _MilkBagWidget({super.key, required this.floatAnim});
  final Animation<double> floatAnim;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: floatAnim,
    builder: (_, child) => Transform.translate(
      offset: Offset(0, -4 + floatAnim.value * 8),
      child: child,
    ),
    child: const SizedBox(
      width: 90,
      height: 112,
      child: CustomPaint(painter: _MilkBagPainter()),
    ),
  );
}

class _DropZoneLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.crypt,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(
      'TAP TO SELECT IMAGE',
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        letterSpacing: 1.4,
        color: AppColors.dust,
        fontSize: 10,
      ),
    ),
  );
}

class _SupportedFormats extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text(
    'PNG  ·  JPG  ·  JPEG  ·  HEIC',
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.ash,
      letterSpacing: 1.0,
      fontSize: 8,
    ),
  );
}

// ── Action row ────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.disabled,
    required this.onGallery,
    required this.onCamera,
  });

  final bool disabled;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _SourceButton(
              icon: Icons.photo_library_outlined,
              label: 'GALLERY',
              onTap: disabled ? null : onGallery,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SourceButton(
              icon: Icons.camera_alt_outlined,
              label: 'CAMERA',
              onTap: disabled ? null : onCamera,
              accent: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatefulWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool accent;

  @override
  State<_SourceButton> createState() => _SourceButtonState();
}

class _SourceButtonState extends State<_SourceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    final bg = widget.accent ? AppColors.crimson : AppColors.crypt;
    final pressedBg = widget.accent ? AppColors.maroon : AppColors.vessel;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          height: 52,
          decoration: BoxDecoration(
            color: _pressed ? pressedBg : bg,
            borderRadius: BorderRadius.circular(10),
            border: widget.accent
                ? null
                : Border.all(color: AppColors.border),
            boxShadow: widget.accent && !_pressed && !disabled
                ? [
                    BoxShadow(
                      color: AppColors.crimson.withOpacity(0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: disabled ? 0.38 : 1.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 15,
                  color: widget.accent ? AppColors.chalk : AppColors.dust,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: widget.accent ? AppColors.chalk : AppColors.dust,
                    letterSpacing: 1.2,
                    fontSize: 10,
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

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
      child: Row(
        children: [
          Text(
            'v1.0.0',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.ember,
              letterSpacing: 0.4,
              fontSize: 8,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 8, color: AppColors.divider),
          const SizedBox(width: 8),
          Text(
            'ViaXTrace',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.ember,
              letterSpacing: 0.4,
              fontSize: 8,
            ),
          ),
          const Spacer(),
          _PulseDots(),
        ],
      ),
    );
  }
}

class _PulseDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        return Padding(
          padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == 0
                  ? AppColors.crimson
                  : AppColors.crimson.withOpacity(0.25 - i * 0.08),
              boxShadow: i == 0
                  ? [
                      BoxShadow(
                        color: AppColors.crimson.withOpacity(0.75),
                        blurRadius: 7,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// ── Milk Bag custom painter ───────────────────────────────────────────────────

class _MilkBagPainter extends CustomPainter {
  const _MilkBagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Drop shadow
    canvas.drawPath(
      _bagPath(w, h),
      Paint()
        ..color = AppColors.crimson.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Bag body fill
    canvas.drawPath(
      _bagPath(w, h),
      Paint()
        ..color = AppColors.crimson
        ..style = PaintingStyle.fill,
    );

    // Left edge highlight
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.14, h * 0.27)
        ..lineTo(w * 0.03, h * 0.91)
        ..lineTo(w * 0.19, h * 0.91)
        ..lineTo(w * 0.27, h * 0.27)
        ..close(),
      Paint()
        ..color = AppColors.chalk.withOpacity(0.04)
        ..style = PaintingStyle.fill,
    );

    // Seal bar
    final sealRect = Rect.fromLTWH(w * 0.07, h * 0.16, w * 0.86, h * 0.13);
    canvas.drawRRect(
      RRect.fromRectAndRadius(sealRect, const Radius.circular(3)),
      Paint()..color = AppColors.maroon,
    );

    // Mauve gradient stripe on seal
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.76, h * 0.045),
        const Radius.circular(1.5),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.mauve.withOpacity(0.0),
            AppColors.mauve.withOpacity(0.9),
            AppColors.mauve.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.76, h * 0.045)),
    );

    // Fold crease lines on bag body
    final creasePaint = Paint()
      ..color = AppColors.maroon.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(w * 0.35, h * 0.32), Offset(w * 0.27, h * 0.90), creasePaint);
    canvas.drawLine(Offset(w * 0.65, h * 0.32), Offset(w * 0.73, h * 0.90), creasePaint);

    // Eyes — void squares
    final eyePaint = Paint()..color = AppColors.void_;
    final eyeStroke = Paint()
      ..color = AppColors.abyss
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final leftEye = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.50, w * 0.20, h * 0.18),
      const Radius.circular(2),
    );
    final rightEye = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.60, h * 0.50, w * 0.20, h * 0.18),
      const Radius.circular(2),
    );
    canvas.drawRRect(leftEye, eyePaint);
    canvas.drawRRect(rightEye, eyePaint);
    canvas.drawRRect(leftEye, eyeStroke);
    canvas.drawRRect(rightEye, eyeStroke);

    // Mouth
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.30, h * 0.75)
        ..quadraticBezierTo(w * 0.50, h * 0.83, w * 0.70, h * 0.75),
      Paint()
        ..color = AppColors.maroon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  Path _bagPath(double w, double h) => Path()
    ..moveTo(w * 0.14, h * 0.27)
    ..lineTo(w * 0.03, h * 0.91)
    ..quadraticBezierTo(w * 0.03, h * 0.96, w * 0.07, h * 0.96)
    ..lineTo(w * 0.93, h * 0.96)
    ..quadraticBezierTo(w * 0.97, h * 0.96, w * 0.97, h * 0.91)
    ..lineTo(w * 0.86, h * 0.27)
    ..close();

  @override
  bool shouldRepaint(_MilkBagPainter old) => false;
}
