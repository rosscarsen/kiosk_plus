import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../utils/dec_calc.dart';
import '../../utils/logger.dart';

class ProductDetailController extends GetxController {
  final formKey = GlobalKey<FormBuilderState>();
  final box = IsolatedHive.box(Config.kioskHiveBox);
  bool isDataReady = false;
  Product? product;
  double get productPrice => double.tryParse(product?.mPrice ?? "0") ?? 0;

  /// 食品备注列表
  List<ProductRemark> itemProductRemarks = [];

  /// 商品数量
  int productQty = 1;

  /// 商品单价
  double totalAmount = 0;

  /// 选择的食品备注
  List<String> selectRemarks = [];

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
    product = null;
    itemProductRemarks.clear();
    selectRemarks.clear();
    super.onClose();
  }

  /// 初始化数据
  /// 从路由参数中获取产品详情数据
  /// 如果数据为空，则返回上一页
  /// 如果数据不为空，则设置isDataReady为true
  void initData() async {
    isDataReady = false;
    product = Get.arguments as Product?;
    //进入默认1件商品
    totalAmount = double.tryParse(product?.mPrice ?? "0") ?? 0;
    if (product?.productRemarks?.isNotEmpty ?? false) {
      await getProductRemark(product!.productRemarks!);
    }
    if (product == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return;
    }
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
    remarksAmount();
    update(["bottom"]);
  }

  /// 备注金额
  void remarksAmount() {
    final Decimal baseAmount = DecUtil.mul(productPrice, productQty);

    if (itemProductRemarks.isEmpty || selectRemarks.isEmpty) {
      totalAmount = baseAmount.toDouble();
      update(["bottom"]);
      return;
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
          multiAmount = DecUtil.add(multiAmount, DecUtil.mul(baseAmount, remarkPrice));
          break;
      }
    }

    // ✅ 最终备注影响金额
    final Decimal finalRemarkAmount = DecUtil.add(DecUtil.sub(addAmount, discountAmount), multiAmount);

    // ✅ 最终应付金额
    totalAmount = DecUtil.add(baseAmount, finalRemarkAmount).toDouble();
  }
}
