import 'package:flutter/material.dart';

class OnBorading3 extends StatelessWidget {
  const OnBorading3({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            // Ensures the image covers the entire screen
            child: Image.asset(
              'assets/images/splash3.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
