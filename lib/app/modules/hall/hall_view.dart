import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiosk_plus/app/widgets/auto_text.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:scrollable_list_tab_scroller/scrollable_list_tab_scroller.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:view_tabbar/view_tabbar.dart';
import '../../model/api_data_model/data_result_model.dart';
import 'hall_controller.dart';

class HallView extends GetView<HallController> {
  const HallView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              spacing: 20,
              children: [
                Badge.count(count: 5, child: const Icon(Icons.shopping_cart)),
                Text('\$100.00', style: const TextStyle(fontSize: 20.0)),
              ],
            ),
          ),
        ],
        shadowColor: Colors.black.withAlpha(15),
      ),
      body: _buildMain(context),
    );
  }

  /// 构建主界面
  Widget _buildMain(BuildContext context) {
    return GetBuilder<HallController>(
      id: "hall_left_nav",
      builder: (_) {
        if (!controller.isDataReady) {
          return const Center(child: CircularProgressIndicator());
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 一级分类
            _buildLeftNav(context),
            const VerticalDivider(width: 5, thickness: 1, indent: 5, endIndent: 5),
            _buildRightContainer(context),
          ],
        );
      },
    );

    return Row(
      children: [
        _buildLeftNav(context),
        Expanded(child: _buildRightContainer(context)),
      ],
    );
  }

  /// 左侧一级分类
  Widget _buildLeftNav(BuildContext context) {
    return ViewTabBar(
      width: 150,
      itemCount: controller.categoryTreeProductList.length,
      direction: Axis.vertical,
      pageController: controller.leftPageController,
      tabBarController: controller.leftTabBarController,
      animationDuration: Duration(milliseconds: 300),
      builder: (context, index) {
        return ViewTabBarItem(
          index: index,
          transform: ScaleTransform(
            maxScale: 1,
            transform: ColorsTransform(
              normalColor: const Color(0xff606266),
              highlightColor: controller.activeColor,
              builder: (context, color) {
                return Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: AutoText(
                    controller.categoryTreeProductList[index].mDescription ?? "",
                    style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 16.0),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                  ),
                );
              },
            ),
          ),
        );
      },
      indicator: StandardIndicator(color: controller.activeColor, width: 3.0, height: 30.0, left: 3),
    );

    return Container(
      constraints: BoxConstraints(maxWidth: 180),
      width: context.width * 0.35,
      child: GetBuilder<HallController>(
        id: "hall_left_nav",
        builder: (_) {
          if (!controller.isDataReady) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            itemCount: controller.categoryTreeProductList.length,
            separatorBuilder: (_, _) => Divider(color: Colors.black12),
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

  /// 右侧内容
  Widget _buildRightContainer(BuildContext context) {
    return Expanded(
      child: GetBuilder<HallController>(
        id: "hall_right_nav",
        builder: (_) {
          if (!controller.isDataReady) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ViewTabBar(
                height: 36,
                itemCount: controller.children?.length ?? 0,
                direction: Axis.horizontal,
                pageController: controller.rightPageController,
                tabBarController: controller.rightTabBarController,
                animationDuration: Duration(milliseconds: 300), // 取消动画 -> Duration.zero
                builder: (context, index) {
                  return ViewTabBarItem(
                    index: index,
                    transform: ScaleTransform(
                      maxScale: 1.2,
                      transform: ColorsTransform(
                        normalColor: const Color(0xff606266),
                        highlightColor: const Color(0xff436cff),
                        builder: (context, color) {
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0, bottom: 8.0),
                            child: Text(
                              controller.children?[index].mDescription ?? '',
                              style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 14.0),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                indicator: StandardIndicator(color: const Color(0xff436cff), width: 27.0, height: 2.0, bottom: 0),
              ),
              Expanded(
                flex: 1,
                child: PageView.builder(
                  itemCount: controller.children?.length ?? 0,
                  controller: controller.rightPageController,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                      child: Text(
                        '这里渲染显示 ${controller.children?[index].mDescription ?? ''} 的内容',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff606266)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );

          return ScrollableListTabScroller.defaultComponents(
            itemCount: controller.children?.length ?? 0,
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

  /// 构建产品列表
  Widget _buildProductView(List<Product>? products) {
    if (products == null || products.isEmpty) {
      return const Center(
        child: Text('无子分类', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }
    /* return ResponsiveGridList(
      minItemWidth: 180,
      horizontalGridSpacing: 8,
      verticalGridSpacing: 8,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true),
      children: products.map((product) {
        return _buildProductCard(product);
      }).toList(),
    ); */
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 180),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  /// 构建产品卡片
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

  /// 构建产品图片
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

class VerticalWithPinned extends StatelessWidget {
  VerticalWithPinned({super.key});

  final pageController = PageController();
  final tabBarController = ViewTabBarController();

  @override
  Widget build(BuildContext context) {
    const tags = ['板块1', '板块2', '板块3', '板块4', '板块5', '板块6', '板块7', '板块8', '板块9', '板块10', '板块11', '板块12', '板块13'];
    const duration = Duration(milliseconds: 300);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ViewTabBar(
          width: 58,
          itemCount: tags.length,
          direction: Axis.vertical,
          pageController: pageController,
          tabBarController: tabBarController,
          animationDuration: duration, // 取消动画 -> Duration.zero
          builder: (context, index) {
            return ViewTabBarItem(
              index: index,
              transform: ScaleTransform(
                maxScale: 1.2,
                transform: ColorsTransform(
                  normalColor: const Color(0xff606266),
                  highlightColor: const Color(0xff436cff),
                  builder: (context, color) {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0, bottom: 8.0),
                      child: Text(
                        tags[index],
                        style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 14.0),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          indicator: StandardIndicator(color: const Color(0xff436cff), width: 2.0, height: 25.0, right: 0),
        ),
        const VerticalDivider(width: 5, thickness: 1, indent: 5, endIndent: 5),
        Expanded(
          flex: 1,
          child: PageView.builder(
            itemCount: tags.length,
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                child: Text(
                  '这里渲染显示 ${tags[index]} 的内容',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff606266)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class HorizontalNoPinned extends StatelessWidget {
  HorizontalNoPinned({super.key});

  final pageController = PageController();
  final tabBarController = ViewTabBarController();

  @override
  Widget build(BuildContext context) {
    const tags = ['板块1', '板块2', '板块3', '板块4', '板块5', '板块6', '板块7', '板块8'];
    const duration = Duration(milliseconds: 300);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ViewTabBar(
          height: 36,
          itemCount: tags.length,
          direction: Axis.horizontal,
          pageController: pageController,
          tabBarController: tabBarController,
          animationDuration: duration, // 取消动画 -> Duration.zero
          builder: (context, index) {
            return ViewTabBarItem(
              index: index,
              transform: ScaleTransform(
                maxScale: 1.2,
                transform: ColorsTransform(
                  normalColor: const Color(0xff606266),
                  highlightColor: const Color(0xff436cff),
                  builder: (context, color) {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0, bottom: 8.0),
                      child: Text(
                        tags[index],
                        style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 14.0),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          indicator: StandardIndicator(color: const Color(0xff436cff), width: 27.0, height: 2.0, bottom: 0),
        ),
        Expanded(
          flex: 1,
          child: PageView.builder(
            itemCount: tags.length,
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: Text(
                  '这里渲染显示 ${tags[index]} 的内容',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff606266)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
