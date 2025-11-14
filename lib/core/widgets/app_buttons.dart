// widgets/app_button.dart

import 'package:flutter/material.dart';
import 'package:inventory_tracker/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final IconData? icon;
  final double iconSize;
  final bool fullWidth;
  final bool isElevated;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.width,
    this.borderRadius = 15,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.icon,
    this.iconSize = 20,
    this.fullWidth = true,
    this.isElevated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, size: iconSize, color: textColor ?? Colors.black),
        if (icon != null) const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor ?? Colors.black,
          ),
        ),
      ],
    );

    Widget button = Container(
      width: fullWidth ? double.infinity : width,
      height: height ?? 50,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isElevated
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: Center(child: content),
        ),
      ),
    );

    // Wrap in Padding if needed for elevation shadow
    if (isElevated) {
      button = Padding(
        padding: const EdgeInsets.all(2),
        child: button,
      );
    }

    return button;
  }
}