import 'package:banner_app/src/modules/splash/views/spash_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPages {
  // Define the initial route
  static const INITIAL = Routes.SPLASH;

  // Define the list of routes
  static final routes = [
    // Define each route with GetPage
    GetPage(
      name: Routes.SPLASH,
      page: () => SpashView(),
    ),
    // GetPage(
    //   name: Routes.INTRO,
    //   page: () => IntroScreen(),
    // ),
  ];
}

abstract class Routes {
  static const SPLASH = '/';
  static const INTRO = '/intro';
}
