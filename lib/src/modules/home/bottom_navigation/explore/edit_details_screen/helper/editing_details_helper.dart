import 'package:banner_app/src/core/controller/template_editor_controller.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';

// Helper functions and widgets of details screen

// Function to handle back navigation
Future<bool> onWillPop(
    BuildContext context, TemplateEditorController controller) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
              'Do you want to discard changes, save as draft, or continue editing?'),
          actions: [
            TextButton(
              onPressed: () {
                controller.resetState();
                Navigator.of(context).pop(true);
              },
              child: const Text('Discard Changes'),
            ),
            TextButton(
              onPressed: () {
                final draftData = {
                  'timestamp': DateTime.now().toIso8601String(),
                };
                controller.saveDraft();
                Navigator.of(context).pop(true);
              },
              child: const Text('Save Draft'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Continue Editing'),
            ),
          ],
        ),
      ) ??
      false;
}

// icon resubale for text option
Widget buildTextOptionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          child: Icon(icon, size: 24, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );
}

Widget buildColorButton({required Color color, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

Widget buildGradientButton(
    {required Gradient gradient, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

// ######################################################################
void showFontFamilyPicker(BuildContext context) {
  final controller = Get.find<TemplateEditorController>();

  if (controller.selectedElementId.value.isEmpty) return;

  final List<String> fonts = [
    'Roboto',
    'Lobster',
    'Pacifico',
    'Poppins',
    'Montserrat',
    'Oswald',
    'Dancing Script',
    'Raleway',
    'Merriweather',
    'Open Sans',
    'Bebas Neue'
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: fonts.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () {
              controller.updateSelectedFontFamily(fonts[index]);
              Get.back();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.darkGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fonts[index],
                    style: GoogleFonts.getFont(
                      fonts[index],
                      fontSize: 16,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

//######################################################## fontsized increase decreased
void showFontSizeSlider(
    BuildContext context, TemplateEditorController controller) {
  if (controller.selectedElementId.value.isEmpty) return; // No element selected

  // Find the selected text element
  final selectedElement = controller.elements.firstWhereOrNull(
    (e) => e['id'] == controller.selectedElementId.value,
  );

  if (selectedElement == null || selectedElement['type'] != 'text') return;

  double currentSize = selectedElement['fontSize']?.toDouble() ?? 24.0;

  showModalBottomSheet(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Container(
        height: 72, // Compact size
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, size: 30),
                onPressed: () => Get.back(), // Close modal with GetX
              ),
            ),

            /// Centered Text & Slider
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Obx(() => Text(
                        "Size: ${controller.elements.firstWhereOrNull(
                              (e) =>
                                  e['id'] == controller.selectedElementId.value,
                            )?['fontSize']?.round() ?? 24}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                ),
                Slider(
                  activeColor: AppColor.darkGreen,
                  value: currentSize,
                  min: 8,
                  max: 120,
                  divisions: 84,
                  label: currentSize.round().toString(),
                  onChanged: (value) {
                    setState(() => currentSize = value);
                    controller.updateSelectedTextSize(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// #####################################################################################################
// change colors and gradient for text

class TextColorPickerBottomSheet extends StatefulWidget {
  final Function({Color? color, LinearGradient? gradient}) onBackgroundSelected;
  const TextColorPickerBottomSheet(
      {super.key, required this.onBackgroundSelected});

  @override
  TextColorPickerBottomSheetState createState() =>
      TextColorPickerBottomSheetState();
}

class TextColorPickerBottomSheetState
    extends State<TextColorPickerBottomSheet> {
  bool isSolidColorSelected = true; // Tracks Solid Color or Gradient selection

  @override
  Widget build(
    BuildContext context,
  ) {
    final TemplateEditorController controller =
        Get.find<TemplateEditorController>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle Buttons: Solid Color or Gradient
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionButton(
                icon: Icons.color_lens,
                label: "Solid Color",
                isSelected: isSolidColorSelected,
                onTap: () {
                  setState(() {
                    isSolidColorSelected = true;
                  });
                },
              ),
              _buildOptionButton(
                icon: Icons.gradient,
                label: "Gradient",
                isSelected: !isSolidColorSelected,
                onTap: () {
                  setState(() {
                    isSolidColorSelected = false;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Show Colors or Gradients
          isSolidColorSelected
              ? _buildSolidColors(controller)
              : _buildGradients(controller),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.darkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradients(TemplateEditorController controller) {
    final List<LinearGradient> gradients = [
      const LinearGradient(colors: [Colors.red, Colors.orange]),
      const LinearGradient(colors: [Colors.blue, Colors.purple]),
      const LinearGradient(colors: [Colors.green, Colors.teal]),
      const LinearGradient(colors: [Colors.yellow, Colors.orange]),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.pink, Colors.purple, Colors.black, Colors.blue],
      ),
      const LinearGradient(colors: [Colors.indigo, Colors.blue]),
      const LinearGradient(colors: [Colors.teal, Colors.green]),
      const LinearGradient(colors: [Colors.orange, Colors.red]),
      const LinearGradient(colors: [Colors.purple, Colors.pink]),
      const LinearGradient(colors: [Colors.brown, Colors.orange]),
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gradients.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Fix: Properly handle text gradient updates
              if (controller.selectedElementId.value.isNotEmpty) {
                controller.updateSelectedTextGradient(gradients[index]);
              } else {
                const SizedBox();
              }
              Get.back();
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: gradients[index],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSolidColors(TemplateEditorController controller) {
    final List<Color> solidColors = [
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: solidColors.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Fix: Always update text color when element is selected
              if (controller.selectedElementId.value.isNotEmpty) {
                controller.updateSelectedTextColor(solidColors[index]);
              } else {
                const SizedBox();
              }
              Get.back();
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: solidColors[index],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BgColorPickerBottomSheet extends StatefulWidget {
  final Function({Color? color, LinearGradient? gradient}) onBackgroundSelected;
  const BgColorPickerBottomSheet(
      {super.key, required this.onBackgroundSelected});

  @override
  BgColorPickerBottomSheetState createState() =>
      BgColorPickerBottomSheetState();
}

class BgColorPickerBottomSheetState extends State<BgColorPickerBottomSheet> {
  bool isSolidColorSelected = true; // Tracks Solid Color or Gradient selection

  @override
  Widget build(
    BuildContext context,
  ) {
    final TemplateEditorController controller =
        Get.find<TemplateEditorController>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle Buttons: Solid Color or Gradient
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bgbuildOptionButton(
                icon: Icons.color_lens,
                label: "Solid Color",
                isSelected: isSolidColorSelected,
                onTap: () {
                  setState(() {
                    isSolidColorSelected = true;
                  });
                },
              ),
              _bgbuildOptionButton(
                icon: Icons.gradient,
                label: "Gradient",
                isSelected: !isSolidColorSelected,
                onTap: () {
                  setState(() {
                    isSolidColorSelected = false;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Show Colors or Gradients
          isSolidColorSelected
              ? _bgbuildSolidColors(controller)
              : _bgbuildGradients(controller),
        ],
      ),
    );
  }

  Widget _bgbuildOptionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.darkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bgbuildGradients(TemplateEditorController controller) {
    final List<LinearGradient> gradients = [
      const LinearGradient(colors: [Colors.red, Colors.orange]),
      const LinearGradient(colors: [Colors.blue, Colors.purple]),
      const LinearGradient(colors: [Colors.green, Colors.teal]),
      const LinearGradient(colors: [Colors.yellow, Colors.orange]),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.pink, Colors.purple, Colors.black, Colors.blue],
      ),
      const LinearGradient(colors: [Colors.indigo, Colors.blue]),
      const LinearGradient(colors: [Colors.teal, Colors.green]),
      const LinearGradient(colors: [Colors.orange, Colors.red]),
      const LinearGradient(colors: [Colors.purple, Colors.pink]),
      const LinearGradient(colors: [Colors.brown, Colors.orange]),
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gradients.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              controller.updateBackgroundGradient(gradients[index]);

              Get.back();
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: gradients[index],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bgbuildSolidColors(TemplateEditorController controller) {
    final List<Color> solidColors = [
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: solidColors.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              controller.updateBackgroundColor(solidColors[index]);

              Get.back();
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: solidColors[index],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}
