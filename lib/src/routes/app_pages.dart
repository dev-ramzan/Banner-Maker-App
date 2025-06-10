import 'package:banner_app/src/modules/home/view/home_view.dart';
import 'package:banner_app/src/modules/intro/views/intro_view.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPages {
  // Define the initial route
  static const INITIAL = Routes.INTRO;

  // Define the list of routes
  static final routes = [
    // Define each route with GetPage
    GetPage(
      name: Routes.INTRO,
      page: () => const IntroView(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
    ),
  ];
}

abstract class Routes {
  static const INTRO = '/intro';
  static const HOME = '/home';
}

class InitialRouteCheck {
  static Future<String> getInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('seen') ?? false;
      return seen ? Routes.HOME : Routes.INTRO;
    } catch (e) {
      print('Error checking initial route: $e');
      return Routes.INTRO;
    }
  }
}
