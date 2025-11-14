import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String? suffixText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixText,
    this.suffixText,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
          onChanged: onChanged,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colors.textSecondary.withOpacity(0.5),
            ),
            filled: true,
            fillColor: enabled ? colors.surface : colors.surface.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.error,
                width: 2,
              ),
            ),
            prefixIcon: Icon(
              icon,
              color: colors.textSecondary,
              size: 20,
            ),
            prefixText: prefixText,
            suffixText: suffixText,
            prefixStyle: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
            ),
            suffixStyle: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
          validator: validator ??
              (required
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    }
                  : null),
        ),
      ],
    );
  }
}