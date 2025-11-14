import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class RoomCounterCard extends StatelessWidget {
  final String roomName;
  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const RoomCounterCard({
    super.key,
    required this.roomName,
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colors.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            roomName,
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  color: colors.primary,
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

