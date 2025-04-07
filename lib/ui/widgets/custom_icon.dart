import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const CustomIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size + (size*0.4),
        height: size + (size*0.4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: size,
          color: color ?? Theme.of(context).colorScheme.primary,
        ));
  }
}
