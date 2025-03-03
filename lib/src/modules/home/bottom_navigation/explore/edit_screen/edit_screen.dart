import 'package:banner_app/src/core/common/app_button.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/edit_details_screen.dart';
import 'package:flutter/material.dart';

class EditScreen extends StatelessWidget {
  final String imagePath;

  const EditScreen({super.key, required this.imagePath, required});

  // navigate screen
  void _navigateToEditingScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditingDetailsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToEditingScreen(context),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                onPressed: () => _navigateToEditingScreen(context),
              ), //
            ],
          ),
        ),
      ),
    );
  }
}
