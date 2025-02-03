import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'src/routes/app_pages.dart';
import 'src/core/theme/theme_service.dart';
import 'src/core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ThemeController with ThemeService
  final themeController = Get.put(ThemeController(ThemeService()));
  await themeController.loadThemeSettings();

  runApp(
    GetMaterialApp(
      title: 'Your App Name',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeController.themeMode,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
