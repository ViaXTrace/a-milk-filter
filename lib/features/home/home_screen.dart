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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  bool _isPickingFile = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingFile) return;
    setState(() => _isPickingFile = true);
    try {
      final xFile = await _picker.pickImage(source: source);
      if (xFile != null && mounted) {
        await Navigator.of(context).push(_fadeRoute(
          EditorScreen(imageFile: File(xFile.path)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  PageRoute<void> _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 380),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Stack(
        children: [
          const ScanlineOverlay(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(),
                Expanded(child: _DropZone(
                  pulseAnimation: _pulseAnimation,
                  onTap: () => _pickImage(ImageSource.gallery),
                  isLoading: _isPickingFile,
                )),
                _SourceRow(
                  onGallery: () => _pickImage(ImageSource.gallery),
                  onCamera: () => _pickImage(ImageSource.camera),
                  enabled: !_isPickingFile,
                ),
                _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 36, height: 2, color: AppColors.crimson),
        const SizedBox(height: 14),
        Text(
          'A MILK\nFILTER',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            shadows: [Shadow(
              color: AppColors.crimson.withOpacity(0.5),
              blurRadius: 24,
            )],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'OUTSIDE THE BAG',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.mauve,
            letterSpacing: 0.7,
          ),
        ),
      ],
    ),
  );
}

class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.pulseAnimation,
    required this.onTap,
    required this.isLoading,
  });

  final Animation<double> pulseAnimation;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) => Container(
          width: 216,
          height: 216,
          decoration: BoxDecoration(
            color: AppColors.abyss,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.crimson.withOpacity(pulseAnimation.value * 0.55),
              width: 1,
            ),
            boxShadow: [BoxShadow(
              color: AppColors.crimson.withOpacity(pulseAnimation.value * 0.12),
              blurRadius: 32,
            )],
          ),
          child: child,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.crimson, strokeWidth: 1.5,
                    ),
                  )
                : const _MilkBagIcon(size: 68),
            const SizedBox(height: 20),
            Text(
              'OPEN FILE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'PNG  ·  JPG  ·  JPEG',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.onGallery,
    required this.onCamera,
    required this.enabled,
  });

  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Row(
      children: [
        Expanded(child: _SourceButton(
          icon: Icons.photo_library_outlined,
          label: 'GALLERY',
          onTap: enabled ? onGallery : null,
        )),
        const SizedBox(width: 10),
        Expanded(child: _SourceButton(
          icon: Icons.camera_alt_outlined,
          label: 'CAMERA',
          onTap: enabled ? onCamera : null,
        )),
      ],
    ),
  );
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.crypt,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.dust),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    ),
  );
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('v1.0.0 · ViaXTrace',
          style: Theme.of(context).textTheme.labelSmall),
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(
            color: AppColors.crimson,
            borderRadius: BorderRadius.circular(1),
            boxShadow: [BoxShadow(
              color: AppColors.crimson.withOpacity(0.8), blurRadius: 6,
            )],
          ),
        ),
      ],
    ),
  );
}

class _MilkBagIcon extends StatelessWidget {
  const _MilkBagIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size * 1.15,
    child: CustomPaint(painter: _MilkBagPainter()),
  );
}

class _MilkBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bag body
    final bagPath = Path()
      ..moveTo(w * 0.15, h * 0.26)
      ..lineTo(w * 0.04, h * 0.94)
      ..lineTo(w * 0.96, h * 0.94)
      ..lineTo(w * 0.85, h * 0.26)
      ..close();
    canvas.drawPath(bagPath, Paint()..color = AppColors.crimson.withOpacity(0.92));

    // Seal strip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.18, w * 0.84, h * 0.10),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.maroon,
    );

    // Accent line on seal
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.11, h * 0.20, w * 0.78, h * 0.04),
        const Radius.circular(1),
      ),
      Paint()..color = AppColors.mauve.withOpacity(0.7),
    );

    // Eyes (void squares)
    final eyePaint = Paint()..color = AppColors.abyss;
    final eyeW = w * 0.12;
    final eyeH = w * 0.13;
    canvas.drawRect(Rect.fromLTWH(w * 0.24, h * 0.53, eyeW, eyeH), eyePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.60, h * 0.53, eyeW, eyeH), eyePaint);

    // Subtle mouth
    final mouthPath = Path()
      ..moveTo(w * 0.34, h * 0.74)
      ..quadraticBezierTo(w * 0.50, h * 0.80, w * 0.66, h * 0.74);
    canvas.drawPath(mouthPath, Paint()
      ..color = AppColors.abyss
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_MilkBagPainter old) => false;
}
