import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';
import 'filter_segment_control.dart';

class EmptyStateWidget extends StatelessWidget {
  final HomeViewType viewType;
  final bool isSearching;

  const EmptyStateWidget({
    super.key,
    required this.viewType,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    String message;
    IconData icon;

    if (isSearching) {
      message = 'No results found';
      icon = Icons.search_off;
    } else {
      switch (viewType) {
        case HomeViewType.rooms:
          message = 'No rooms found. Add a room to get started.';
          icon = Icons.door_front_door_outlined;
          break;
        case HomeViewType.containers:
          message = 'No containers found. Add a container to get started.';
          icon = Icons.inventory_2_outlined;
          break;
        case HomeViewType.items:
          message = 'No items found. Add an item to get started.';
          icon = Icons.category_outlined;
          break;
        case HomeViewType.locations:
          message = 'No locations found. Add a location to get started.';
          icon = Icons.location_on_outlined;
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: colors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

