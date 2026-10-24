import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/config/api_config.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  final IconData fallbackIcon;

  const AppAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 24,
    this.fallbackIcon = Icons.person_rounded,
  });

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final resolved = ApiConfig.resolveMedia(photoUrl);
    final fallback = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.goldGradient,
      ),
      alignment: Alignment.center,
      child: _initials.isEmpty
          ? Icon(
              fallbackIcon,
              color: AppColors.black,
              size: radius * .9,
            )
          : Text(
              _initials,
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
                fontSize: radius * .72,
              ),
            ),
    );

    if (resolved == null) {
      return fallback;
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: resolved,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          width: radius * 2,
          height: radius * 2,
          color: AppColors.surface,
        ),
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
