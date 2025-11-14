import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class DirectRoomOption extends StatelessWidget {
  final bool isSelected;
  final String subtitle;
  final VoidCallback onTap;

  const DirectRoomOption({
    super.key,
    required this.isSelected,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
            vertical: 8,
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
              Icons.meeting_room,
              color: isSelected ? Colors.black : colors.primary,
              size: 24,
            ),
          ),
          title: Text(
            'Directly in Room',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
            ),
          ),
          trailing: Icon(
            isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
            color: isSelected ? colors.primary : colors.textSecondary,
            size: isSelected ? 24 : 16,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

