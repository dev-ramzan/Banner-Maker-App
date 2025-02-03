import 'package:banner_app/src/core/theme/theme_controller.dart';
import 'package:banner_app/src/modules/splash/views/spash_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'src/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ThemeController with ThemeService
  final themeController = Get.put(ThemeController());
  await themeController.loadThemeSettings();

  runApp(
    GetMaterialApp(
      title: 'Your App Name',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeController.themeMode,
      initialRoute: AppPages.INITIAL,
      home: const SpashView(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
