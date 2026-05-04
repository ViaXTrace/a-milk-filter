import 'dart:io';
import 'package:flutter/material.dart';
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
  bool _isHoveringDrop = false;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;
  late final AnimationController _fadeInController;
  late final Animation<double> _fadeInAnim;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeInAnim = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeInController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingFile) return;
    setState(() => _isPickingFile = true);
    try {
      final xFile = await _picker.pickImage(source: source);
      if (xFile != null && mounted) {
        await Navigator.of(
          context,
        ).push(_slideRoute(EditorScreen(imageFile: File(xFile.path))));
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  PageRoute<void> _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 420),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: animation.drive(tween), child: child),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        children: [
          const ScanlineOverlay(opacity: 0.03),
          // Radial glow at top-right (brand atmosphere)
          Positioned(
            top: -screenH * 0.18,
            right: -80,
            child: AnimatedBuilder(
              animation: _glowAnim,
              builder:
                  (_, __) => Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.mauve.withValues(
                            alpha: 0.09 + _glowAnim.value * 0.05,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
            ),
          ),
          // Radial glow bottom-left
          Positioned(
            bottom: -screenH * 0.1,
            left: -60,
            child: AnimatedBuilder(
              animation: _glowAnim,
              builder:
                  (_, __) => Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.crimson.withValues(
                            alpha: 0.08 + _glowAnim.value * 0.06,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeInAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildDropZone(context)),
                  _buildActionRow(context),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand accent line
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.crimson, AppColors.mauve],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'IMAGE FILTER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.ash,
                        letterSpacing: 1.4,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Courier New',
                      fontWeight: FontWeight.w900,
                      height: 0.92,
                      letterSpacing: -1,
                    ),
                    children: [
                      TextSpan(
                        text: 'A MILK\n',
                        style: TextStyle(
                          fontSize: 48,
                          color: AppColors.chalk,
                          shadows: [
                            Shadow(
                              color: AppColors.crimson.withValues(alpha: 0.45),
                              blurRadius: 32,
                            ),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: 'FILTER',
                        style: TextStyle(
                          fontSize: 48,
                          color: AppColors.crimson,
                          shadows: [
                            Shadow(
                              color: AppColors.crimson.withValues(alpha: 0.5),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'outside the bag',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mauve.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          // Palette swatches — visual brand stamp
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 4),
              _PaletteStamp(
                colors: [
                  Color(0xFF000000),
                  Color(0xFF660020),
                  Color(0xFF890092),
                ],
                label: 'I',
              ),
              SizedBox(height: 6),
              _PaletteStamp(
                colors: [
                  Color(0xFF000000),
                  Color(0xFF5C2420),
                  Color(0xFFCB2B2B),
                ],
                label: 'II',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: GestureDetector(
        onTap: () => _pickImage(ImageSource.gallery),
        onTapDown: (_) => setState(() => _isHoveringDrop = true),
        onTapUp: (_) => setState(() => _isHoveringDrop = false),
        onTapCancel: () => setState(() => _isHoveringDrop = false),
        child: AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, child) {
            final glow = _isHoveringDrop ? 1.0 : _glowAnim.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: AppColors.abyss,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.crimson.withValues(
                    alpha: 0.18 + glow * 0.22,
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.crimson.withValues(
                      alpha: 0.06 + glow * 0.08,
                    ),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.mauve.withValues(
                      alpha: 0.03 + glow * 0.04,
                    ),
                    blurRadius: 60,
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
                duration: const Duration(milliseconds: 250),
                child:
                    _isPickingFile
                        ? const _LoadingIndicator(key: ValueKey('loading'))
                        : const _MilkBagIcon(key: ValueKey('icon'), size: 96),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.crypt,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'TAP TO SELECT IMAGE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.2,
                    color: AppColors.dust,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PNG  ·  JPG  ·  JPEG',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.ash,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: _SourceButton(
              icon: Icons.photo_library_outlined,
              label: 'GALLERY',
              onTap:
                  _isPickingFile ? null : () => _pickImage(ImageSource.gallery),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SourceButton(
              icon: Icons.camera_alt_outlined,
              label: 'CAMERA',
              onTap:
                  _isPickingFile ? null : () => _pickImage(ImageSource.camera),
              accent: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'v1.0.0 · ViaXTrace',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.ember,
              letterSpacing: 0.4,
            ),
          ),
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        i == 0
                            ? AppColors.crimson
                            : AppColors.crimson.withValues(
                              alpha: 0.3 - i * 0.1,
                            ),
                    boxShadow:
                        i == 0
                            ? [
                              BoxShadow(
                                color: AppColors.crimson.withValues(alpha: 0.7),
                                blurRadius: 6,
                              ),
                            ]
                            : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Palette Stamp widget ─────────────────────────────────────────────────────

class _PaletteStamp extends StatelessWidget {
  const _PaletteStamp({required this.colors, required this.label});
  final List<Color> colors;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        'MILK $label',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.ash,
          fontSize: 8,
          letterSpacing: 0.6,
        ),
      ),
      const SizedBox(width: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Row(
          children:
              colors
                  .map((c) => Container(width: 8, height: 22, color: c))
                  .toList(),
        ),
      ),
    ],
  );
}

// ── Source button ─────────────────────────────────────────────────────────────

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
    final border = widget.accent ? AppColors.crimson : AppColors.border;
    final iconColor = widget.accent ? AppColors.chalk : AppColors.dust;
    final labelColor = widget.accent ? AppColors.chalk : AppColors.dust;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52,
        decoration: BoxDecoration(
          color:
              _pressed
                  ? (widget.accent ? AppColors.maroon : AppColors.vessel)
                  : bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: widget.accent ? 0 : 1),
          boxShadow:
              widget.accent && !_pressed
                  ? [
                    BoxShadow(
                      color: AppColors.crimson.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Opacity(
          opacity: disabled ? 0.4 : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: labelColor,
                  letterSpacing: 1.0,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading indicator ─────────────────────────────────────────────────────────

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 28,
    height: 28,
    child: CircularProgressIndicator(
      color: AppColors.crimson,
      strokeWidth: 1.5,
    ),
  );
}

// ── Milk Bag Icon ─────────────────────────────────────────────────────────────

class _MilkBagIcon extends StatelessWidget {
  const _MilkBagIcon({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size * 1.2,
    child: CustomPaint(painter: _MilkBagPainter()),
  );
}

class _MilkBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft shadow beneath bag
    final shadowPaint =
        Paint()
          ..color = AppColors.crimson.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final shadowPath =
        Path()
          ..moveTo(w * 0.14, h * 0.28)
          ..lineTo(w * 0.03, h * 0.95)
          ..lineTo(w * 0.97, h * 0.95)
          ..lineTo(w * 0.86, h * 0.28)
          ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Bag body
    final bagPaint =
        Paint()
          ..color = AppColors.crimson
          ..style = PaintingStyle.fill;
    final bagPath =
        Path()
          ..moveTo(w * 0.14, h * 0.28)
          ..lineTo(w * 0.03, h * 0.92)
          ..quadraticBezierTo(w * 0.03, h * 0.96, w * 0.07, h * 0.96)
          ..lineTo(w * 0.93, h * 0.96)
          ..quadraticBezierTo(w * 0.97, h * 0.96, w * 0.97, h * 0.92)
          ..lineTo(w * 0.86, h * 0.28)
          ..close();
    canvas.drawPath(bagPath, bagPaint);

    // Inner highlight (left edge lighter band)
    final highlightPaint =
        Paint()
          ..color = AppColors.chalk.withValues(alpha: 0.05)
          ..style = PaintingStyle.fill;
    final highlightPath =
        Path()
          ..moveTo(w * 0.14, h * 0.28)
          ..lineTo(w * 0.03, h * 0.92)
          ..lineTo(w * 0.18, h * 0.92)
          ..lineTo(w * 0.26, h * 0.28)
          ..close();
    canvas.drawPath(highlightPath, highlightPaint);

    // Seal / top clamp
    final sealPaint = Paint()..color = AppColors.maroon;
    final sealRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.07, h * 0.17, w * 0.86, h * 0.13),
      const Radius.circular(3),
    );
    canvas.drawRRect(sealRRect, sealPaint);

    // Accent stripe on seal
    final stripeGradient =
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.mauve.withValues(alpha: 0.0),
              AppColors.mauve,
              AppColors.mauve.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(w * 0.07, h * 0.21, w * 0.86, h * 0.04));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.21, w * 0.80, h * 0.04),
        const Radius.circular(1),
      ),
      stripeGradient,
    );

    // Eyes — void squares with subtle border
    final eyePaint = Paint()..color = AppColors.void_;
    final eyeBorderPaint =
        Paint()
          ..color = AppColors.abyss
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final leftEye = Rect.fromLTWH(w * 0.22, h * 0.53, w * 0.18, h * 0.16);
    final rightEye = Rect.fromLTWH(w * 0.60, h * 0.53, w * 0.18, h * 0.16);
    canvas.drawRect(leftEye, eyePaint);
    canvas.drawRect(rightEye, eyePaint);
    canvas.drawRect(leftEye, eyeBorderPaint);
    canvas.drawRect(rightEye, eyeBorderPaint);

    // Subtle mouth curve
    final mouthPaint =
        Paint()
          ..color = AppColors.maroon
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;
    final mouthPath =
        Path()
          ..moveTo(w * 0.33, h * 0.76)
          ..quadraticBezierTo(w * 0.50, h * 0.83, w * 0.67, h * 0.76);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(_MilkBagPainter old) => false;
}
