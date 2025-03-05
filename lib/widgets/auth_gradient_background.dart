import 'package:flutter/material.dart';

class AuthGradientBackground extends StatelessWidget {
  final Widget child;

  const AuthGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF673AB7), // Deep Purple
      ),
      child: child,
    );
  }
} 