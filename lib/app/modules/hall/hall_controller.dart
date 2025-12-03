import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:view_tabbar/view_tabbar_controller.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../service/data_sync_service.dart';
import '../../service/dio_api_client.dart';

class HallController extends GetxController with GetTickerProviderStateMixin {
  final leftPageController = PageController();
  final leftTabBarController = ViewTabBarController();
  final rightPageController = PageController();
  final rightTabBarController = ViewTabBarController();
  final box = IsolatedHive.box(Config.kioskHiveBox);
  final ApiClient apiClient = ApiClient();
  final activeColor = Color(0xff436cff);
  List<CategoryTreeProduct> categoryTreeProductList = [];
  List<CategoryTreeProduct>? children = [];
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
    children?.clear();
    leftPageController.dispose();
    rightPageController.dispose();
    super.onClose();
  }

  void changeLeftNavIndex(int index) {
    selectIndex = index;
    children = (categoryTreeProductList.isNotEmpty && selectIndex < categoryTreeProductList.length)
        ? categoryTreeProductList[selectIndex].children
        : [];
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

    children = (categoryTreeProductList.isNotEmpty && selectIndex < categoryTreeProductList.length)
        ? categoryTreeProductList[selectIndex].children
        : [];

    isDataReady = true;
    update(["hall_app_bar", "hall_left_nav", "hall_right_nav"]);
  }
}
