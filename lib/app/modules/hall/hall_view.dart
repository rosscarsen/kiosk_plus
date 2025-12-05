import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiosk_plus/app/widgets/auto_text.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:view_tabbar/view_tabbar.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../translations/locale_keys.dart';
import '../../utils/logger.dart';
import 'hall_controller.dart';

class HallView extends GetView<HallController> {
  const HallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: GetBuilder<HallController>(
          id: "hall_app_bar",
          builder: (_) => Text(
            controller.companyName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
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
      ),
      body: _buildMain(context),
    );
  }

  Widget _buildMain(BuildContext context) {
    return GetBuilder<HallController>(
      id: "hall_body",
      builder: (_) {
        if (!controller.isDataReady) {
          return Skeletonizer(
            enabled: true,
            effect: const ShimmerEffect(
              baseColor: Color(0xFFE0E0E0),
              highlightColor: Color(0xFFF5F5F5),
              duration: Duration(milliseconds: 1200),
            ),
            child: Card(
              child: Container(color: const Color(0xFFF0F0F0), width: context.width, height: context.height),
            ),
          );
        }

        return Row(children: [_buildLeftNav(context), const VerticalDivider(width: 1), _buildRightContainer(context)]);
      },
    );
  }

  /// 左侧导航
  Widget _buildLeftNav(BuildContext context) {
    return ViewTabBar(
      width: 150,
      itemCount: controller.leftTabBarCount,
      direction: Axis.vertical,
      pageController: controller.leftPageController,
      tabBarController: controller.leftTabBarController,
      animationDuration: const Duration(milliseconds: 300),
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
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Text(
                        controller.categoryTreeProductList[index].mDescription ?? "",
                        style: TextStyle(color: color, fontSize: 14),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      indicator: StandardIndicator(color: controller.activeColor, width: 3, height: 30, left: 2),
    );
  }

  ///  右侧内容
  Widget _buildRightContainer(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        itemCount: controller.leftTabBarCount,
        controller: controller.leftPageController,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final List<CategoryTreeProduct> secondCateAndProductsData =
              controller.categoryTreeProductList[index].children ?? [];
          return CategoryAndProducts(childrenData: secondCateAndProductsData);
        },
      ),
    );
  }
}

class CategoryAndProducts extends StatelessWidget {
  CategoryAndProducts({super.key, required this.childrenData});

  /// 第二级分类 & 商品数据
  final pageController = PageController();
  final tabBarController = ViewTabBarController();
  final List<CategoryTreeProduct> childrenData;
  final ctl = Get.find<HallController>();

  /// 到达下一页 → 切换到下一【大类】
  void _onReachNextPage(BuildContext context) {
    if (!pageController.hasClients) return;

    final int current = pageController.page!.round();
    if (current < childrenData.length - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      // 第二级已经到底 → 切换第一级
      ctl.jumpToNextCategory();
    }
  }

  /// 到达上一页 → 切换到上一【大类】
  void _onReachPrevPage(BuildContext context) {
    if (!pageController.hasClients) return;

    final int current = pageController.page!.round();

    if (current > 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      // 第二级已经到顶 → 切换到上一【大类】
      ctl.jumpToPrevCategory();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (childrenData.isEmpty) {
      return Center(child: Text(LocaleKeys.noData.tr));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ViewTabBar(
          height: 36,
          itemCount: childrenData.length,
          direction: Axis.horizontal,
          pageController: pageController,
          tabBarController: tabBarController,
          animationDuration: const Duration(milliseconds: 300),
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
                        childrenData[index].mDescription ?? "",
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
            itemCount: childrenData.length,
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final products = childrenData[index].products ?? [];
              return Container(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: _buildProductList(context, products, index),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 商品网格
  Widget _buildProductList(BuildContext context, List<Product> products, index) {
    if (products.isEmpty) {
      bool lock = false;

      void unlockLater() {
        Future.delayed(const Duration(milliseconds: 400), () {
          lock = false;
        });
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque, //  空白区域也能接收手势
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (lock) return;

          // ✅ 向上甩 → 下一页 / 下一大类
          if (velocity < -300) {
            lock = true;
            logger.f("空数据页：手势向上 → 下一页");
            _onReachNextPage(context);
            unlockLater();
          }

          // ✅ 向下甩 → 上一页 / 上一大类
          if (velocity > 300) {
            lock = true;
            logger.f("空数据页：手势向下 → 上一页");
            _onReachPrevPage(context);
            unlockLater();
          }
        },
        child: Center(
          child: Text(LocaleKeys.noData.tr, style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double designWidth = width > 600 ? 200 : 150;
        bool lock = false;
        void unlockLater() {
          Future.delayed(const Duration(milliseconds: 400), () {
            lock = false;
          });
        }

        return GestureDetector(
          // 未超屏时：靠手势触发切换
          onVerticalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (lock) return;
            // 手指向上快速甩 → 下一页
            if (velocity < -300) {
              lock = true;
              logger.f(" 未超屏：手势向上 → 下一页");
              _onReachNextPage(context);
              unlockLater();
            }

            // 手指向下快速甩 → 上一页
            if (velocity > 300) {
              lock = true;
              logger.f("未超屏：手势向下 → 上一页");
              _onReachPrevPage(context);
              unlockLater();
            }
          },

          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // 只处理“真实发生滚动”的情况（超屏）
              if (notification is ScrollUpdateNotification) {
                final metrics = notification.metrics;
                final double delta = notification.scrollDelta ?? 0;

                final bool isAtBottom = metrics.pixels >= metrics.maxScrollExtent - 2;
                final bool isAtTop = metrics.pixels <= metrics.minScrollExtent + 2;

                if (lock) return false;

                /// 已到底部 + 继续上滑 → 下一页
                if (isAtBottom && delta > 12) {
                  lock = true;
                  logger.f("超屏：滚动到底 → 下一页");
                  _onReachNextPage(context);
                  unlockLater();
                }

                /// 已到顶部 + 继续下滑 → 上一页
                if (isAtTop && delta < -12) {
                  lock = true;
                  logger.f("超屏：滚动到顶 → 上一页");
                  _onReachPrevPage(context);
                  unlockLater();
                }
              }
              return false;
            },

            child: ResponsiveGridList(
              listViewBuilderOptions: ListViewBuilderOptions(physics: const BouncingScrollPhysics()),
              minItemWidth: designWidth,
              horizontalGridSpacing: 8,
              verticalGridSpacing: 8,
              children: products.map((product) {
                return _buildProductCard(product);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// 商品卡片
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

  /// ✅ 商品图片
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
