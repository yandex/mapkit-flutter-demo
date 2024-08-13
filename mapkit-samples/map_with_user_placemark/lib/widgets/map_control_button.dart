import 'package:flutter/material.dart';

final class MapControlButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final EdgeInsets margin;
  final double size;
  final VoidCallback? onPressed;

  const MapControlButton({
    super.key,
    required this.icon,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.blue,
    this.margin = EdgeInsets.zero,
    this.size = 28.0,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: IconButton(
        onPressed: onPressed,
        iconSize: size,
        icon: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}
