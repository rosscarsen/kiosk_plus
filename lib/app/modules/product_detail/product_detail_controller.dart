import 'package:decimal/decimal.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../model/api_data_model/single_product_extra_info_model.dart';
import '../../model/cart/cart_model.dart';
import '../../service/dio_api_client.dart';
import '../../translations/locale_keys.dart' show LocaleKeys;
import '../../utils/custom_dialog.dart';
import '../../utils/dec_calc.dart';
import '../../utils/logger.dart';

class ProductDetailController extends GetxController {
  final formKey = GlobalKey<FormBuilderState>();
  final setMealKey = GlobalKey<State>();
  late final ExpansionGroupController groupController;
  final ScrollController scrollController = ScrollController();
  final apiClient = ApiClient();
  final box = IsolatedHive.box(Config.kioskHiveBox);
  bool isDataReady = false;
  Product? product;

  /// 商品单价
  double get productPrice => double.tryParse(product?.mPrice ?? "0") ?? 0;
  // 日历折扣
  Decimal calendarDiscount = Decimal.zero;

  /// 食品备注列表
  List<ProductRemark> itemProductRemarks = [];

  /// 商品数量
  int productQty = 1;

  /// 商品总价
  double totalAmount = 0;

  /// 选择的食品备注
  List<String> selectRemarks = [];

  /// 商品额外信息
  List<SingleProductExtraInfoModel> extraInfo = [];

  /// 套餐列表
  List<SetMealDatum> get setMealList =>
      extraInfo.expand((e) => e.setMealLimit?.setMealData ?? []).cast<SetMealDatum>().toList();

  /// 选择的套餐备注
  List<String> selectSetMeal = [];

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  void onReady() {
    if (product == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return;
    }
    super.onReady();
  }

  @override
  void onClose() {
    product = null;
    itemProductRemarks.clear();
    selectRemarks.clear();
    extraInfo.clear();
    selectSetMeal.clear();
    groupController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// 初始化数据
  /// 从路由参数中获取产品详情数据
  /// 如果数据为空，则返回上一页
  /// 如果数据不为空，则设置isDataReady为true
  void initData() async {
    isDataReady = false;
    product = Get.arguments as Product?;
    final productID = product?.tProductId.toString().trim() ?? "";
    // 初始日历折扣
    calendarDiscount = DecUtil.from(await box.get(Config.calendarDiscount) ?? "0");
    // 获取商品额外信息(食品备注與套餐)
    if (productID.isNotEmpty) {
      final apiResponse = await apiClient.get(
        Config.getSingleProductExtraInfo,
        queryParameters: {"productID": productID},
      );
      try {
        if (apiResponse.success) {
          extraInfo = singleProductExtraInfoModelFromJson(apiResponse.data);
        }
      } catch (e) {
        logger.d("获取商品额外信息失败: $e");
      }
    }
    if (product?.productRemarks?.isNotEmpty ?? false) {
      await getProductRemark(product!.productRemarks!);
    }

    for (var e in extraInfo) {
      final setMealLimit = e.setMealLimit;

      // 套餐最大选择数量
      final tempMax = setMealLimit?.limitMax ?? 0;
      final max = tempMax > 0 ? tempMax : 1;
      // 强制选择
      final foreSelect = setMealLimit?.obligatory ?? 0;
      // 套餐数据
      final setMealData = setMealLimit?.setMealData ?? [];
      // 根据最大选择数量取默认选中的套餐
      List<String> defaultSelected = setMealData
          .where((e) => e.soldOut == 0)
          .take(max)
          .map((e) => e.mProductCode ?? "")
          .toList();
      if (max > 1) {
        if (foreSelect == 1) {
          defaultSelected = setMealData
              .where((e) => e.soldOut == 0)
              .take(max)
              .map((e) => e.mProductCode ?? "")
              .toList();
        } else {
          defaultSelected = setMealData.where((e) => e.soldOut == 0).take(1).map((e) => e.mProductCode ?? "").toList();
        }
      }
      selectSetMeal.addAll(defaultSelected);
    }
    // 初始化展开控制器
    groupController = ExpansionGroupController(length: extraInfo.length, toggleType: ToggleType.expandOnlyCurrent);
    changeTotal();
    isDataReady = true;
    update(["body"]);
  }

  /// 获取对应的所有食品备注
  Future<void> getProductRemark(String searchKey) async {
    final boxProductRemarks = await box.get(Config.productRemarks);
    if (boxProductRemarks != null && boxProductRemarks is List) {
      itemProductRemarks = boxProductRemarks
          .cast<ProductRemark>()
          .where((element) => element.mRemark == searchKey && (element.mDetail?.isNotEmpty ?? false))
          .toList();
    }
  }

  /// 改变商品数量
  /// 改变商品总价
  /// 更新底部视图
  void changeTotal() {
    // ✅ 基础金额 = 单价 * 数量
    final baseAmount = DecUtil.mul(productPrice, productQty);
    // ✅ 备注金额
    final remarkAmount = calculateRemarksAmount();
    // ✅ 套餐金额
    final setMealAmount = calculateSetMealAmount();
    // ✅ 总金额 = 基础金额 + 备注金额 + 套餐金额
    final tempTotalAmount = DecUtil.add(DecUtil.add(baseAmount, remarkAmount), setMealAmount);

    totalAmount = DecUtil.calculateDiscountedAmount(tempTotalAmount, calendarDiscount).toDouble();
    update(["bottom"]);
  }

  /// 计算备注金额
  Decimal calculateRemarksAmount() {
    if (itemProductRemarks.isEmpty || selectRemarks.isEmpty) {
      return Decimal.zero;
    }

    final List<ProductRemark> selectedRemarks = itemProductRemarks.where((e) {
      final detail = e.mDetail?.trim();
      return detail != null && selectRemarks.contains(detail);
    }).toList();
    Decimal addAmount = Decimal.zero; // 类型 0：加价
    Decimal discountAmount = Decimal.zero; // 类型 1：折扣
    Decimal multiAmount = Decimal.zero; // 类型 2：倍数

    for (final element in selectedRemarks) {
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

  /// 修改选中套餐
  void changeSelectSetMeal({required String item, required bool isAdd}) {
    if (isAdd) {
      selectSetMeal.add(item);
    } else {
      selectSetMeal.remove(item);
    }
    selectSetMeal = List.from(selectSetMeal.toSet());
    changeTotal();
  }

  /// 计算套餐金额
  Decimal calculateSetMealAmount() {
    final selectedSetMealList = setMealList.where((e) => selectSetMeal.contains(e.mProductCode)).toList();
    if (selectedSetMealList.isEmpty) {
      return Decimal.zero;
    }
    //  套餐金额 = 累加(套餐单价 * 套餐数量)
    final selectedSetMealAmount = selectedSetMealList.fold(
      Decimal.zero,
      (prev, element) =>
          DecUtil.add(prev, DecUtil.mul(DecUtil.from(element.mPrice ?? "0"), DecUtil.from(element.mQty ?? "0"))),
    );
    // ✅ 最终套餐金额 = 套餐金额 * 商品数量
    final Decimal lastSetMealAmount = DecUtil.mul(selectedSetMealAmount, productQty);
    return lastSetMealAmount;
  }

  /// 滚动到套餐列表
  void scrollToSetMeal() {
    final context = setMealKey.currentContext;
    if (context == null) return;

    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);

    final offset = viewport.getOffsetToReveal(renderObject, 0.0).offset;

    scrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  /// 检测套餐
  bool checkSetMeal() {
    // 有套餐，才检测
    if (setMealList.isNotEmpty) {
      if (selectSetMeal.isEmpty) {
        scrollToSetMeal();
        groupController.handleBehaviors(0, true, false);
        CustomDialog.errorMessages(LocaleKeys.pleaseSelectSetMeal.tr);
        return false;
      }
      for (var item in extraInfo.asMap().entries) {
        final index = item.key;
        final setMealLimit = item.value.setMealLimit;
        final title = Get.locale.toString() == "en_US" ? setMealLimit?.enus ?? "" : setMealLimit?.zhtw ?? "";
        // 套餐最大选择数量
        final tempMax = setMealLimit?.limitMax ?? 0;
        final max = tempMax > 0 ? tempMax : 1;
        // 强制选择
        final foreSelect = setMealLimit?.obligatory ?? 0;
        // // 套餐数据
        final setMealData = setMealLimit?.setMealData ?? [];
        final itemSelectedList = selectSetMeal.where((e) => setMealData.any((item) => item.mProductCode == e)).toList();
        if (foreSelect == 1) {
          if (itemSelectedList.isEmpty || itemSelectedList.length < max) {
            scrollToSetMeal();
            groupController.handleBehaviors(index, true, false);
            CustomDialog.errorMessages("$title${LocaleKeys.requireItemsParam.trArgs([max.toString()])}");
            return false;
          }
        } else {
          if (itemSelectedList.isEmpty) {
            scrollToSetMeal();
            groupController.handleBehaviors(index, true, false);
            CustomDialog.errorMessages("$title${LocaleKeys.requireItemsParam.trArgs(["1"])}");
            return false;
          }
        }
      }
    }
    return true;
  }

  /// 添加到购物车
  Future<void> addToCart() async {
    try {
      final Map<String, dynamic> singleCartInfo = {};
      if (product == null) {
        CustomDialog.errorMessages(LocaleKeys.paramFailed.trArgs([LocaleKeys.addToCart.tr]));
        return;
      }
      singleCartInfo.addAll({"product": product?.copyWith(qty: productQty).toJson()});

      final formData = formKey.currentState?.value;

      if (formData != null) {
        //备注
        final remarkCodes = formData["remark"] as List? ?? [];
        final List<ProductRemark> remark = itemProductRemarks.where((e) => remarkCodes.contains(e.mDetail)).toList();

        singleCartInfo.addAll({"remarkList": remark.map((e) => e.toJson()).toList()});
        //套餐
        final Set<String> selectSetMealCodes = <String>{
          for (final e in formData.entries)
            if (e.key.startsWith('setMeal_')) ...?e.value,
        };
        final selectAllSetMealList = setMealList
            .where((e) => selectSetMealCodes.contains(e.mProductCode))
            .map((e) => e.toJson())
            .toList();
        singleCartInfo.addAll({"setMealList": selectAllSetMealList});
      }
      final cartModel = CartModel.fromJson(singleCartInfo);

      final boxCartList = (await box.get(Config.shoppingCart) as List?)?.cast<CartModel>();

      if (boxCartList == null) {
        await box.put(Config.shoppingCart, [cartModel]);
      } else {
        final index = boxCartList.indexWhere((e) => e.product?.mCode == cartModel.product?.mCode);
        if (index == -1) {
          boxCartList.add(cartModel);
        } else {
          boxCartList[index] = cartModel;
        }
        await box.put(Config.shoppingCart, boxCartList);
      }
      CustomDialog.successMessages(LocaleKeys.paramSuccess.trArgs([LocaleKeys.addToCart.tr]));
      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } catch (e) {
      CustomDialog.errorMessages(LocaleKeys.paramFailed.trArgs([LocaleKeys.addToCart.tr]));
    }
  }
}
