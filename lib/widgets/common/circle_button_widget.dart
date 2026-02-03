import 'package:flutter/material.dart';

/// Botão circular genérico (usado principalmente para cores)
class CircleButtonWidget extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;
  final double selectedBorderWidth;
  final double unselectedBorderWidth;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;
  final EdgeInsets margin;
  final bool showShadow;
  final Widget? child;

  const CircleButtonWidget({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.size = 36.0,
    this.selectedBorderWidth = 3.0,
    this.unselectedBorderWidth = 1.0,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.showShadow = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected 
              ? (selectedBorderColor ?? Colors.white)
              : (unselectedBorderColor ?? Colors.grey[700]!),
            width: isSelected ? selectedBorderWidth : unselectedBorderWidth,
          ),
          boxShadow: (showShadow && isSelected) ? [
            BoxShadow(
              color: Color.fromRGBO(
                (color.r * 255.0).round().clamp(0, 255),
                (color.g * 255.0).round().clamp(0, 255),
                (color.b * 255.0).round().clamp(0, 255),
                0.5,
              ),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: child,
      ),
    );
  }
}