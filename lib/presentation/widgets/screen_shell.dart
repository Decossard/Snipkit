import 'package:flutter/material.dart';

class ScreenShell extends StatelessWidget {
  const ScreenShell({super.key, required this.child, this.scrollable = false});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(child: child);
    }
    return child;
  }
}
