import 'package:flutter/material.dart';

class CustomTopicHeader extends StatelessWidget {
  final String label;

  const CustomTopicHeader({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 1.1,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
