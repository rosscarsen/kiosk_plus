import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiosk_plus/app/widgets/auto_text.dart';
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
            controller.companyName.value,
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

    return Container(
      clipBehavior: Clip.hardEdge,
      width: 160,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF2F4F8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 22, offset: Offset(4, 0))],
      ),
      child: ExtendedTabBar(
        controller: controller.firstLevelTabController,
        mainAxisAlignment: MainAxisAlignment.start,
        dividerColor: Colors.transparent,
        isScrollable: true,
        scrollDirection: Axis.vertical,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF666666),
        indicator: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(14)),
        tabs: controller.categoryTreeProductList.map((c) {
          return Tab(
            height: 48,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: AutoText(
                c.mDescription ?? c.mCategory ?? '',
                maxLines: 1,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
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
      controller: controller.firstLevelTabController,
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

    final TabController secondController = controller.secondLevelControllers[firstIndex]!;

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
            controller: secondController,
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
            controller: secondController,
            link: true,
            scrollDirection: Axis.vertical,
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

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.82,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(context, products[index]),
    );
  }

  /// 商品卡片
  Widget _buildProductCard(BuildContext context, Product product) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 14, offset: Offset(0, 8))],
          border: Border.all(color: Colors.grey[100]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 图片
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: _buildProductImageView(product.imagesPath ?? ''),
              ),
            ),

            /// 文本
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.mCode ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.mDesc1 ?? '',
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
  }
 */
}

/*class HallView extends GetView<HallController> {
  const HallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: GetBuilder<HallController>(
          id: "hall_app_bar",
          builder: (_) {
            return Text(
              controller.companyName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
            );
          },
        ),
        centerTitle: true,
      ),
      body: Row(
        children: [
          ExtendedTabBar(
            indicator: const ColorTabIndicator(Colors.blue),
            labelColor: Colors.black,
            scrollDirection: Axis.vertical,
            tabs: controller.categoryTreeProductList.map((e) => ExtendedTab(text: e.mDescription ?? '')).toList(),
            controller: controller.tabController,
          ),
        ],
      ),
      // body: Row(children: [_buildLeftNav(context), _buildRightContent(context)]),
    );
  }

  Widget _buildLeftNav(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 180),
      width: context.width * 0.35,
      child: GetBuilder<HallController>(
        id: "hall_left_nav",
        builder: (_) {
          return ListView.separated(
            itemCount: controller.categoryTreeProductList.length,
            separatorBuilder: (_, __) => Divider(color: Colors.black12),
            itemBuilder: (context, index) {
              final isSelected = controller.selectIndex == index;
              return Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    height: 28,
                    width: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: AutoText(
                        controller.categoryTreeProductList[index].mDescription ?? '',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () {
                        controller.changeLeftNavIndex(index);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRightContent(BuildContext context) {
    return Expanded(
      child: GetBuilder<HallController>(
        id: "hall_right_nav",
        builder: (_) {
          return ScrollableListTabScroller.defaultComponents(
            itemScrollController: controller.itemScrollController,
            itemPositionsListener: controller.itemPositionsListener,
            itemCount: controller.childrenCount,
            headerContainerProps: const HeaderContainerProps(height: 56),
            tabBarProps: const TabBarProps(dividerColor: Colors.transparent),
            tabBuilder: (context, index, active) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  controller.children?[index].mDescription ?? '',
                  style: active ? const TextStyle(fontWeight: FontWeight.bold, color: Colors.green) : null,
                ),
              );
            },
            itemBuilder: (context, index) {
              final products = controller.children?[index].products;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.children?[index].mDescription ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  _buildProductView(products),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductView(List<Product>? products) {
    return Column(
      children: List.generate(products?.length ?? 0, (index) {
        final String imagePath = products![index].imagesPath ?? "";
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              _buildProductImageView(imagePath),
              const SizedBox(width: 12),
              Expanded(child: Text(products[index].mDesc1 ?? "")),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProductImageView(String imagePath) {
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
  }
}
 */
