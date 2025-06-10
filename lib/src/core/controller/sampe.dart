// if (templateId != null) {
      //   controller.shouldResetOnExit.value = true;
      //   controller.prepareForEditing();
      //   controller.loadTemplate(templateId);
      // // }
      
   


      //editing details screen code for loading templates

// import 'package:banner_app/src/core/controller/category_controller.dart';
// import 'package:banner_app/src/data/models/category_model.dart';
// import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/text/text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:gallery_saver_plus/gallery_saver.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:image_picker/image_picker.dart';
// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:path_provider/path_provider.dart';

// class TemplateEditorScreen extends StatefulWidget {
//   final Color? backgroundColor;
//   final String? jsonImage;
//   final VoidCallback? onTextElementSelected;
//   final Template? template;
//   const TemplateEditorScreen(
//       {super.key,
//       required this.backgroundColor,
//       required this.jsonImage,
//       required this.onTextElementSelected,
//       this.template});
//   @override
//   TemplateEditorScreenState createState() => TemplateEditorScreenState();
// }

// class TemplateEditorScreenState extends State<TemplateEditorScreen> {
//   final GlobalKey _templateKey = GlobalKey();
//   final CategoryController categoryController = Get.find();
//   List<Map<String, dynamic>> elements = [];
//   String? selectedElementId;
//   String? profilePicture;
//   TextEditingController textController = TextEditingController();
//   bool isEditingText = false;
//   String? backgroundImagePath;
//   // Undo/Redo stacks ........
//   List<List<Map<String, dynamic>>> undoStack = [];
//   List<List<Map<String, dynamic>>> redoStack = [];

//   @override
//   void didUpdateWidget(TemplateEditorScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Reset state when the template changes
//     if (widget.template != oldWidget.template) {}
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadTemplate();
//   }

// // here we load json template,,
//   void _loadTemplate() {
//     if (widget.template != null) {
//       setState(() {
//         backgroundImagePath = widget.template!.background;
//         elements = List<Map<String, dynamic>>.from(widget.template!.elements);
//       });
//     }
//   }

//   // make any elements will be duplicate..#######################################
//   void duplicateSelectedElement() {
//     // _saveState();
//     if (selectedElementId == null) return;

//     final selectedElement = elements.firstWhere(
//       (element) => element['id'] == selectedElementId,
//       orElse: () => {},
//     );

//     if (selectedElement.isEmpty) return;

//     String elementType = selectedElement['type'] ?? 'unknown';
//     final newId = '${elementType}_${DateTime.now().millisecondsSinceEpoch}';

//     final copiedElement = Map<String, dynamic>.from(selectedElement);

//     copiedElement['id'] = newId;
//     copiedElement['x'] = (copiedElement['x']) + 20;
//     copiedElement['y'] = (copiedElement['y']) + 20;

//     setState(() {
//       elements.add(copiedElement);
//       selectedElementId = newId;
//     });
//   }

// // save image function#####################################################
//   Future<void> saveTemplateAsImage() async {
//     try {
//       await Future.delayed(const Duration(milliseconds: 500));

//       // Check if the context is null
//       final context = _templateKey.currentContext;
//       if (context == null) {
//         throw Exception("Template key context is null");
//       }

//       // Get the render object
//       final RenderRepaintBoundary boundary =
//           context.findRenderObject() as RenderRepaintBoundary;

//       // Capture the image
//       final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       ("Captured image: ${image.width} x ${image.height}");

//       final ByteData? byteData =
//           await image.toByteData(format: ui.ImageByteFormat.png);

//       if (byteData == null) {
//         throw Exception("Failed to convert image to bytes");
//       }

//       final Uint8List pngBytes = byteData.buffer.asUint8List();

//       final directory = await getExternalStorageDirectory() ??
//           await getApplicationDocumentsDirectory();
//       final String fileName =
//           'banner_${DateTime.now().millisecondsSinceEpoch}.png';
//       final String filePath = '${directory.path}/$fileName';

//       final File file = File(filePath);
//       await file.writeAsBytes(pngBytes);
//       // use package here gallery_saver_plus
//       await GallerySaver.saveImage(filePath);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save template: $e')),
//       );
//     }
//   }

//   // Save the current state to the undo stack and clear red0..################################

//   // Undo functionality
//   void undo() {
//     if (undoStack.isNotEmpty) {
//       redoStack.add(List.from(elements));
//       setState(() {
//         elements = undoStack.removeLast();
//       });
//     }
//   }

//   void redo() {
//     if (redoStack.isNotEmpty) {
//       undoStack.add(List.from(elements));
//       setState(() {
//         elements = redoStack.removeLast();
//       });
//     }
//   }

// // text options##############################################################
//   void updateSelectedTextColor(Color color) {
//     if (selectedElementId == null) return;

//     setState(() {
//       final index = elements.indexWhere((e) => e['id'] == selectedElementId);
//       if (index == -1) return;

//       final element = elements[index];

//       // Update the color for text
//       if (element['type'] == 'text') {
//         elements[index]['color'] = _colorToHex(color);
//         elements[index]['gradient'] = null;
//       }
//     });
//   }

//   String _colorToHex(Color color) {
//     return "#${color.value.toRadixString(16).padLeft(8, '0')}";
//   }

//   void updateSelectedTextGradient(Gradient gradient) {
//     if (selectedElementId == null) return;

//     setState(() {
//       final index = elements.indexWhere((e) => e['id'] == selectedElementId);
//       if (index == -1) return;

//       final element = elements[index];

//       // Update the gradient for text
//       if (element['type'] == 'text') {
//         elements[index]['gradient'] = gradient;
//         elements[index]['color'] = null;
//       }
//     });
//   }

//   // here resize your selected text #######################
//   void updateSelectedTextSize(double newSize) {
//     if (selectedElementId == null) return;
//     setState(() {
//       final index = elements.indexWhere((e) => e['id'] == selectedElementId);
//       if (index != -1 && elements[index]['type'] == 'text') {
//         elements[index]['fontSize'] = newSize;
//       }
//     });
//   }

//   // here update fontfamily ##############################
//   void updateSelectedFontFamily(String newFont) {
//     if (selectedElementId == null) return;
//     setState(() {
//       final index = elements.indexWhere((e) => e['id'] == selectedElementId);
//       if (index != -1 && elements[index]['type'] == 'text') {
//         elements[index]['fontFamily'] = newFont;
//       }
//     });
//   }

// // add new custom image code ###################################################
//   void addNewImage(String imagePath) {
//     // _saveState();
//     final newId1 = 'image_${DateTime.now().millisecondsSinceEpoch}';

//     setState(() {
//       elements.add({
//         'id': newId1,
//         'type': 'image',
//         'x': 100.0,
//         'y': 150.0,
//         'src': imagePath,
//         'width': 100.0,
//         'height': 150.0,
//         'isDeleted': false,
//       });

//       selectedElementId = newId1;
//     });
//   }

//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImageForElement(ImageSource source) async {
//     final XFile? image = await _picker.pickImage(source: source);
//     if (image != null) {
//       addNewImage(image.path);
//     }
//   }

//   // show Dialogue for custom image from gallery or camera.............
//   void showImageSourceDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Center(child: Text("Select Image Source")),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text("Camera"),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageForElement(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text("Gallery"),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImageForElement(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

// // add new Custom text........##########################################################
//   void addNewText(String text, String fontFamily) {
//     // _saveState();
//     final newId = 'text_${DateTime.now().millisecondsSinceEpoch}';

//     setState(() {
//       elements.add({
//         'id': newId,
//         'type': 'text',
//         'x': 100.0,
//         'y': 150.0,
//         'value': text,
//         'fontSize': 24.0,
//         'color': "#000000",
//         'fontWeight': 'normal',
//         'fontFamily': fontFamily,
//       });

//       selectedElementId = newId;
//     });
//   }

// //,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
//   void _selectElement(String id) {
//     setState(() {
//       if (selectedElementId == id) {
//         // Second tap: Navigate to TextEditorScreen
//         final selectedElement = elements
//             .firstWhere((element) => element['id'] == id, orElse: () => {});
//         if (selectedElement.isEmpty) return;

//         if (selectedElement['type'] == 'text') {
//           textController.text = selectedElement['value'];

//           // Navigate to TextEditorScreen
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => TextEditorScreen(
//                 initialText: selectedElement['value'],
//                 onTextUpdated: (newText, newFont) {
//                   updateText(newText, newFont);
//                 },
//               ),
//             ),
//           );
//         }
//       } else {
//         // First tap: Select the element and show the bottom sheet
//         selectedElementId = id;
//         isEditingText = false;
//         textController.clear();

//         // Show the bottom sheet if a text element is selected
//         final selectedElement = elements
//             .firstWhere((element) => element['id'] == id, orElse: () => {});
//         if (selectedElement.isNotEmpty && selectedElement['type'] == 'text') {
//           widget.onTextElementSelected?.call();
//         }
//       }
//     });
//   }

//   void updateText(String newValue, String newFont) {
//     setState(() {
//       final index =
//           elements.indexWhere((element) => element['id'] == selectedElementId);
//       if (index != -1) {
//         elements[index]['value'] = newValue;
//         elements[index]['fontFamily'] = newFont;
//       }
//     });
//   }

//   void _deleteSelectedElement() {
//     // _saveState();
//     setState(() {
//       elements = List.from(elements)
//         ..removeWhere((el) => el['id'] == selectedElementId);
//       selectedElementId = null;
//     });
//   }

// // resizing ##################################################################
//   Widget _buildResizeHandle(bool isSelected, VoidCallback onTap) {
//     return Visibility(
//       visible: isSelected,
//       child: GestureDetector(
//         onTap: onTap,
//         behavior: HitTestBehavior.opaque,
//         child: Container(
//           width: 50,
//           height: 50,
//           alignment: Alignment.center,
//           child: Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 2),
//             ),
//             child: const Icon(
//               LucideIcons.moveDiagonal2,
//               color: Colors.grey,
//               size: 23,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleScale(Map<String, dynamic> element, double scale) {
//     setState(() {
//       final index = elements.indexWhere((e) => e['id'] == element['id']);
//       if (index != -1) {
//         if (element['type'] == 'icon' || element['type'] == 'image') {
//           double newSize = (element['width'] * scale).clamp(20.0, 300.0);
//           elements[index]['width'] = newSize;
//           elements[index]['height'] = newSize;
//         } else if (element['type'] == 'text') {
//           double newFontSize = (element['fontSize'] * scale).clamp(8.0, 72.0);
//           elements[index]['fontSize'] = newFontSize;
//         }
//       }
//     });
//   }

// //handling rotation.....###############################################

//   Widget _buildElement(Map<String, dynamic> element) {
//     bool isSelected = selectedElementId == element['id'];
//     element['rotation'] ??= 0.0;
//     switch (element['type']) {
//       case 'text':
//         return Positioned(
//           left: element['x'].toDouble(),
//           top: element['y'].toDouble(),
//           child: GestureDetector(
//             onTap: () {
//               _selectElement(element['id']);
//             },

//             ///
//             onPanUpdate: (details) {
//               // _saveState();
//               if (selectedElementId == element['id']) {
//                 setState(() {
//                   final index =
//                       elements.indexWhere((e) => e['id'] == element['id']);
//                   if (index != -1) {
//                     elements[index]['x'] = element['x'] + details.delta.dx;
//                     elements[index]['y'] = element['y'] + details.delta.dy;
//                   }
//                 });
//               }
//             },
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: isSelected
//                       ? BoxDecoration(
//                           border: Border.all(color: Colors.blue, width: 2),
//                         )
//                       : null,
//                   child: isSelected && isEditingText
//                       ? SizedBox(
//                           width: 200,
//                           child: TextField(
//                             controller: textController,
//                             autofocus: true,
//                             style: TextStyle(
//                               fontSize: element['fontSize'].toDouble(),
//                               color: Color(int.parse(
//                                       element['color'].substring(1, 7),
//                                       radix: 16) +
//                                   0xFF000000),
//                               fontWeight: element['fontWeight'] == 'bold'
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                             ),
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.zero,
//                             ),
//                             onSubmitted: (newValue) {
//                               updateText(newValue, newValue);
//                               setState(() {
//                                 isEditingText = false;
//                               });
//                             },
//                           ),
//                         )
//                       : _buildTextWidget(element),
//                 ),

//                 // Modified delete button implementation
//                 if (isSelected)
//                   Positioned(
//                     top: -20,
//                     right: -20,
//                     child: GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onTap: _deleteSelectedElement,
//                       child: Container(
//                         width: 45,
//                         height: 45,
//                         alignment: Alignment.center,
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 2),
//                           ),
//                           child: const Icon(
//                             LucideIcons.x,
//                             color: Colors.grey,
//                             size: 23,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                 // Add resize handles
//                 if (isSelected)
//                   Positioned(
//                     right: -20,
//                     bottom: -20,
//                     child: GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onPanUpdate: (details) {
//                         double distance =
//                             (details.delta.dx + details.delta.dy) / 2;

//                         double scaleFactor = 1.0 + (distance * 0.005);

//                         _handleScale(element, scaleFactor);
//                       },
//                       child: _buildResizeHandle(isSelected, () {}),
//                     ),
//                   ),

//                 // add rotate
//                 // if (isSelected)
//                 //   Positioned(
//                 //     left: -20,
//                 //     bottom: -20,
//                 //     child: GestureDetector(
//                 //         // behavior: HitTestBehavior.opaque,
//                 //         // onPanUpdate: (details) {
//                 //         //   _handleRotate(element);
//                 //         // },
//                 //         // child: _buildRotateHandle(isSelected, () {}),
//                 //         ),
//                 //   ),
//               ],
//             ),
//           ),
//         );

//       case 'image':
//         String? src = element['src'];
//         bool isSvg = src != null && src.endsWith('.svg');
//         bool isDeleted = element['isDeleted'] ?? false;
//         bool isFileImage =
//             src != null && (src.startsWith("/") || src.contains(":\\"));

//         return Positioned(
//           left: element['x'].toDouble(),
//           top: element['y'].toDouble(),
//           child: GestureDetector(
//             onTap: () {
//               _selectElement(element['id']);
//             },
//             onPanUpdate: (details) {
//               // _saveState();
//               if (selectedElementId == element['id']) {
//                 if (selectedElementId == element['id']) {
//                   setState(() {
//                     final index =
//                         elements.indexWhere((e) => e['id'] == element['id']);
//                     if (index != -1) {
//                       elements[index]['x'] = element['x'] + details.delta.dx;
//                       elements[index]['y'] = element['y'] + details.delta.dy;
//                     }
//                   });
//                 }
//               }
//             },
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: isSelected
//                       ? BoxDecoration(
//                           border: Border.all(color: Colors.blue, width: 2),
//                         )
//                       : null,
//                   child: isDeleted
//                       ? const SizedBox()
//                       : isSvg
//                           ? SvgPicture.asset(
//                               element['src'],
//                               width: element['width'].toDouble(),
//                               height: element['height'].toDouble(),
//                               fit: BoxFit.cover,
//                             )
//                           : isFileImage
//                               ? Image.file(
//                                   File(src),
//                                   width: element['width'].toDouble(),
//                                   height: element['height'].toDouble(),
//                                   fit: BoxFit.cover,
//                                 )
//                               : Image.asset(
//                                   element['src'],
//                                   width: element['width'].toDouble(),
//                                   height: element['height'].toDouble(),
//                                   fit: BoxFit.cover,
//                                 ),
//                 ),

//                 // Show Delete Icon when the image is selected
//                 if (isSelected && !isDeleted)
//                   Positioned(
//                     top: -20,
//                     right: -20,
//                     child: GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onTap: _deleteSelectedElement,
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         alignment: Alignment.center,
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 2),
//                           ),
//                           child: const Icon(
//                             LucideIcons.x,
//                             color: Colors.grey,
//                             size: 23,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                 // Add resize handles
//                 if (isSelected && !isDeleted)
//                   Positioned(
//                     right: -20,
//                     bottom: -18,
//                     child: GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onPanUpdate: (details) {
//                         double distance =
//                             (details.delta.dx + details.delta.dy) / 2;

//                         double scaleFactor = 1.0 + (distance * 0.005);

//                         _handleScale(element, scaleFactor);
//                       },
//                       child: _buildResizeHandle(isSelected, () {}),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );

//       case 'shape':
//         return Positioned(
//           left: element['x'].toDouble(),
//           top: element['y'].toDouble(),
//           child: GestureDetector(
//             onTap: () => _selectElement(element['id']),
//             child: Container(
//               width: element['width'].toDouble(),
//               height: element['height'].toDouble(),
//               decoration: BoxDecoration(
//                 color: Color(
//                     int.parse(element['color'].substring(1, 7), radix: 16) +
//                         0xFF000000),
//                 borderRadius:
//                     BorderRadius.circular(element['borderRadius'].toDouble()),
//                 border: isSelected
//                     ? Border.all(color: Colors.blue, width: 2)
//                     : null,
//               ),
//             ),
//           ),
//         );

//       default:
//         return Container();
//     }
//   }

//   // change text color or gradient
//   Widget _buildTextWidget(Map<String, dynamic> element) {
//     final text = element['value'];
//     final fontSize = element['fontSize']?.toDouble() ?? 24.0;
//     final fontFamily = element['fontFamily'] ?? 'Roboto';
//     final fontWeight =
//         element['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal;

//     // Handle color
//     final colorHex = element['color'] ?? "#FF000000";
//     Color color;
//     try {
//       color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
//     } catch (e) {
//       color = Colors.black;
//     }

//     // Handle gradient
//     final gradient = element['gradient'];

//     if (gradient != null) {
//       return ShaderMask(
//         shaderCallback: (bounds) => gradient.createShader(bounds),
//         child: Text(
//           text,
//           style: GoogleFonts.getFont(
//             fontFamily,
//             fontSize: fontSize,
//             fontWeight: fontWeight,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else {
//       // Apply solid color
//       return Text(
//         text,
//         style: GoogleFonts.getFont(
//           fontFamily,
//           fontSize: fontSize,
//           fontWeight: fontWeight,
//           color: color,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: RepaintBoundary(
//         key: _templateKey,
//         child: Stack(
//           children: [
//             // for background color

//             if (widget.backgroundColor != null)
//               Positioned.fill(
//                 child: Container(color: widget.backgroundColor),
//               ),

//             // for  defaulf background
//             if (backgroundImagePath != null &&
//                 widget.backgroundColor == null &&
//                 (widget.jsonImage == null || widget.jsonImage!.isEmpty))
//               Positioned.fill(
//                 child: Image.asset(backgroundImagePath!, fit: BoxFit.cover),
//               ),

//             // Background Image which is user select fr
//             if (widget.jsonImage != null &&
//                 widget.jsonImage!.isNotEmpty &&
//                 widget.backgroundColor == null)
//               Positioned.fill(
//                 child: Image.file(
//                   File(widget.jsonImage!),
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(color: Colors.grey.shade200);
//                   },
//                 ),
//               ),

//             ...elements.map((e) => _buildElement(e)),
//           ],
//         ),
//       ),
//     );
//   }
// }
// // fixed code here
