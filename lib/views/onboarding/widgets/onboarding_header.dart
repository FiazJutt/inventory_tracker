import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class OnboardingHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const OnboardingHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        // const SizedBox(height: 60),
      ],
    );
  }
}

