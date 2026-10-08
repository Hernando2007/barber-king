import 'package:flutter/material.dart';
import '../../core/colors.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primary,
            ),
          )
        else
          const SizedBox(width: 48),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actions.isEmpty)
          const SizedBox(width: 48)
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions,
          ),
      ],
    );
  }
}

class BackButtonHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const BackButtonHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: title,
      onBack: onBack ?? () => Navigator.pop(context),
    );
  }
}

class ScreenPadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ScreenPadding({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

class BottomSafeSpace extends StatelessWidget {
  final double height;

  const BottomSafeSpace({
    super.key,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
