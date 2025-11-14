import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class CustomDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final IconData icon;
  final bool required;
  final String? Function(DateTime?)? validator;

  const CustomDateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    required this.icon,
    this.required = false,
    this.validator,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: validator != null && validator!(date) != null
                  ? Border.all(color: colors.error, width: 1)
                  : null,
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
                  child: Text(
                    date != null ? _formatDate(date!) : 'Select date',
                    style: TextStyle(
                      color: date != null
                          ? colors.textPrimary
                          : colors.textSecondary.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (validator != null && validator!(date) != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              validator!(date)!,
              style: TextStyle(
                color: colors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}