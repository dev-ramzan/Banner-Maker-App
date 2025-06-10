import 'package:banner_app/src/core/common/app_button.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/edit_details_screen.dart';
import 'package:flutter/material.dart';

class EditScreen extends StatelessWidget {
  final String imagePath;
  final String templateId;

  const EditScreen({
    super.key,
    required this.imagePath,
    required this.templateId,
  });

  // navigate screen
  void _navigateToEditingScreen(BuildContext context) {
    final progressNotifier = ValueNotifier<double>(0.0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Template is loading...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<double>(
                valueListenable: progressNotifier,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    minHeight: 6,
                    value: value,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColor.darkGreen),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    // delay of loading templates
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      progressNotifier.value += 0.1;
      return progressNotifier.value < 1.0; //
    }).then((_) {
      Navigator.pop(context);

      // Navigate to the EditingDetailsScreen once loading is done
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditingDetailsScreen(
            templateId: templateId,
          ),
        ),
      );
    });
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
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: 16, top: 5, left: 5, right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                        ),
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
