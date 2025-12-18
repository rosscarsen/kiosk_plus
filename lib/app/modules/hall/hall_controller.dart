import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:view_tabbar/view_tabbar_controller.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../model/cart/cart_model.dart';
import '../../service/data_sync_service.dart';
import '../../service/dio_api_client.dart';
import '../../translations/locale_keys.dart';
import '../../utils/dec_calc.dart';

class HallController extends GetxController {
  /// 左側第一大類 PageView 控制器
  final leftPageController = PageController();

  /// 左側第一大類 TabBar 控制器
  final leftTabBarController = ViewTabBarController();

  /// 盒子
  final box = IsolatedHive.box(Config.kioskHiveBox);

  /// API 客户端
  final ApiClient apiClient = ApiClient();

  /// 选中时颜色
  final activeColor = const Color(0xff436cff);

  /// 定义类目树list
  List<CategoryTreeProduct> categoryTreeProductList = [];

  int get leftTabBarCount => categoryTreeProductList.length;

  /// 公司名
  String companyName = "";

  /// 是否数据准备就绪
  bool isDataReady = false;

  /// 购物车数量与金额
  int cartQuantity = 0;
  String cartAmount = "0.00";
  // 日历折扣
  Decimal calendarDiscount = Decimal.zero;
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
    // 初始日历折扣
    calendarDiscount = DecUtil.from(await box.get(Config.calendarDiscount) ?? "0");
    // 初始化类目树
    var categoryTreeProduct = await box.get(Config.categoryTreeProduct);
    // 缓存数据不存在则跳一次网络请求
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
    // 初始化购物车数量与金额
    await calculateCartAmount();
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

  /// 计算购物车数量与金额
  Future<void> calculateCartAmount() async {
    Decimal lastBaseAmount = Decimal.zero; // 商品的基础金额
    Decimal lastRemarksAmount = Decimal.zero; // 备注金额
    Decimal lastSetMealAmount = Decimal.zero; // 套餐金额
    final cartList = (await box.get(Config.shoppingCart) as List?)?.cast<CartModel>();
    if (cartList == null) return;
    cartQuantity = cartList.fold(0, (prev, cur) => prev + (cur.product?.qty ?? 1));
    for (final item in cartList) {
      final product = item.product;
      final productPrice = DecUtil.from(product?.mPrice ?? '0.0'); //单价
      final productQty = DecUtil.from(item.product?.qty ?? '1'); //数量
      if (product == null) continue;
      // ✅ 基础金额 = 单价 * 数量
      final baseAmount = DecUtil.mul(productPrice, productQty);
      lastBaseAmount = DecUtil.add(lastBaseAmount, baseAmount);

      /// 备注部分
      final List<ProductRemark> productRemarks = item.remarkList ?? [];
      // ✅ 备注金额 = 备注金额 + 计算备注金额
      lastRemarksAmount = DecUtil.add(
        lastRemarksAmount,
        calculateRemarksAmount(productRemarks, productQty, productPrice),
      );

      /// 套餐部分
      final List<SetMealList> productSetMeal = item.setMealList ?? [];
      // ✅ 套餐金额 = 套餐金额 + 计算套餐金额
      lastSetMealAmount = DecUtil.add(lastSetMealAmount, calculateSetMealAmount(productSetMeal, productQty));
    }
    final totalAmount = DecUtil.add(DecUtil.add(lastBaseAmount, lastRemarksAmount), lastSetMealAmount);
    final totalAmountWithDiscount = DecUtil.calculateDiscountedAmount(totalAmount, calendarDiscount);
    cartAmount = DecUtil.formatAmount(totalAmountWithDiscount);

    update(["shoppingCart"]);
  }

  /// 计算备注金额
  Decimal calculateRemarksAmount(List<ProductRemark> productRemarks, Decimal productQty, Decimal productPrice) {
    if (productRemarks.isEmpty) {
      return Decimal.zero;
    }

    Decimal addAmount = Decimal.zero; // 类型 0：加价
    Decimal discountAmount = Decimal.zero; // 类型 1：折扣
    Decimal multiAmount = Decimal.zero; // 类型 2：倍数

    for (final element in productRemarks) {
      final Decimal remarkPrice = DecUtil.from(element.mPrice ?? "0");

      switch (element.mType) {
        case 0:
          // ✅ 加价 = 单价 * 数量
          addAmount = DecUtil.add(addAmount, DecUtil.mul(remarkPrice, productQty));
          break;

        case 1:
          // ✅ 折扣 = (remarkPrice / 100) * 商品单价 * 数量
          final Decimal discount = DecUtil.mul(DecUtil.mul(DecUtil.div(remarkPrice, 100), productPrice), productQty);

          discountAmount = DecUtil.add(discountAmount, discount);
          break;

        case 2:
          // ✅ 倍数 = 基础金额 * remarkPrice
          final Decimal baseAmount = DecUtil.mul(productPrice, productQty);
          multiAmount = DecUtil.add(multiAmount, DecUtil.mul(baseAmount, remarkPrice));
          break;
      }
    }

    // ✅ 最终备注金额 = 加价 - 折扣 + 倍数
    final Decimal finalRemarkAmount = DecUtil.add(DecUtil.sub(addAmount, discountAmount), multiAmount);
    return finalRemarkAmount;
  }

  /// 计算套餐金额
  Decimal calculateSetMealAmount(List<SetMealList> productSetMeal, Decimal productQty) {
    if (productSetMeal.isEmpty) {
      return Decimal.zero;
    }
    //  套餐金额 = 累加(套餐单价 * 套餐数量)
    final selectedSetMealAmount = productSetMeal.fold(
      Decimal.zero,
      (prev, element) =>
          DecUtil.add(prev, DecUtil.mul(DecUtil.from(element.mPrice ?? "0"), DecUtil.from(element.mQty ?? "0"))),
    );
    // ✅ 最终套餐金额 = 套餐金额 * 商品数量
    final Decimal lastSetMealAmount = DecUtil.mul(selectedSetMealAmount, productQty);
    return lastSetMealAmount;
  }
}
