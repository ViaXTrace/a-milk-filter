import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// Custom AppBar with gradient accent rule and optional subtitle.
/// Implements [PreferredSizeWidget] for Scaffold integration.
class MilkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MilkAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.void_,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: AppColors.abyss,
            elevation: 0,
            titleSpacing: 0,
            leading: _BackButton(),
            title: _AppBarTitle(title: title, subtitle: subtitle),
            actions: actions != null
                ? [
                    ...actions!,
                    const SizedBox(width: 8),
                  ]
                : null,
          ),
          _AccentRule(),
        ],
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Semantics(
        button: true,
        label: 'Back',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _pressed ? AppColors.vessel : AppColors.crypt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _pressed ? AppColors.borderActive : AppColors.border,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 13,
            color: AppColors.chalk,
          ),
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            letterSpacing: 1.2,
            fontSize: 13,
            color: AppColors.chalk,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 1),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.mauve.withOpacity(0.85),
              letterSpacing: 0.6,
              fontSize: 9,
            ),
          ),
        ],
      ],
    );
  }
}

class _AccentRule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.crimson,
            AppColors.mauve,
            Colors.transparent,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}
