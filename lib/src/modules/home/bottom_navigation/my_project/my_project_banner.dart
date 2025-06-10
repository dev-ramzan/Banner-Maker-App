import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:banner_app/src/core/controller/template_editor_controller.dart';
import 'package:banner_app/src/modules/home/bottom_navigation/explore/edit_details_screen/edit_details_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MyProjectBanner extends StatelessWidget {
  const MyProjectBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TemplateEditorController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Drafts'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: Obx(
          () => MasonryGridView.builder(
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
            ),
            itemCount: controller.drafts.length,
            itemBuilder: (context, index) {
              final draft = controller.drafts[index];
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.loadDraft(draft);
                      Get.to(() => const EditingDetailsScreen());
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: 16, top: 16, left: 16, right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: draft['thumbnail'] != null
                              ? Image.file(
                                  File(draft['thumbnail']),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 120,
                                  child: const Icon(Icons.image,
                                      color: Colors.grey),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Draft'),
                                content: const Text(
                                    'Are you sure you want to delete this draft?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      controller.deleteDraft(index);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
