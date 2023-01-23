import 'package:flutter/material.dart';

class ErrorWidgetScreen extends StatelessWidget {
  final String text;
  const ErrorWidgetScreen({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text),
    );
  }
}
