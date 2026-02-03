import 'package:flutter/material.dart';

/// Botão genérico com ícone que pode ser usado em toda a aplicação
class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsets margin;
  final bool showBorder;

  const IconButtonWidget({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.tooltip,
    this.size = 50.0,
    this.iconSize = 24.0,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? Colors.blue[700];
    // ignore: unused_local_variable
    final effectiveUnselectedColor = unselectedColor ?? Colors.grey[800];
    
    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isSelected ? effectiveSelectedColor : Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius),
          border: showBorder ? Border.all(
            color: isSelected ? (selectedColor ?? Colors.blue) : Colors.transparent,
            width: 2,
          ) : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}