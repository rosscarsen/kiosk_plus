/* import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiosk_plus/app/widgets/auto_text.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../model/api_data_model/data_result_model.dart';
import 'hall_controller.dart';

class HallView extends GetView<HallController> {
  const HallView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Obx(
          () => Text(
            "",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: themeColor, letterSpacing: 0.4),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              spacing: 20,
              children: [
                // Badge(label: Text('100'), child: Icon(Icons.shopping_cart)),
                Badge.count(count: 5, child: const Icon(Icons.shopping_cart)),
                Text('\$100.00', style: const TextStyle(fontSize: 20.0)),
              ],
            ),
          ),
        ],
        shadowColor: Colors.black.withAlpha(15),
      ),
      body: GetBuilder<HallController>(
        id: "hall_body",
        builder: (_) {
          if (!controller.isDataReady) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 3));
          }
          return _buildMain(context);
        },
      ),
    );
  }

  //  主视图
  Widget _buildMain(BuildContext context) {
    return Row(
      children: [
        _buildLeftNav(context),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8, top: 10, bottom: 10, right: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(26)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8))],
            ),
            child: _buildRightContainer(context),
          ),
        ),
      ],
    );
  }

  /// 左侧一级分类
  Widget _buildLeftNav(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth < 600 ? 86 : 120, // ✅ 更窄，适合小屏点餐机
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF2F4F8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20)],
      ),
      child: ExtendedTabBar(
        //controller: controller.firstLevelTabController,
        isScrollable: true,
        scrollDirection: Axis.vertical,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF666666),
        indicator: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(12)),
        tabs: controller.categoryTreeProductList.map((c) {
          return Tab(
            height: 60, // ✅ 高一点，方便换行
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                c.mDescription ?? c.mCategory ?? '',
                maxLines: 2, // ✅ 允许两行
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center, // ✅ 居中更像商用终端
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 右侧内容
  Widget _buildRightContainer(BuildContext context) {
    return ExtendedTabBarView(
      //controller: controller.firstLevelTabController,
      children: controller.categoryTreeProductList
          .map((category) => _buildSecondLevelAndProducts(context, category))
          .toList(),
    );
  }

  /// 二级分类 + 商品
  Widget _buildSecondLevelAndProducts(BuildContext context, CategoryTreeProduct category) {
    final int firstIndex = controller.categoryTreeProductList.indexOf(category);
    final children = category.children ?? [];
    final themeColor = Theme.of(context).primaryColor;

    if (children.isEmpty) {
      return const Center(
        child: Text('无子分类', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    //final TabController secondController = controller.secondLevelControllers[firstIndex]!;

    return Column(
      children: [
        /// 二级分类
        Container(
          height: 64,
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(0, 14, 12, 10),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: ExtendedTabBar(
            //controller: secondController,
            isScrollable: true,
            scrollDirection: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.start,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(14)),
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF666666),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),

            labelPadding: const EdgeInsets.symmetric(horizontal: 18),

            tabs: children.map((e) {
              return Tab(
                height: 44,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AutoText(e.mDescription ?? e.mCategory ?? '', maxLines: 1, style: const TextStyle()),
                ),
              );
            }).toList(),

            overlayColor: WidgetStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
          ),
        ),

        /// 商品区
        Expanded(
          child: ExtendedTabBarView(
            // controller: secondController,
            shouldIgnorePointerWhenScrolling: false,
            link: true,
            scrollDirection: Axis.horizontal,
            children: children.map((subCategory) => _buildProductList(context, subCategory)).toList(),
          ),
        ),
      ],
    );
  }

  /// 商品网格
  Widget _buildProductList(BuildContext context, CategoryTreeProduct subCategory) {
    final products = subCategory.products ?? [];

    if (products.isEmpty) {
      return const Center(
        child: Text('暂无商品', style: TextStyle(color: Colors.grey)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double designWidth = width > 600 ? 200 : 150;
        return SizedBox(
          width: designWidth,
          height: constraints.maxHeight,
          child: ResponsiveGridList(
            minItemWidth: designWidth,
            horizontalGridSpacing: 8,
            verticalGridSpacing: 8,
            children: products.map((product) {
              return _buildProductCard(product);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return SizedBox(
      height: 240,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 图片
            Expanded(child: _buildProductImageView(product.imagesPath ?? '')),

            // 文字区
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoText(
                    product.mDesc1 ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  AutoText(
                    '\$${product.mPrice}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImageView(String imagePath) {
    return CachedNetworkImage(
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
      errorWidget: (_, _, _) => Container(
        color: const Color(0xFFF5F7FA),
        alignment: Alignment.center,
        child: Image.asset("assets/notfound.png", width: 80),
      ),
    );
  }

}
  */

/* Widget _buildProductImageView(String imagePath) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: Colors.grey[200]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          // imageUrl: "$imagePath?timestamp=${DateTime.now().millisecondsSinceEpoch}",
          imageUrl: imagePath.isNotEmpty ? "$imagePath?timestamp=${DateTime.now().millisecondsSinceEpoch}" : "",
          fit: BoxFit.cover,
          placeholder: (context, url) => Skeletonizer(
            enabled: true,
            effect: const ShimmerEffect(
              baseColor: Color(0xFFE0E0E0),
              highlightColor: Color(0xFFF5F5F5),
              duration: Duration(milliseconds: 1200),
            ),
            child: Container(width: 100, height: 100, color: Colors.grey),
          ),
          errorWidget: (context, url, error) => Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: Image.asset("assets/notfound.png", fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }*/

/* import 'package:flutter/material.dart';
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
 */
