import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/models/room_model.dart';

class RoomListItem extends StatelessWidget {
  final Room room;
  final bool isSelected;
  final bool isCurrentRoom;
  final int? containerCount;
  final VoidCallback onTap;

  const RoomListItem({
    super.key,
    required this.room,
    required this.isSelected,
    this.isCurrentRoom = false,
    this.containerCount,
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
            Icons.meeting_room,
            color: isSelected ? Colors.black : colors.primary,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                room.name,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (isCurrentRoom)
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  room.location,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (containerCount != null && containerCount! > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$containerCount container${containerCount == 1 ? '' : 's'}',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
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

