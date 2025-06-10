import 'package:banner_app/src/modules/intro/on_boarding/on_boarding_1.dart';
import 'package:banner_app/src/modules/intro/on_boarding/on_boarding_2.dart';
import 'package:banner_app/src/modules/intro/on_boarding/on_borading_3.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroView extends StatefulWidget {
  const IntroView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<IntroView> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  final List<Widget> splashScreens = const [
    OnBoarding1(),
    OnBoarding2(),
    OnBorading3()
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  Future<void> _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = (prefs.getBool('seen') ?? false);

    if (seen) {
      // If user has already seen intro, navigate to home
      Get.offAllNamed('/home');
    }
  }

  Future<void> _markIntroSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', true);
  }

  // Update the continue/skip logic
  void _navigateToHome() async {
    await _markIntroSeen(); // Mark intro as seen
    Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Carousel slider takes the available space
            Expanded(
              child: CarouselSlider(
                carouselController: _carouselController,
                items: splashScreens,
                options: CarouselOptions(
                  disableCenter: false,
                  height: double.infinity,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
            // Indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: splashScreens.asMap().entries.map((entry) {
                return Container(
                  width: _currentIndex == entry.key ? 20.0 : 8,
                  height: 6.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _currentIndex == entry.key
                        ? Colors.blueAccent
                        : Colors.grey,
                  ),
                );
              }).toList(),
            ),
            // Buttons row for Skip and Next/Continue
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _navigateToHome, // Updated
                    child: const Text(
                      "Skip",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex == splashScreens.length - 1) {
                        _navigateToHome(); // Updated
                      } else {
                        _carouselController.nextPage();
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text(
                      _currentIndex == splashScreens.length - 1
                          ? "Continue"
                          : "Next",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
