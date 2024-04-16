import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String text;
  final double size;
  final bool overflow;
  final bool bold;
  final Color color;
  const MyText({super.key, required this.text, required this.size, required this.overflow, required this.bold, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: (bold)?FontWeight.bold : FontWeight.normal,
        overflow: (overflow) ?TextOverflow.ellipsis : TextOverflow.visible,
        color: color,
      ),
    );
  }
}