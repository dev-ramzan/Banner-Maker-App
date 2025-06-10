import 'package:get/get.dart';

class CustomController extends GetxController {
  final RxList<Map<String, dynamic>> aspectRatios =
      <Map<String, dynamic>>[].obs;
  final selectedRatio = Rx<Map<String, dynamic>>({});
  final containerWidth = 650.0.obs;
  final containerHeight = 800.0.obs;
  RxBool showCustomFields = false.obs;
  //???????????????????????????????????????????????
  RxDouble selectedWidth = 1080.0.obs;
  RxDouble selectedHeight = 1920.0.obs;
  RxString selectedName = ''.obs;
  //???????????????????????????????????????????????
  @override
  void onInit() {
    super.onInit();
    aspectRatios.assignAll([
      {
        'name': 'Custom Size',
        'ratio': 1.0,
        'width': 1,
        'height': 1,
        'image': "assets/images/createScreen/customSize.png",
        'namePosition': {
          'x': 35.0.obs,
          'y': 100.0.obs,
        },
        'ratioPosition': {
          'x': 67.0.obs,
          'y': 125.0.obs,
        },
      },
      {
        'name': 'Standard Size',
        'ratio': 13 / 16,
        'width': 13,
        'height': 16,
        'image': "assets/images/createScreen/stPoster.png",
        'namePosition': {
          'x': 32.0.obs,
          'y': 100.0.obs,
        },
        'ratioPosition': {
          'x': 55.0.obs,
          'y': 130.0.obs,
        },
      },
      {
        'name': 'Instagram Square',
        'ratio': 1.0,
        'width': 1,
        'height': 1,
        'image': "assets/images/createScreen/instaSquare.png",
        'namePosition': {
          'x': 20.0.obs,
          'y': 75.0.obs,
        },
        'ratioPosition': {
          'x': 67.0.obs,
          'y': 100.0.obs,
        },
      },
      {
        'name': 'Instagram Story',
        'ratio': 9 / 16,
        'width': 9,
        'height': 16,
        'image': "assets/images/createScreen/instaStory.png",
        'namePosition': {
          'x': 27.0.obs,
          'y': 120.0.obs,
        },
        'ratioPosition': {
          'x': 60.0.obs,
          'y': 150.0.obs,
        },
      },
      {
        'name': 'Instagram Post',
        'ratio': 4 / 5,
        'width': 4,
        'height': 5,
        'image': "assets/images/createScreen/instaPost.png",
        'namePosition': {
          'x': 27.0.obs,
          'y': 95.0.obs,
        },
        'ratioPosition': {
          'x': 65.0.obs,
          'y': 120.0.obs,
        },
      },
      {
        'name': 'FB Cover',
        'ratio': 2 / 1,
        'width': 2,
        'height': 1,
        'image': "assets/images/createScreen/fbCover.png",
        'namePosition': {
          'x': 70.0.obs,
          'y': 30.0.obs,
        },
        'ratioPosition': {
          'x': 88.0.obs,
          'y': 50.0.obs,
        },
      },
      {
        'name': 'Facebook Post',
        'ratio': 1.0,
        'width': 1,
        'height': 1,
        'image': "assets/images/createScreen/fbSqure.png",
        'namePosition': {
          'x': 30.0.obs,
          'y': 80.0.obs,
        },
        'ratioPosition': {
          'x': 63.0.obs,
          'y': 105.0.obs,
        },
      },
      {
        'name': 'LinkedIn Cover',
        'ratio': 4 / 1,
        'width': 4,
        'height': 1,
        'image': "assets/images/createScreen/lkBg.png",
        'namePosition': {
          'x': 55.0.obs,
          'y': 0.0.obs,
        },
        'ratioPosition': {
          'x': 85.0.obs,
          'y': 20.0.obs,
        },
      },
      {
        'name': 'LinkedIn Post',
        'ratio': 16 / 9,
        'width': 16,
        'height': 9,
        'image': "assets/images/createScreen/lkCover.png",
        'namePosition': {
          'x': 60.0.obs,
          'y': 30.0.obs,
        },
        'ratioPosition': {
          'x': 85.0.obs,
          'y': 50.0.obs,
        },
      },
      {
        'name': 'Pinterest Post',
        'ratio': 3 / 4,
        'width': 3,
        'height': 4,
        'image': "assets/images/createScreen/pintPost.png",
        'namePosition': {
          'x': 32.0.obs,
          'y': 90.0.obs,
        },
        'ratioPosition': {
          'x': 65.0.obs,
          'y': 115.0.obs,
        },
      },
      {
        'name': 'YouTube Thumbnail',
        'ratio': 16 / 9,
        'width': 16,
        'height': 9,
        'image': "assets/images/createScreen/ytTn.png",
        'namePosition': {
          'x': 17.0.obs,
          'y': 47.0.obs,
        },
        'ratioPosition': {
          'x': 65.0.obs,
          'y': 67.0.obs,
        },
      },
      {
        'name': 'X Cover',
        'ratio': 3 / 1,
        'width': 3,
        'height': 1,
        'image': "assets/images/createScreen/xCover.png",
        'namePosition': {
          'x': 70.0.obs,
          'y': 8.0.obs,
        },
        'ratioPosition': {
          'x': 85.0.obs,
          'y': 25.0.obs,
        },
      },
      {
        'name': 'X Post',
        'ratio': 2 / 1,
        'width': 2,
        'height': 1,
        'image': "assets/images/createScreen/xPost.png",
        'namePosition': {
          'x': 80.0.obs,
          'y': 20.0.obs,
        },
        'ratioPosition': {
          'x': 93.0.obs,
          'y': 37.0.obs,
        },
      },
    ]);
  }

  void updatePosition(String templateName, bool isName, double x, double y) {
    final template = aspectRatios.firstWhere((t) => t['name'] == templateName);
    final position =
        isName ? template['namePosition'] : template['ratioPosition'];

    (position['x'] as RxDouble).value = x;
    (position['y'] as RxDouble).value = y;

    update();
  }

  void selectRatio(Map<String, dynamic> ratio) {
    selectedRatio.value = ratio;

    if (ratio['name'] == 'Custom Size') {
      showCustomFields.value = true;
    } else {
      showCustomFields.value = false;
      _calculateContainerSize(ratio['ratio']);
    }
  }

  void _calculateContainerSize(double? ratio) {
    if (ratio == null) return;

    final screenWidth = Get.width;
    final maxWidth = screenWidth * 0.8;
    final calculatedHeight = maxWidth / ratio;

    containerWidth.value = maxWidth;
    containerHeight.value = calculatedHeight;
  }

  void updateCustomSize(double width, double height) {
    containerWidth.value = width;
    containerHeight.value = height;

    final customTemplate = aspectRatios
        .firstWhere((template) => template['name'] == 'Custom Size');

    customTemplate['width'] = width;
    customTemplate['height'] = height;
    customTemplate['ratio'] = width / height;
    selectedRatio.value = customTemplate;

    // Add this part:
    selectedWidth.value = width;
    selectedHeight.value = height;
    selectedName.value = 'Custom Size';
    showCustomFields.value = false;
  }

  void resetCustomSize() {
    selectRatio(aspectRatios.first);
    showCustomFields.value = false;
  }
}
