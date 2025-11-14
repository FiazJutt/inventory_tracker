import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class LocationBadge extends StatelessWidget {
  final String location;

  const LocationBadge({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 16,
            color: colors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            location,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

