import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';
import 'package:a_milk_filter/features/editor/editor_screen.dart';
import 'package:a_milk_filter/shared/widgets/banner_ad_widget.dart';
import 'package:a_milk_filter/shared/widgets/scanline_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _picker = ImagePicker();
  bool _isPickingFile = false;

  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryAnim;
  late final AnimationController _bagCtrl;
  late final Animation<double> _bagAnim;
  late final AnimationController _ctaPulse;
  late final Animation<double> _ctaAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4400),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);

    _bagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
    _bagAnim = CurvedAnimation(parent: _bagCtrl, curve: Curves.easeInOut);

    _ctaPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _ctaAnim = CurvedAnimation(parent: _ctaPulse, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _entryCtrl.dispose();
    _bagCtrl.dispose();
    _ctaPulse.dispose();
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
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (_, animation, __, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0, 0.035),
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
    final screenW = mq.size.width;

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── CRT grain ────────────────────────────────────────────────────
          const Positioned.fill(child: ScanlineOverlay(opacity: 0.045)),

          // ── Crimson glow — lower left ─────────────────────────────────────
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Positioned(
              bottom: -screenH * 0.08,
              left: -screenW * 0.20,
              child: _GlowBlob(
                size: screenW * 1.1,
                color: AppColors.crimson,
                opacity: 0.28 + _glowAnim.value * 0.14,
              ),
            ),
          ),

          // ── Mauve glow — upper right ──────────────────────────────────────
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Positioned(
              top: -screenH * 0.06,
              right: -screenW * 0.25,
              child: _GlowBlob(
                size: screenW * 1.0,
                color: AppColors.mauve,
                opacity: 0.22 + (1 - _glowAnim.value) * 0.12,
              ),
            ),
          ),

          // ── Main layout ──────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _entryAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Wordmark block ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
                    child: _WordmarkBlock(),
                  ),

                  // ── Hero bag ────────────────────────────────────────────
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _HeroBag(
                            floatAnim: _bagAnim,
                            isLoading: _isPickingFile,
                          ),
                          const SizedBox(height: 36),
                          _SelectCTA(
                            pulseAnim: _ctaAnim,
                            isLoading: _isPickingFile,
                            onTap: () => _pickImage(ImageSource.gallery),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom actions ──────────────────────────────────────
                  _BottomBar(
                    disabled: _isPickingFile,
                    onGallery: () => _pickImage(ImageSource.gallery),
                    onCamera: () => _pickImage(ImageSource.camera),
                  ),

                  const SizedBox(height: 8),

                  // ── Banner Ad ───────────────────────────────────────────
                  const BannerAdWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glow blob ─────────────────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    ),
  );
}

// ── Wordmark block ────────────────────────────────────────────────────────────

class _WordmarkBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '— OUTSIDE THE BAG',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.ash,
            letterSpacing: 2.4,
            fontSize: 7,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A MILK',
          style: TextStyle(
            fontFamily: 'Courier New',
            fontWeight: FontWeight.w900,
            fontSize: 64,
            height: 0.92,
            letterSpacing: -1.5,
            color: AppColors.chalk,
            shadows: [
              Shadow(
                color: AppColors.mauve.withValues(alpha: 0.35),
                blurRadius: 60,
              ),
            ],
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.crimson, Color(0xFF9B002A)],
          ).createShader(bounds),
          child: const Text(
            'FILTER',
            style: TextStyle(
              fontFamily: 'Courier New',
              fontWeight: FontWeight.w900,
              fontSize: 64,
              height: 0.92,
              letterSpacing: -1.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.crimson, AppColors.mauve, Colors.transparent],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero bag ──────────────────────────────────────────────────────────────────

class _HeroBag extends StatelessWidget {
  const _HeroBag({required this.floatAnim, required this.isLoading});
  final Animation<double> floatAnim;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          color: AppColors.crimson,
          strokeWidth: 1.5,
        ),
      );
    }

    return AnimatedBuilder(
      animation: floatAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -8 + floatAnim.value * 16),
        child: child,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, __) => Container(
              width: 160,
              height: 40,
              margin: const EdgeInsets.only(top: 240),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.crimson.withValues(
                      alpha: 0.30 + floatAnim.value * 0.15,
                    ),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 200,
            height: 248,
            child: CustomPaint(painter: _MilkBagPainter()),
          ),
        ],
      ),
    );
  }
}

// ── Select CTA ────────────────────────────────────────────────────────────────

class _SelectCTA extends StatelessWidget {
  const _SelectCTA({
    required this.pulseAnim,
    required this.isLoading,
    required this.onTap,
  });

  final Animation<double> pulseAnim;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, child) => Opacity(
        opacity: 0.55 + pulseAnim.value * 0.45,
        child: child,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.crimson,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.crimson.withValues(alpha: 0.50),
                blurRadius: 28,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            'SELECT A PHOTO',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.chalk,
              letterSpacing: 2.0,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.divider,
                  AppColors.divider,
                  Colors.transparent,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: _BottomButton(
                  icon: Icons.photo_library_outlined,
                  label: 'GALLERY',
                  onTap: disabled ? null : onGallery,
                  filled: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BottomButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'CAMERA',
                  onTap: disabled ? null : onCamera,
                  filled: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Text(
                'v1.2.0',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.ember,
                  fontSize: 8,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 6),
              Container(width: 1, height: 7, color: AppColors.divider),
              const SizedBox(width: 6),
              Text(
                'ViaXTrace',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.ember,
                  fontSize: 8,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatefulWidget {
  const _BottomButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  State<_BottomButton> createState() => _BottomButtonState();
}

class _BottomButtonState extends State<_BottomButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: Opacity(
          opacity: disabled ? 0.36 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 54,
            decoration: BoxDecoration(
              color: widget.filled
                  ? (_pressed ? AppColors.maroon : AppColors.crimson)
                  : (_pressed
                      ? AppColors.vessel
                      : AppColors.abyss.withValues(alpha: 0.0)),
              borderRadius: BorderRadius.circular(14),
              border: widget.filled
                  ? null
                  : Border.all(color: AppColors.border),
              boxShadow: widget.filled && !_pressed
                  ? [
                      BoxShadow(
                        color: AppColors.crimson.withValues(alpha: 0.40),
                        blurRadius: 24,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.filled ? AppColors.chalk : AppColors.dust,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: widget.filled ? AppColors.chalk : AppColors.dust,
                    letterSpacing: 1.4,
                    fontSize: 11,
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

// ── Milk Bag custom painter ───────────────────────────────────────────────────

class _MilkBagPainter extends CustomPainter {
  const _MilkBagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawPath(
      _bagPath(w, h),
      Paint()
        ..color = AppColors.crimson.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    final bagPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF7A0025),
          AppColors.crimson,
          AppColors.maroon,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(_bagPath(w, h), bagPaint);

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.14, h * 0.27)
        ..lineTo(w * 0.03, h * 0.91)
        ..lineTo(w * 0.19, h * 0.91)
        ..lineTo(w * 0.27, h * 0.27)
        ..close(),
      Paint()
        ..color = AppColors.chalk.withValues(alpha: 0.07)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.07, h * 0.16, w * 0.86, h * 0.13),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.maroon,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.76, h * 0.045),
        const Radius.circular(1.5),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.mauve.withValues(alpha: 0.0),
            AppColors.mauve.withValues(alpha: 1.0),
            AppColors.mauve.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.76, h * 0.045)),
    );

    final crease = Paint()
      ..color = AppColors.maroon.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawLine(Offset(w * 0.35, h * 0.32), Offset(w * 0.27, h * 0.90), crease);
    canvas.drawLine(Offset(w * 0.65, h * 0.32), Offset(w * 0.73, h * 0.90), crease);

    final eyeFill = Paint()..color = AppColors.void_;
    final eyeStroke = Paint()
      ..color = AppColors.abyss
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final leftEye = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.50, w * 0.20, h * 0.18),
      const Radius.circular(2),
    );
    final rightEye = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.60, h * 0.50, w * 0.20, h * 0.18),
      const Radius.circular(2),
    );
    canvas.drawRRect(leftEye, eyeFill);
    canvas.drawRRect(rightEye, eyeFill);
    canvas.drawRRect(leftEye, eyeStroke);
    canvas.drawRRect(rightEye, eyeStroke);

    final mouthPaint = Paint()
      ..color = AppColors.void_
      ..style = PaintingStyle.fill;
    final mouthPath = Path()
      ..moveTo(w * 0.34, h * 0.72)
      ..lineTo(w * 0.42, h * 0.76)
      ..lineTo(w * 0.50, h * 0.72)
      ..lineTo(w * 0.58, h * 0.76)
      ..lineTo(w * 0.66, h * 0.72)
      ..lineTo(w * 0.66, h * 0.76)
      ..lineTo(w * 0.58, h * 0.80)
      ..lineTo(w * 0.50, h * 0.76)
      ..lineTo(w * 0.42, h * 0.80)
      ..lineTo(w * 0.34, h * 0.76)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);
  }

  Path _bagPath(double w, double h) => Path()
    ..moveTo(w * 0.10, h * 0.28)
    ..lineTo(w * 0.00, h * 0.95)
    ..quadraticBezierTo(w * 0.00, h * 1.00, w * 0.07, h * 1.00)
    ..lineTo(w * 0.93, h * 1.00)
    ..quadraticBezierTo(w * 1.00, h * 1.00, w * 1.00, h * 0.95)
    ..lineTo(w * 0.90, h * 0.28)
    ..quadraticBezierTo(w * 0.88, h * 0.20, w * 0.78, h * 0.18)
    ..lineTo(w * 0.22, h * 0.18)
    ..quadraticBezierTo(w * 0.12, h * 0.20, w * 0.10, h * 0.28)
    ..close();

  @override
  bool shouldRepaint(_MilkBagPainter old) => false;
}
