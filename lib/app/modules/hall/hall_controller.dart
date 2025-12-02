import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../service/data_sync_service.dart';

class HallController extends GetxController with GetTickerProviderStateMixin {
  final box = IsolatedHive.box(Config.kioskHiveBox);

  List<CategoryTreeProduct> categoryTreeProductList = [];

  //  一级 TabController
  late TabController firstLevelTabController;
  //  二级 TabController
  late final Map<int, TabController> secondLevelControllers;
  RxString companyName = ''.obs;
  bool isDataReady = false;

  int selectIndex = 0;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    isDataReady = false;

    final companyInfo = await box.get(Config.companyInfo) as CompanyInfo?;
    companyName.value = Get.locale.toString() == 'en_US'
        ? companyInfo?.mNameEnglish ?? ''
        : companyInfo?.mNameChinese ?? '';

    var categoryTreeProduct = await box.get(Config.categoryTreeProduct);
    if (categoryTreeProduct == null) {
      await Get.find<DataSyncService>().getData();
      categoryTreeProduct = await box.get(Config.categoryTreeProduct);
    }

    if (categoryTreeProduct is List) {
      categoryTreeProductList = categoryTreeProduct.cast<CategoryTreeProduct>();
    }

    // 一级 TabController
    firstLevelTabController = TabController(length: categoryTreeProductList.length, vsync: this);
    // 二级 TabController  初始化
    secondLevelControllers = categoryTreeProductList.asMap().map((index, item) {
      final childrenCount = item.children?.length ?? 0;
      return MapEntry(index, TabController(length: childrenCount, vsync: this));
    });
    isDataReady = true;
    update(['hall_body']);
  }

  @override
  void onClose() {
    firstLevelTabController.dispose();
    // 释放所有二级TabController资源
    secondLevelControllers.forEach((_, controller) => controller.dispose());
    super.onClose();
  }
}

/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:scrollable_list_tab_scroller/scrollable_list_tab_scroller.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../service/data_sync_service.dart';
import '../../service/dio_api_client.dart';
import '../../utils/logger.dart';

class HallController extends GetxController with GetTickerProviderStateMixin {
  final itemPositionsListener = ItemPositionsListener.create();
  final itemScrollController = ItemScrollController();

  final box = IsolatedHive.box(Config.kioskHiveBox);
  final ApiClient apiClient = ApiClient();
  // 所有分类数据
  List<CategoryTreeProduct> categoryTreeProductList = [];
  // 第一大类对应子类数据
  List<CategoryTreeProduct>? children = [];
  String companyName = "";
  // 第一大类index
  int selectIndex = 0;
  // 第一大类总数
  int get categoryCount => categoryTreeProductList.length;
  // 第一大类对应子类数据总数
  int get childrenCount => children?.length ?? 0;

  late TabController tabController;
  late TabController tabController1;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    categoryTreeProductList.clear();
    tabController.dispose();
    tabController1.dispose();
    super.onClose();
  }

  void changeLeftNavIndex(int index) {
    selectIndex = index;

    // 第一大类对应子类数据
    if (categoryTreeProductList.isNotEmpty && selectIndex < categoryTreeProductList.length) {
      children = categoryTreeProductList[selectIndex].children;
    } else {
      children = [];
    }
    update(["hall_left_nav", "hall_right_nav"]);
    itemScrollController.scrollTo(index: 0, duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  Future<void> initData() async {
    final companyInfo = await box.get(Config.companyInfo) as CompanyInfo?;
    companyName = Get.locale.toString() == 'en_US' ? companyInfo?.mNameEnglish ?? '' : companyInfo?.mNameChinese ?? '';

    var categoryTreeProduct = await box.get(Config.categoryTreeProduct);
    if (categoryTreeProduct == null) {
      await Get.find<DataSyncService>().getData();
      categoryTreeProduct = await box.get(Config.categoryTreeProduct);
    }
    if (categoryTreeProduct is List) {
      categoryTreeProductList = categoryTreeProduct.cast<CategoryTreeProduct>();
    }
    // 第一大类对应子类数据
    if (categoryTreeProductList.isNotEmpty && selectIndex < categoryTreeProductList.length) {
      children = categoryTreeProductList[selectIndex].children;
    } else {
      children = [];
    }
    tabController = TabController(length: categoryCount, vsync: this);
    tabController1 = TabController(length: childrenCount, vsync: this);
    update(["hall_app_bar", "hall_left_nav", "hall_right_nav"]);
  }
}
 */
