import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:banner_app/src/routes/app_pages.dart';
import 'package:banner_app/src/core/controller/category_controller.dart';
import 'package:banner_app/src/core/controller/template_editor_controller.dart';
import 'package:banner_app/src/core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize controllers
    final themeController = Get.put(ThemeController());
    await themeController.loadThemeSettings();
    Get.put(CategoryController());
    Get.put(TemplateEditorController(), permanent: true);

    // Get initial route
    final initialRoute = await InitialRouteCheck.getInitialRoute();

    runApp(
      GetMaterialApp(
        title: 'Banner Maker',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeController.themeMode,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  } catch (e) {
    print('Initialization error: $e');
    runApp(
      GetMaterialApp(
        title: 'Banner Maker',
        initialRoute: Routes.INTRO,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
