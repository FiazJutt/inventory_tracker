import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class SuggestionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SuggestionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimary : colors.primary,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? colors.primary
              : colors.primary.withOpacity(0.25),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

