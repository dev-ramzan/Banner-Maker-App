import 'package:banner_app/src/core/values/app_color.dart';
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
        resizeToAvoidBottomInset: false,
        body: BottomBar(
          fit: StackFit.loose,
          barColor: Colors.transparent, // Glassmorphic effect

          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          showIcon: true,
          hideOnScroll: true,
          scrollOpposite: true,
          iconHeight: 50,
          iconWidth: 50,
          width: MediaQuery.of(context).size.width,
          reverse: false,
          barAlignment: Alignment.bottomCenter,
          body: (context, controller) => TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: _screens,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Background Bar
                Container(
                  height: 75,
                  decoration: BoxDecoration(
                    color: AppColor.darkGreen,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                ),
                // Floating Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) => _buildTab(index)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildTab(int index) {
    List<IconData> icons = [
      Icons.home,
      Icons.explore,
      Icons.search,
      Icons.add_circle_rounded,
      Icons.person,
    ];

    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _tabController.index = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isSelected ? 55 : 45,
        width: isSelected ? 70 : 50,
        margin: EdgeInsets.only(bottom: isSelected ? 10 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 1.5,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icons[index],
          color: isSelected
              ? AppColor.lightGreen
              : AppColor.lightGreen.withOpacity(0.5),
          size: isSelected ? 35 : 30, // Bigger icon when selected
        ),
      ),
    );
  }
}
