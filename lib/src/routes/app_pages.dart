import 'package:banner_app/src/modules/home/view/home_view.dart';
import 'package:banner_app/src/modules/intro/views/intro_view.dart';
import 'package:get/get.dart';

class AppPages {
  // Define the initial route
  static const INITIAL = Routes.SPLASH;

  // Define the list of routes
  static final routes = [
    // Define each route with GetPage
    GetPage(
      name: Routes.SPLASH,
      page: () => const IntroView(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
    ),
  ];
}

abstract class Routes {
  static const SPLASH = '/splash';
  static const INTRO = '/intro';
  static const HOME = '/home';
}
