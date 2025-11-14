import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'package:inventory_tracker/models/room_model.dart';

class LocationRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const LocationRoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.meeting_room,
            color: colors.primary,
            size: 22,
          ),
        ),
        title: Text(
          room.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            room.location,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

