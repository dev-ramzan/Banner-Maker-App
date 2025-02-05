import 'package:banner_app/src/modules/home/bottom_navigation/create/create.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/explore_banner.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/home/home_banner.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/my_project/my_project_banner.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/search/search_banners.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  final List<Widget> _screens = [
    const HomeBanner(),
    const ExploreBanner(),
    const SearchBanners(),
    const CreateBanner(),
    const MyProjectBanner(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _screens.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true, // Makes bottom bar float over body content
        body: BottomBar(
          fit: StackFit.loose,
          barColor: Colors.transparent, // No solid background for glass effect
          borderRadius: BorderRadius.circular(30),
          duration: const Duration(milliseconds: 600), // Smooth animation
          curve: Curves.fastOutSlowIn, // Elegant transition effect
          showIcon: true,
          hideOnScroll: true, // Hide bar when scrolling
          scrollOpposite: true, // Keep icon visible when scrolling up
          iconHeight: 40,
          iconWidth: 40,
          width: MediaQuery.of(context).size.width * 0.9,
          reverse: false,
          barAlignment: Alignment.bottomCenter,
          body: (context, controller) => TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: _screens,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.purpleAccent.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                      width: 4, color: Colors.white.withOpacity(0.8)),
                  insets: const EdgeInsets.symmetric(horizontal: 16),
                ),
                tabs: [
                  _buildTab(Icons.home, 0),
                  _buildTab(Icons.explore, 1),
                  _buildTab(Icons.add_circle, 2),
                  _buildTab(Icons.favorite, 3),
                  _buildTab(Icons.person, 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// seprate reuseable design widget for tabs
  Widget _buildTab(IconData icon, int index) {
    return SizedBox(
      height: 60,
      width: 50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentIndex == index
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Center(
          child: Icon(
            icon,
            color: _currentIndex == index ? Colors.white : Colors.grey.shade400,
            size: _currentIndex == index ? 35 : 30,
          ),
        ),
      ),
    );
  }
}
