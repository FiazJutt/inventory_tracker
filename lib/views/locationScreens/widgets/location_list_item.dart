import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class LocationListItem extends StatelessWidget {
  final String location;
  final bool isSelected;
  final VoidCallback onTap;

  const LocationListItem({
    super.key,
    required this.location,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? colors.primary.withOpacity(0.1)
            : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? colors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary
                : colors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.location_on,
            color: isSelected ? Colors.black : colors.primary,
            size: 24,
          ),
        ),
        title: Text(
          location,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
          color: isSelected ? colors.primary : colors.textSecondary,
          size: isSelected ? 24 : 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

