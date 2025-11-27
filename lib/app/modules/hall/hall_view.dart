import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../routes/app_pages.dart';
import 'hall_controller.dart';

class HallView extends GetView<HallController> {
  const HallView({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(controller.companyName.value)),
          //automaticallyImplyLeading: false,
          centerTitle: true,
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
        body: _buildMainView(),
      ),
    );
  }

  // 主界面
  Widget _buildMainView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8.0,
        children: [
          Obx(() => Text(controller.isLoading.value ? "Loading..." : "Loaded")),
          ElevatedButton(
            child: const Text('获取本地数据'),
            onPressed: () async {
              //Get.toNamed(Routes.LOGIN);
              /*  await controller.box.delete(Config.categoryTreeProduct);
              logger.i("==>删除本地数据: ${await controller.box.get(Config.categoryTreeProduct)}"); */
              /* controller.getLocaleData(); */
              //Get.toNamed(Routes.LOGIN);
              print((await controller.box.get(Config.companyInfo) as CompanyInfo?)?.toJson());
            },
          ),
        ],
      ),
    );
  }
}
