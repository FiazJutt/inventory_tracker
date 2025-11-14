import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/models/container_model.dart';

class ContainerListItem extends StatelessWidget {
  final ContainerModel container;
  final bool isSelected;
  final bool isCurrentLocation;
  final int? itemCount;
  final VoidCallback onTap;

  const ContainerListItem({
    super.key,
    required this.container,
    required this.isSelected,
    this.isCurrentLocation = false,
    this.itemCount,
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
            Icons.inventory_2,
            color: isSelected ? Colors.black : colors.primary,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                container.name,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (isCurrentLocation)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Current',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: itemCount != null && itemCount! > 0
            ? Text(
                '$itemCount item${itemCount == 1 ? '' : 's'}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              )
            : null,
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

