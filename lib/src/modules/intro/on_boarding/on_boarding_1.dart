import 'package:flutter/material.dart';

class OnBoarding1 extends StatelessWidget {
  const OnBoarding1({super.key});

  @override
  Widget build(BuildContext context) {
    // Example: Adjust based on your image
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            // Ensures the image covers the entire screen
            child: Image.asset(
              'assets/images/splash1.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
