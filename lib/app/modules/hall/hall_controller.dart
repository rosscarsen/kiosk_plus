import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:view_tabbar/view_tabbar_controller.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../service/data_sync_service.dart';
import '../../service/dio_api_client.dart';
import '../../translations/locale_keys.dart';

class HallController extends GetxController {
  final leftPageController = PageController();
  final leftTabBarController = ViewTabBarController();

  final box = IsolatedHive.box(Config.kioskHiveBox);
  final ApiClient apiClient = ApiClient();

  final activeColor = const Color(0xff436cff);

  List<CategoryTreeProduct> categoryTreeProductList = [];

  int get leftTabBarCount => categoryTreeProductList.length;

  String companyName = "";
  int selectIndex = 0;
  bool isDataReady = false;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  void onClose() {
    leftPageController.dispose();
    categoryTreeProductList.clear();

    super.onClose();
  }

  /// ✅ 初始化数据 + 初始化所有右侧控制器
  Future<void> initData() async {
    isDataReady = false;
    update(["hall_body", "hall_app_bar"]);

    var categoryTreeProduct = await box.get(Config.categoryTreeProduct);
    if (categoryTreeProduct == null) {
      await Get.find<DataSyncService>().getData();
      categoryTreeProduct = await box.get(Config.categoryTreeProduct);
      final companyInfo = await box.get(Config.companyInfo) as CompanyInfo?;
      companyName = Get.locale.toString() == 'en_US'
          ? companyInfo?.mNameEnglish ?? ''
          : companyInfo?.mNameChinese ?? '';
    }

    if (categoryTreeProduct is List) {
      categoryTreeProductList = categoryTreeProduct.cast<CategoryTreeProduct>();
    }
    final companyInfo = await box.get(Config.companyInfo) as CompanyInfo?;
    companyName = Get.locale.toString() == 'en_US'
        ? companyInfo?.mNameEnglish ?? ''
        : companyInfo?.mNameChinese ?? LocaleKeys.hall.tr;
    isDataReady = true;
    update(["hall_body", "hall_app_bar"]);
  }

  ///  滑动切换后一大类
  void jumpToNextCategory() {
    if (!leftPageController.hasClients) return;

    final int current = leftPageController.page!.round();

    if (current < leftTabBarCount - 1) {
      leftPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  ///  滑动切换前一大类
  void jumpToPrevCategory() {
    if (!leftPageController.hasClients) return;

    final int current = leftPageController.page!.round();

    if (current > 0) {
      leftPageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}

/* class HallController extends GetxController with GetTickerProviderStateMixin {
  final leftPageController = PageController();
  final leftTabBarController = ViewTabBarController();
  final Map<int, PageController> rightPageControllers = {};
  final Map<int, ViewTabBarController> rightTabBarControllers = {};
  final box = IsolatedHive.box(Config.kioskHiveBox);
  final ApiClient apiClient = ApiClient();
  final activeColor = Color(0xff436cff);
  List<CategoryTreeProduct> categoryTreeProductList = [];
  int get leftTabBarCount => categoryTreeProductList.length;
  // List<CategoryTreeProduct>? children = [];
  // int get rightTabBarCount => children?.length ?? 0;
  String companyName = "";
  int selectIndex = 0;
  bool isDataReady = false;

  @override
  void onInit() {
    super.onInit();
    initData();
    leftPageController.addListener(() {});
  }

  @override
  void onClose() {
    categoryTreeProductList.clear();
    // children?.clear();
    leftPageController.dispose();
    rightPageControllers.forEach((key, value) => value.dispose());
    super.onClose();
  }

  void changeLeftNavIndex(int index) {
    selectIndex = index;
    // children = (categoryTreeProductList.isNotEmpty && selectIndex < categoryTreeProductList.length)
    //     ? categoryTreeProductList[selectIndex].children
    //     : [];
    /*  if (leftPageController.hasClients) {
      leftPageController.jumpToPage(index);
    } */
    update(["hall_left_nav", "hall_right_nav"]);
  }

  Future<void> initData() async {
    isDataReady = false;
    final companyInfo = await box.get(Config.companyInfo) as CompanyInfo?;
    companyName = Get.locale.toString() == 'en_US' ? companyInfo?.mNameEnglish ?? '' : companyInfo?.mNameChinese ?? '';

    var categoryTreeProduct = await box.get(Config.categoryTreeProduct);
    if (categoryTreeProduct == null) {
      await Get.find<DataSyncService>().getData();
      categoryTreeProduct = await box.get(Config.categoryTreeProduct);
      final companyInfo = await box.get(Config.companyInfo) as CompanyInfo?;
      companyName = Get.locale.toString() == 'en_US'
          ? companyInfo?.mNameEnglish ?? ''
          : companyInfo?.mNameChinese ?? '';
    }

    if (categoryTreeProduct is List) {
      categoryTreeProductList = categoryTreeProduct.cast<CategoryTreeProduct>();
    }

    // children = (categoryTreeProductList.isNotEmpty && selectIndex < categoryTreeProductList.length)
    //     ? categoryTreeProductList[selectIndex].children
    //     : [];
    for (int i = 0; i < leftTabBarCount; i++) {
      rightPageControllers[i] = PageController();
      rightTabBarControllers[i] = ViewTabBarController();
    }

    isDataReady = true;
    update(["hall_app_bar", "hall_left_nav", "hall_right_nav"]);
  }
}
 */
