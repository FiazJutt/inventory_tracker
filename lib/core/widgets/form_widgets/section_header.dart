import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: colors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
        ] else ...[
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}