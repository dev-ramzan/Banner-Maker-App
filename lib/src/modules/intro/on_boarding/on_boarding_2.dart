import 'package:flutter/material.dart';

class OnBoarding2 extends StatelessWidget {
  const OnBoarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            // Ensures the image covers the entire screen
            child: Image.asset(
              'assets/images/splash2.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
