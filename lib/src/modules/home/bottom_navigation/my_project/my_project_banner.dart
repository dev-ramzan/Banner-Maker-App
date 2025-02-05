import 'package:flutter/material.dart';

class MyProjectBanner extends StatelessWidget {
  const MyProjectBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green,
        child: Text('my project sheeet'),
      ),
    );
  }
}
