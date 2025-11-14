import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

enum HomeViewType { rooms, containers, items, locations }

class FilterSegmentControl extends StatelessWidget {
  final HomeViewType selectedView;
  final Function(HomeViewType) onViewChanged;

  const FilterSegmentControl({
    super.key,
    required this.selectedView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegment(
            context,
            label: 'Rooms',
            icon: Icons.door_front_door_outlined,
            viewType: HomeViewType.rooms,
            colors: colors,
          ),
          _buildSegment(
            context,
            label: 'Containers',
            icon: Icons.inventory_2_outlined,
            viewType: HomeViewType.containers,
            colors: colors,
          ),
          _buildSegment(
            context,
            label: 'Items',
            icon: Icons.category_outlined,
            viewType: HomeViewType.items,
            colors: colors,
          ),
          _buildSegment(
            context,
            label: 'Locations',
            icon: Icons.location_on_outlined,
            viewType: HomeViewType.locations,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context, {
    required String label,
    required IconData icon,
    required HomeViewType viewType,
    required AppColorsTheme colors,
  }) {
    final isSelected = selectedView == viewType;

    return Expanded(
      child: GestureDetector(
        onTap: () => onViewChanged(viewType),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? colors.onPrimary : colors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? colors.onPrimary : colors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

