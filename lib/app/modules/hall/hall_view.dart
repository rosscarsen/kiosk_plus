import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiosk_plus/app/routes/app_pages.dart';
import 'package:kiosk_plus/app/widgets/auto_text.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:view_tabbar/view_tabbar.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../translations/locale_keys.dart';
import '../../utils/constants.dart';
import '../../utils/logger.dart';
import 'hall_controller.dart';

class HallView extends GetView<HallController> {
  const HallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: GetBuilder<HallController>(
          id: "hall_app_bar",
          builder: (_) => Text(
            controller.companyName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextMain,
              letterSpacing: 0.3,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: AppColors.kBg, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Badge.count(count: 5, child: const Icon(Icons.shopping_cart, size: 18, color: AppColors.kPrimary)),
                const SizedBox(width: 6),
                const Text(
                  '\$100.00',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.kPrimary),
                ),
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

        return ColoredBox(
          color: const Color(0xFFF5F6FA),
          child: Row(
            children: [_buildLeftNav(context), const VerticalDivider(width: 1), _buildRightContainer(context)],
          ),
        );
      },
    );
  }

  /// 左侧导航
  Widget _buildLeftNav(BuildContext context) {
    return ViewTabBar(
      width: 140,
      itemCount: controller.leftTabBarCount,
      direction: Axis.vertical,
      pageController: controller.leftPageController,
      tabBarController: controller.leftTabBarController,
      animationDuration: const Duration(milliseconds: 250),

      builder: (context, index) {
        return ViewTabBarItem(
          index: index,
          transform: ColorsTransform(
            normalColor: AppColors.kTextSub,
            highlightColor: AppColors.kPrimary,
            builder: (context, color) {
              final bool selected = color == AppColors.kPrimary;

              return AnimatedContainer(
                width: double.infinity,
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.kPrimary.withAlpha(20) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  controller.categoryTreeProductList[index].mDescription ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        );
      },

      indicator: StandardIndicator(color: AppColors.kPrimary, width: 3, height: 26, left: 2),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              LocaleKeys.noData.tr,
              style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ViewTabBar(
          height: 40,
          itemCount: childrenData.length,
          direction: Axis.horizontal,
          pageController: pageController,
          tabBarController: tabBarController,
          animationDuration: const Duration(milliseconds: 250),

          builder: (context, index) {
            return ViewTabBarItem(
              index: index,
              transform: ColorsTransform(
                normalColor: AppColors.kTextSub,
                highlightColor: AppColors.kPrimary,
                builder: (context, color) {
                  final bool selected = color == AppColors.kPrimary;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    child: Text(
                      childrenData[index].mDescription ?? "",
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            );
          },

          indicator: StandardIndicator(color: AppColors.kPrimary, width: 20, height: 3, bottom: 4),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                LocaleKeys.noData.tr,
                style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
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
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: const Color(0x1A000000), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 0),
            BoxShadow(color: const Color(0x0F000000), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 0),
          ],
          border: Border.all(width: 1, color: const Color(0xFFF0F2F5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 图片区域
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                      child: _buildProductImageView(product.imagesPath ?? ''),
                    ),
                  ),
                ),
                // 角标位置
                /* Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.kPrimary, borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      '热销',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ), */
              ],
            ),

            // 内容区域
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 产品名称
                  AutoText(
                    product.mDesc1 ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.kTextMain,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.mPrice}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kPrice,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  //添加按钮（如果需要快速添加到购物车）
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 32,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       // 添加到购物车逻辑
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: AppColors.kPrimary,
                  //       foregroundColor: Colors.white,
                  //       padding: EdgeInsets.zero,
                  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  //       elevation: 0,
                  //     ),
                  //     child: const Text('添加', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  //   ),
                  // ),
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
