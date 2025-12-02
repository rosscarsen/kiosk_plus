import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../model/api_data_model/data_result_model.dart';
import 'hall_controller.dart';

class HallView extends GetView<HallController> {
  const HallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Obx(
          () => Text(
            controller.companyName.value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<HallController>(
        id: "hall_body",
        builder: (_) {
          return controller.isDataReady ? _buildMain(context) : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  //主视图
  Widget _buildMain(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(children: [_buildLeftNav(context), _buildRightContainer(context)]),
    );
  }

  /// 左边第一大类
  Widget _buildLeftNav(BuildContext context) {
    return ExtendedTabBar(
      isScrollable: true,
      controller: controller.firstLevelTabController,
      scrollDirection: Axis.vertical,
      indicator: const ColorTabIndicator(Colors.blue),
      labelColor: Colors.black,
      tabs: controller.categoryTreeProductList
          .map((c) => ExtendedTab(text: c.mDescription ?? c.mCategory ?? '', scrollDirection: Axis.vertical))
          .toList(),
    );
  }

  /// 右边内容
  Widget _buildRightContainer(BuildContext context) {
    return Expanded(
      child: ExtendedTabBarView(
        controller: controller.firstLevelTabController,
        children: controller.categoryTreeProductList
            .map((category) => _buildSecondLevelAndProducts(context, category))
            .toList(),
      ),
    );
  }

  /// 右边第二大类
  Widget _buildSecondLevelAndProducts(BuildContext context, CategoryTreeProduct category) {
    final int firstIndex = controller.categoryTreeProductList.indexOf(category);
    final children = category.children ?? [];

    if (children.isEmpty) {
      return const Center(child: Text('无子分类'));
    }

    final TabController secondController = controller.secondLevelControllers[firstIndex]!;

    return Column(
      children: [
        /// ✅ 右上：第二大类（可滚动，不溢出）
        ExtendedTabBar(
          controller: secondController,
          isScrollable: true, // ✅ 关键：防止溢出
          scrollDirection: Axis.horizontal,
          indicator: const ColorTabIndicator(Colors.blue),
          labelColor: Colors.black,
          mainAxisAlignment: MainAxisAlignment.start,
          tabs: children
              .map((e) => ExtendedTab(text: e.mDescription ?? e.mCategory ?? '', scrollDirection: Axis.vertical))
              .toList(),
        ),

        /// ✅ 右下：商品区（上下滑优先切二级，边界自动切一级）
        Expanded(
          child: ExtendedTabBarView(
            controller: secondController,
            link: true, // ✅ 关键：允许滚动传递到一级
            scrollDirection: Axis.vertical,
            children: children.map((subCategory) => _buildProductList(context, subCategory)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(BuildContext context, CategoryTreeProduct subCategory) {
    return ListView.builder(
      itemCount: subCategory.products?.length ?? 0,
      itemBuilder: (context, index) {
        final product = subCategory.products?[index];
        return ListTile(
          leading: _buildProductImageView(product?.imagesPath ?? ''),
          title: Text(product?.mCode ?? ''),
          subtitle: Text(product?.mDesc1 ?? ''),
        );
      },
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
