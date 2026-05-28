import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String text;
  final Color? textColor;

  const MyText({
  super.key,
  required this.text,
  this.textColor,
});

  @override
  Widget build(BuildContext context) {
    return Text(
        text,
        style: TextStyle(
            color: textColor ?? Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
        ),
    );
  }
}
