import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class LocationSectionHeader extends StatelessWidget {
  final String location;
  final int roomCount;

  const LocationSectionHeader({
    super.key,
    required this.location,
    required this.roomCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: colors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            location.toUpperCase(),
            style: TextStyle(
              color: colors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$roomCount',
              style: TextStyle(
                color: colors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

