import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

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
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
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
          leading: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.crypt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppColors.chalk,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  letterSpacing: 0.8,
                  fontSize: 14,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mauve.withOpacity(0.8),
                    letterSpacing: 0.5,
                    fontSize: 9,
                  ),
                ),
              ],
            ],
          ),
          actions: actions,
        ),
        // Accent gradient rule — 1px, extends edge to edge
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
    ),
  );
}
