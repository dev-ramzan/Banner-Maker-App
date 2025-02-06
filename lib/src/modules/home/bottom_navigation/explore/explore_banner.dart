import 'package:banner_app/src/core/common/my_app_bar.dart';
import 'package:banner_app/src/core/values/app_color.dart';
import 'package:banner_app/src/core/values/constants.dart';
import 'package:flutter/material.dart';

class ExploreBanner extends StatelessWidget {
  const ExploreBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "Banner Maker",
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // Static Search Bar
              TextField(
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColor.darkGreen),
                  ),
                  hintText: "Search categories . . . . . .",
                  prefixIcon:
                      const Icon(Icons.search, color: AppColor.darkGreen),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColor.darkGreen)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Popular Categories",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              // listview builder
              SizedBox(
                height: 170,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: PopularCategories.PopularImages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 220,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            image: DecorationImage(
                                image: AssetImage(
                                  PopularCategories.PopularImages[index],
                                ),
                                fit: BoxFit.cover),
                          ),
                        ),
                        Container(
                          width: 220,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColor.darkGreen,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(10)),
                          ),
                          child: Center(
                            child: Text(
                              " ${CategoriesTitle.CategoriesTitleList[index]}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Beautify Your Life Event",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(
                height: 270, // Adjust height to fit text
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: PopularCategories.PopularImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // First Image inside a Container
                          Container(
                            width: 100,
                            height: 120, // Increased height to fit text
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                  offset: const Offset(3, 3),
                                ),
                              ],
                              color: AppColor.darkGreen, // Background color
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100, // Image height
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: AssetImage(PopularCategories
                                          .PopularImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                // Space between image and text
                                Text(
                                  "${CategoriesTitle.CategoriesTitleList[index]}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                              height: 10), // Space between two containers

                          // Second Image inside a Container
                          Container(
                            width: 100,
                            height: 120, // Increased height to fit text
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                  offset: const Offset(3, 3),
                                ),
                              ],
                              color: AppColor.darkGreen, // Background color
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100, // Image height
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          PopularCategories.PopularImages[
                                              (index + 1) %
                                                  PopularCategories
                                                      .PopularImages.length]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    height: 3), // Space between image and text
                                Text(
                                  "${CategoriesTitle.CategoriesTitleList[index]}", // Title for the second image
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Explore More Categories",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
