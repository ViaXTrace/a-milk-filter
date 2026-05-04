import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// Custom AppBar with a crimson→mauve gradient accent rule at the bottom.
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            color: AppColors.chalk,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mauve,
                    letterSpacing: 0.4,
                  ),
                ),
            ],
          ),
          actions: actions,
        ),
        // Accent gradient rule
        Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.crimson, AppColors.mauve, Colors.transparent],
            ),
          ),
        ),
      ],
    ),
  );
}
