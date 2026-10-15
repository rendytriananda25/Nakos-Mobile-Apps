import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'NAKOS',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 22.0,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
    );
  }
}
