import 'package:decimal/decimal.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../model/cart/cart_model.dart';
import '../../utils/dec_calc.dart';
import '../hall/hall_controller.dart';

class CartController extends GetxController {
  /// 盒子
  final box = IsolatedHive.box(Config.kioskHiveBox);

  /// 购物车列表
  List<CartModel> cartList = [];

  /// 是否数据准备就绪
  bool isDataReady = false;

  /// 购物车数量与金额
  int cartQuantity = 0;
  String cartAmount = "0.00";

  /// 日历折扣
  Decimal calendarDiscount = Decimal.zero;
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
    super.onClose();
  }

  Future<void> initData() async {
    isDataReady = false;
    // 初始日历折扣
    calendarDiscount = DecUtil.from(await box.get(Config.calendarDiscount) ?? "0");
    cartList = (await box.get(Config.shoppingCart) as List?)?.cast<CartModel>() ?? [];
    isDataReady = true;
    calculateCartAmount();
    update(["cartList"]);
  }

  /// 计算购物车数量与金额
  Future<void> calculateCartAmount() async {
    Decimal lastBaseAmount = Decimal.zero; // 商品的基础金额
    Decimal lastRemarksAmount = Decimal.zero; // 备注金额
    Decimal lastSetMealAmount = Decimal.zero; // 套餐金额

    if (cartList.isEmpty) {
      update(["totalAmount"]);
      return;
    }

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

    update(["totalAmount"]);
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

  /// 移除购物车商品
  Future<void> removeCartItem(int index) async {
    cartList.removeAt(index);
    await box.put(Config.shoppingCart, cartList);
    calculateCartAmount();
    update(["cartList"]);
    final hallCtl = Get.find<HallController>();
    hallCtl.calculateCartAmount();
  }
}
