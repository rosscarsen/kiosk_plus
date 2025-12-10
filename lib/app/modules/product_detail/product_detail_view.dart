import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../translations/locale_keys.dart';
import '../../utils/constants.dart';
import '../../utils/dec_calc.dart';
import '../../widgets/cart_quantity_stepper.dart';
import 'product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      /*  floatingActionButton: FloatingActionButton(
        onPressed: () {
          final c = DecUtil.div(1, 100);
          print(c);
        },
      ), */
      //appBar: AppBar(title: Text('')),
      body: GetBuilder<ProductDetailController>(
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
                    LocaleKeys.totalPiece.trArgs([ctl.productQty.toString()]),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kPrice,
                      letterSpacing: 0.5,
                    ),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.kPrice, foregroundColor: Colors.white),
                    child: Text(LocaleKeys.addToCart.tr),
                    onPressed: () {},
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
          ),
        ];
      },
      body: _buildDetail(context, ctl),
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 产品基本信息区域
          Container(
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
          ),

          // 分隔线
          const Divider(height: 1, thickness: 1, color: AppColors.kLine),

          if (productRemarksList.isNotEmpty)
            // 备注
            _buildProductRemarks(context, ctl),
          // 分隔线
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // 其他信息区域（可根据需要添加）
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '规格信息',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('重量:', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    const SizedBox(width: 8),
                    Text(
                      '500g', // 这里可以替换为实际重量
                      style: TextStyle(fontSize: 14, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ],
            ),
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

  /// ✅ 商品图片 - 智能适配
  Widget _buildProductImageView(String imagePath) {
    if (imagePath.isEmpty || !imagePath.startsWith('http')) {
      return Container(
        color: const Color(0xFFF5F7FA),
        alignment: Alignment.center,
        child: Image.asset("assets/notfound.png", width: 80, fit: BoxFit.contain),
      );
    }
    ValueNotifier<bool> isImageLoaded = ValueNotifier<bool>(false);
    ValueNotifier<BoxFit> imageFit = ValueNotifier<BoxFit>(BoxFit.cover);

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
          child: CachedNetworkImage(
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
                // 智能判断图片适配方式
                _determineImageFit(imageProvider, imageFit);
              });

              return ValueListenableBuilder<BoxFit>(
                valueListenable: imageFit,
                builder: (context, fit, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: fit == BoxFit.contain ? const Color(0xFFF8FAFC) : Colors.transparent,
                    ),
                    child: Image(image: imageProvider, fit: fit, width: double.infinity, height: double.infinity),
                  );
                },
              );
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

  /// 智能判断图片适配方式
  void _determineImageFit(ImageProvider imageProvider, ValueNotifier<BoxFit> imageFit) {
    final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
    late ImageStreamListener listener;

    listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
      final image = info.image;
      final double imageAspectRatio = image.width / image.height;

      // 更宽松的判断条件，优先使用cover来填充容器
      if (imageAspectRatio >= 0.5 && imageAspectRatio <= 2.0) {
        // 大部分正常比例的图片都使用cover，确保填充效果
        imageFit.value = BoxFit.cover;
      } else {
        // 只有极端比例的图片才使用contain
        imageFit.value = BoxFit.contain;
      }

      stream.removeListener(listener);
    });

    stream.addListener(listener);
  }
}
