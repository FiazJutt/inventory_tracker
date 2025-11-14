import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

enum ButtonType { primary, secondary, outline, danger, success }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final ButtonType type;
  final bool isFullWidth;
  final bool isLoading;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.isFullWidth = false,
    this.isLoading = false,
    this.height,
    this.width,
    this.padding,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.surface;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.danger:
        return Colors.red;
      case ButtonType.success:
        return Colors.green;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.black;
      case ButtonType.secondary:
        return AppColors.textPrimary;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.success:
        return Colors.white;
    }
  }

  BorderSide? _getBorder() {
    if (type == ButtonType.outline) {
      return const BorderSide(
        color: AppColors.primary,
        width: 2,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: Size(width ?? 0, height ?? 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: _getBorder() ?? BorderSide.none,
        ),
        elevation: type == ButtonType.outline ? 0 : 2,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
              ],
            ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}