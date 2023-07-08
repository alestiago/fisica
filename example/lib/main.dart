import 'package:fisica/fisica.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const _MyApp());
}

class _MyApp extends StatelessWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context) {
    return World(
      child: Body(
        child: Align(
          child: ColoredBox(
            color: Color(0xff00ff00),
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );
  }
}
