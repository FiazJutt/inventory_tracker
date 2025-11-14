import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final bool required;
  final String hint;
  final String Function(T)? itemLabel;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    this.required = false,
    this.hint = 'Select an option',
    this.itemLabel,
  });

  String _getItemLabel(T item) {
    if (itemLabel != null) {
      return itemLabel!(item);
    }
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: colors.error,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: colors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    hint: Text(
                      hint,
                      style: TextStyle(
                        color: colors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                    isExpanded: true,
                    dropdownColor: colors.surface,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colors.textSecondary,
                    ),
                    items: items.map((T item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(_getItemLabel(item)),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}