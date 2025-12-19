import 'package:cached_network_image/cached_network_image.dart';
import 'package:decimal/decimal.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../translations/locale_keys.dart';
import '../../utils/constants.dart';
import '../../utils/custom_dialog.dart';
import '../../utils/dec_calc.dart';
import '../../utils/logger.dart';
import '../../widgets/cart_quantity_stepper.dart';
import 'product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SafeArea(
        bottom: true,
        child: GetBuilder<ProductDetailController>(
          init: ProductDetailController(),
          id: "body",
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
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text('Item number $index as title'),
                        subtitle: const Text('Subtitle here'),
                        trailing: const Icon(Icons.ac_unit),
                      ),
                    );
                  },
                ),
              );
            }
            return _buildMain(context, ctl);
          },
        ),
      ),

      bottomNavigationBar: ColoredBox(
        color: Color(0xFFF8FAFC),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(border: Border(top: Divider.createBorderSide(context, width: 1.0))),
            ),
            GetBuilder<ProductDetailController>(
              id: "bottom",
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
                String subtitle = LocaleKeys.totalPiece.trArgs([ctl.productQty.toString()]);

                if (ctl.calendarDiscount != Decimal.zero) {
                  subtitle +=
                      " (${LocaleKeys.discount.trArgs([ctl.calendarDiscount.toString()])}:${ctl.calendarDiscount}%)";
                }
                return ListTile(
                  title: Text(
                    "${LocaleKeys.total.tr}: \$${DecUtil.formatAmount(ctl.totalAmount)}",
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.kAddCart, foregroundColor: Colors.white),
                    child: Text(LocaleKeys.addToCart.tr),
                    onPressed: () {
                      final bool validate = ctl.checkSetMeal();
                      if (validate && (ctl.formKey.currentState?.saveAndValidate() ?? false)) {
                        ctl.addToCart();
                      } else {
                        logger.f("验证失败");
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 主视图
  Widget _buildMain(BuildContext context, ProductDetailController ctl) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Center(
                child: Container(
                  width: 200, // 固定宽度
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildProductImageView(ctl.product?.imagesPath ?? ""),
                  ),
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(235),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.kTextMain),
                onPressed: () => Get.back(),
                splashRadius: 24,
              ),
            ),
          ),
        ];
      },
      body: FormBuilder(key: ctl.formKey, child: _buildDetail(context, ctl)),
    );
  }

  /// 详细信息
  Widget _buildDetail(BuildContext context, ProductDetailController ctl) {
    final productRemarksList = ctl.itemProductRemarks;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, -5), spreadRadius: 0),
          BoxShadow(color: Color(0x0F000000), blurRadius: 25, offset: Offset(0, -10), spreadRadius: 0),
        ],
      ),
      // 产品详细信息区域
      child: SingleChildScrollView(
        controller: ctl.scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 产品基本信息区域
            _buildBaseInfo(context, ctl),

            // 分隔线
            const Divider(height: 1, thickness: 1, color: AppColors.kLine),

            if (productRemarksList.isNotEmpty)
              // 备注
              _buildProductRemarks(context, ctl),
            if (ctl.extraInfo.isNotEmpty)
              // 分隔线
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            if (ctl.extraInfo.isNotEmpty)
              // 套餐视图
              _buildSetMealView(context, ctl),
          ],
        ),
      ),
    );
  }

  /// 基本信息
  Widget _buildBaseInfo(BuildContext context, ProductDetailController ctl) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 产品名称
                SelectableText(
                  ctl.product?.mDesc1 ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kTextMain,
                    letterSpacing: 0.3,
                    height: 1.3,
                  ),
                  contextMenuBuilder: (context, editableTextState) {
                    return AdaptiveTextSelectionToolbar.editableText(editableTextState: editableTextState);
                  },
                ),
                const SizedBox(height: 8),
                // 价格信息
                Text(
                  '\$${DecUtil.formatAmount(ctl.productPrice)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kPrice,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // 商品数量选择器
          CartQuantityStepper(
            onChanged: (int value) {
              ctl.productQty = value;
              ctl.changeTotal();
            },
          ),
        ],
      ),
    );
  }

  /// 食品备注
  Widget _buildProductRemarks(BuildContext context, ProductDetailController ctl) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.remarks.tr,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.kTextMain),
          ),
          const SizedBox(height: 12),
          FormBuilderField<List<String>>(
            name: 'remark',
            initialValue: const [],
            onChanged: (List<String>? value) {
              ctl.selectRemarks = value ?? [];
              ctl.changeTotal();
            },
            builder: (field) {
              final selectedValues = field.value ?? [];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ctl.itemProductRemarks.map((e) {
                  final value = e.mDetail ?? '';
                  final disabled = e.mSoldOut == 1;

                  return ChoiceChip(
                    label: Text(
                      value,
                      style: TextStyle(
                        color: selectedValues.contains(value) ? Colors.white : AppColors.kTextMain,
                        decoration: disabled ? TextDecoration.lineThrough : null,
                        decorationColor: disabled ? AppColors.kPrice : null,
                        decorationThickness: 3,
                      ),
                    ),

                    selected: selectedValues.contains(value),
                    selectedColor: AppColors.kPrimary,
                    checkmarkColor: Colors.white,
                    backgroundColor: disabled ? Colors.grey.shade200 : Colors.grey.shade100,
                    disabledColor: Colors.grey.shade200,
                    onSelected: disabled
                        ? null
                        : (selected) {
                            final newValues = [...selectedValues];
                            if (selected) {
                              newValues.add(value);
                            } else {
                              newValues.remove(value);
                            }
                            field.didChange(newValues);
                          },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 套餐视图
  Widget _buildSetMealView(BuildContext context, ProductDetailController ctl) {
    return Padding(
      key: ctl.setMealKey,
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 8.0,
        children: ctl.extraInfo.asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          // 套餐限制
          final setMealLimit = e.setMealLimit;

          // 套餐最大选择数量
          final tempMax = setMealLimit?.limitMax ?? 0;
          final max = tempMax > 0 ? tempMax : 1;
          // 强制选择
          final foreSelect = setMealLimit?.obligatory ?? 0;
          // 套餐数据
          final setMealData = setMealLimit?.setMealData ?? [];
          // 套餐组标题
          String msgTitle = "";
          if (max > 1) {
            if (foreSelect == 1) {
              msgTitle = LocaleKeys.requireItemsParam.trArgs([max.toString()]);
            } else {
              msgTitle = LocaleKeys.selectUpToItemsParam.trArgs([max.toString()]);
            }
          }

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ExpansionTileOutlined(
              controller: ctl.groupController,
              index: index,
              initiallyExpanded: index == 0,
              border: BoxBorder.all(color: Colors.grey.withAlpha(60)),
              title: RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: Get.locale.toString() == "en_US" ? setMealLimit?.enus ?? "" : setMealLimit?.zhtw ?? "",
                      style: TextStyle(color: AppColors.kTextMain, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if (msgTitle.isNotEmpty)
                      TextSpan(
                        text: "  ($msgTitle)",
                        style: TextStyle(color: AppColors.kRequire, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              children: [
                FormBuilderField<List<String>>(
                  name: 'setMeal_$index',
                  initialValue: controller.selectSetMeal,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocaleKeys.requireItemsParam.trArgs(["1"]);
                    }
                    return null;
                  },

                  onChanged: (List<String>? values) {
                    final currentValues = values ?? [];
                    final itemAllItems = setMealData
                        .map((e) => e.mProductCode)
                        .whereType<String>()
                        .where((e) => e.isNotEmpty)
                        .toList();
                    ctl.changeSelectSetMeal(itemAllSelectedItems: currentValues, itemAllItems: itemAllItems);
                    if (currentValues.isEmpty) {
                      CustomDialog.errorMessages(LocaleKeys.requireItemsParam.trArgs(["1"]));
                      return;
                    }
                    if (foreSelect == 1 && currentValues.length != max) {
                      CustomDialog.errorMessages(LocaleKeys.requireItemsParam.trArgs([max.toString()]));
                      return;
                    }
                  },
                  builder: (field) {
                    final selectedValues = field.value ?? [];
                    return InputDecorator(
                      decoration: InputDecoration(border: InputBorder.none, errorText: field.errorText),
                      child: MultiSelectCheckList(
                        maxSelectableCount: max,
                        onMaximumSelected: (selectedItems, selectedItem) {
                          CustomDialog.errorMessages(
                            LocaleKeys.selectUpToItemsParam.trArgs([selectedItems.length.toString()]),
                          );
                        },
                        items: setMealData
                            .map(
                              (e) => CheckListCard<String>(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                enabled: e.soldOut == 0,
                                value: e.mProductCode ?? "",
                                title: Text(e.mName ?? ""),
                                selected: selectedValues.contains(e.mProductCode ?? ""),
                                selectedColor: AppColors.kPrimary,
                                checkColor: Colors.white,
                                checkBoxBorderSide: BorderSide(color: Colors.grey, width: 2.0),
                              ),
                            )
                            .toList(),
                        onChange: (allSelectedItems, selectedItem) {
                          field.didChange(allSelectedItems);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ✅ 商品图片
  Widget _buildProductImageView(String imagePath) {
    ValueNotifier<bool> isImageLoaded = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isImageLoaded,
      builder: (context, isLoaded, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            if (isImageLoaded.value) {
              await showImageViewer(
                context,
                NetworkImage(imagePath),
                useSafeArea: false,
                swipeDismissible: false,
                doubleTapZoomable: true,
              );
            }
          },
          child: imagePath.isEmpty
              ? Image.asset("assets/notfound.png")
              : CachedNetworkImage(
                  imageUrl: imagePath.isNotEmpty ? "$imagePath?ts=${DateTime.now().millisecondsSinceEpoch}" : "",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, _) => Skeletonizer(
                    enabled: true,
                    effect: const ShimmerEffect(
                      baseColor: Color(0xFFE0E0E0),
                      highlightColor: Color(0xFFF5F5F5),
                      duration: Duration(milliseconds: 1200),
                    ),
                    child: Container(color: const Color(0xFFF0F0F0), width: 100, height: 100),
                  ),
                  imageBuilder: (context, imageProvider) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      isImageLoaded.value = true;
                    });
                    return Image(image: imageProvider, fit: BoxFit.cover);
                  },
                  errorWidget: (_, _, _) => Container(
                    color: const Color(0xFFF5F7FA),
                    alignment: Alignment.center,
                    child: Image.asset("assets/notfound.png", width: 80),
                  ),
                ),
        );
      },
    );
  }
}
