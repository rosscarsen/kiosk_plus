import 'package:cached_network_image/cached_network_image.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../model/cart/cart_model.dart';
import '../../routes/app_pages.dart';
import '../../translations/locale_keys.dart';
import '../../utils/constants.dart';
import '../../utils/custom_alert.dart';
import '../../utils/dec_calc.dart';
import '../../widgets/auto_text.dart';
import 'cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(title: Text(LocaleKeys.cart.tr), centerTitle: true),
      body: SafeArea(child: _buildMain(context)),
    );
  }

  /// 主视图
  Widget _buildMain(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 8.0,
              children: [
                _buildAgreement(),
                Expanded(child: _buildCartList(context)),
              ],
            ),
          ),
        ),
        _buildBottomBar(context),
      ],
    );
  }

  /// 协议
  Widget _buildAgreement() {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        children: [
          TextSpan(text: LocaleKeys.acceptAgree.tr),
          TextSpan(
            text: "《${LocaleKeys.termAndConditions.tr}》",
            style: const TextStyle(color: AppColors.kActive, fontWeight: FontWeight.w600),
            recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(Routes.PRIVACY),
          ),
        ],
      ),
    );
  }

  /// 空购物车
  Widget _buildEmptyCart() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/cart_empty.png', width: 180),
            const SizedBox(height: 12),
            Text(
              LocaleKeys.cartIsEmpty.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.kTextSub),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(LocaleKeys.goShoppingNow.tr),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                Get.until((route) => route.name == Routes.HALL);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 购物车列表
  Widget _buildCartList(BuildContext context) {
    return GetBuilder<CartController>(
      id: "cartList",
      builder: (_) {
        if (!controller.isDataReady) {
          return Skeletonizer(
            enabled: true,
            effect: const ShimmerEffect(
              baseColor: Color(0xFFE0E0E0),
              highlightColor: Color(0xFFF5F5F5),
              duration: Duration(milliseconds: 1200),
            ),
            child: ListView.builder(itemCount: 7, itemBuilder: (context, index) => _skeletonItem()),
          );
        }
        if (controller.cartList.isEmpty) {
          return _buildEmptyCart();
        }
        return ListView.builder(
          itemCount: controller.cartList.length,
          itemBuilder: (context, index) {
            final item = controller.cartList[index];
            return cartItem(context: context, item: item, index: index);
          },
        );
      },
    );
  }

  /// 购物车项
  Widget cartItem({required BuildContext context, required CartModel item, required int index}) {
    final product = item.product;
    final productPrice = DecUtil.from(product?.mPrice ?? "0.00"); //商品单价
    final productQty = DecUtil.from(product?.qty ?? "1"); //商品数量
    final productTotalPrice = DecUtil.mul(productPrice, productQty); //商品总价
    final remark = item.remarkList ?? [];
    final setMealList = item.setMealList ?? [];
    Decimal subTotal = productTotalPrice;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          /// 商品信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _productImage(product?.imagesPath ?? ""),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.mDesc1 ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${DecUtil.formatAmount(productPrice)} × $productQty",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: product?.mDesc1 ?? "",
                        style: TextStyle(color: AppColors.kTextSub),
                      ),
                      TextSpan(
                        text: " \$$productPrice",
                        style: const TextStyle(color: AppColors.kPrice),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text("x$productQty", style: const TextStyle(color: AppColors.kTextSub)),
              ),
              Expanded(
                flex: 1,
                child: AutoText(
                  "\$${DecUtil.formatAmount(productTotalPrice)}",
                  style: const TextStyle(color: AppColors.kPrice),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          //备注信息
          if (remark.isNotEmpty)
            Column(
              children: remark.map((e) {
                Decimal remarkItemTotalAmount = Decimal.zero;
                // 备注项单价
                final remarkPrice = DecUtil.from(e.mPrice ?? "0.00");
                switch (e.mType) {
                  case 0:
                    // ✅ 加价 = 单价 * 商品数量
                    remarkItemTotalAmount = DecUtil.mul(remarkPrice, productQty);
                    subTotal = DecUtil.add(subTotal, remarkItemTotalAmount);
                    break;

                  case 1:
                    // ✅ 折扣 = (remarkPrice / 100) * 商品单价 * 数量
                    remarkItemTotalAmount = DecUtil.mul(
                      DecUtil.mul(DecUtil.div(remarkPrice, 100), productPrice),
                      productQty,
                    );
                    subTotal = DecUtil.sub(subTotal, remarkItemTotalAmount);
                    break;

                  case 2:
                    // ✅ 倍数 = 基础金额 * remarkPrice
                    remarkItemTotalAmount = DecUtil.mul(productTotalPrice, remarkPrice);
                    subTotal = DecUtil.add(subTotal, remarkItemTotalAmount);
                    break;
                }
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "  ${e.mDetail ?? ""}",
                              style: TextStyle(color: AppColors.kTextSub),
                            ),
                            TextSpan(
                              text: e.mType == 1 ? " -${e.mPrice ?? "0.00"}%" : " +${e.mPrice ?? "0.00"}",
                              style: const TextStyle(color: AppColors.kPrice),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("x$productQty", style: const TextStyle(color: AppColors.kTextSub)),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoText(
                        "\$${DecUtil.formatAmount(e.mType == 1 ? -remarkItemTotalAmount : remarkItemTotalAmount)}",
                        style: const TextStyle(color: AppColors.kPrice),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          // 套餐
          if (setMealList.isNotEmpty)
            Column(
              children: setMealList.map((e) {
                // 备注项单价
                final setMealPrice = DecUtil.from(e.mPrice ?? "0.00");
                // 套餐数量
                final setMealQty = DecUtil.mul(DecUtil.from(e.mQty ?? "0"), productQty);
                final Decimal setMealItemTotalAmount = DecUtil.mul(setMealPrice, setMealQty);
                subTotal = DecUtil.add(subTotal, setMealItemTotalAmount);
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "+${e.mName ?? ""}",
                              style: TextStyle(color: AppColors.kTextSub),
                            ),
                            TextSpan(
                              text: " \$$setMealPrice",
                              style: const TextStyle(color: AppColors.kPrice),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text("x$setMealQty", style: const TextStyle(color: AppColors.kTextSub)),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoText(
                        "\$${DecUtil.formatAmount(setMealItemTotalAmount)}",
                        style: const TextStyle(color: AppColors.kPrice),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

          // 分割線
          Divider(height: 24),
          Row(
            children: [
              Text(LocaleKeys.subtotal.tr, style: TextStyle(color: Colors.grey.shade600)),
              const Spacer(),
              Text(
                "\$${DecUtil.formatAmount(subTotal)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.kPrice),
              ),
            ],
          ),
          // 按鈕組
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8.0,
              children: [
                //删除
                FilledButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text(LocaleKeys.delete.tr),
                  style: TextButton.styleFrom(backgroundColor: AppColors.kDelete, foregroundColor: Colors.white),
                  onPressed: () async {
                    await CustomAlert.iosAlert(
                      message: LocaleKeys.areYouSureDelete.tr,
                      showCancel: true,
                      onConfirm: () async {
                        await controller.removeCartItem(index);
                      },
                    );
                  },
                ),
                //修改
                FilledButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text(LocaleKeys.edit.tr),
                  style: TextButton.styleFrom(backgroundColor: AppColors.kEdit, foregroundColor: Colors.white),
                  onPressed: () async {
                    Get.toNamed(Routes.PRODUCT_DETAIL, arguments: item);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 购物车底部栏
  Widget _buildBottomBar(BuildContext context) {
    return ColoredBox(
      color: Color(0xFFF8FAFC),
      child: GetBuilder<CartController>(
        id: "totalAmount",
        builder: (ctl) {
          // 数据加载完成前显示骨架屏
          if (!ctl.isDataReady) {
            return Skeletonizer(
              enabled: true,
              effect: const ShimmerEffect(
                baseColor: Color(0xFFE0E0E0),
                highlightColor: Color(0xFFF5F5F5),
                duration: Duration(milliseconds: 1200),
              ),
              child: ListTile(
                title: Text('Item number  as title'),
                subtitle: const Text('Subtitle here'),
                trailing: const Icon(Icons.ac_unit),
              ),
            );
          }
          if (ctl.cartList.isEmpty) {
            return Container();
          }
          String subtitle = LocaleKeys.totalPiece.trArgs([ctl.cartQuantity.toString()]);

          if (ctl.calendarDiscount != Decimal.zero) {
            subtitle += " (${LocaleKeys.discount.trArgs([ctl.calendarDiscount.toString()])}:${ctl.calendarDiscount}%)";
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(),
              ListTile(
                title: Text(
                  "${LocaleKeys.total.tr}: \$${DecUtil.formatAmount(ctl.cartAmount)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kPrice,
                    letterSpacing: 0.5,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kPrice,
                    letterSpacing: 0.5,
                  ),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.kCheckOut, foregroundColor: Colors.white),
                  child: Text(LocaleKeys.checkout.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 购物车商品图片
  Widget _productImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: path.isEmpty
            ? Image.asset("assets/notfound.png")
            : CachedNetworkImage(imageUrl: path, fit: BoxFit.cover),
      ),
    );
  }

  /// 购物车商品骨架屏
  Widget _skeletonItem() {
    return Container(margin: const EdgeInsets.symmetric(vertical: 6), height: 120, decoration: _cardDecoration());
  }

  /// 购物车商品卡片装饰
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 12, offset: const Offset(0, 4))],
    );
  }
}
