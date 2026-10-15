import 'package:flutter/material.dart';

class OnboardingWelcomeText extends StatelessWidget {
  const OnboardingWelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Selamat datang',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.0,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          'Atur Keuanganmu, Hidup Lebih Mudah',
          style: TextStyle(
            color: Color(0xFFD6C8E8),
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
