import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'hall_controller.dart';

class HallView extends GetView<HallController> {
  const HallView({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("大厅"),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [Icon(Icons.shopping_cart), Text('\$10.0')],
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
              /*  await controller.box.delete(Config.categoryTreeProduct);
              logger.i("==>删除本地数据: ${await controller.box.get(Config.categoryTreeProduct)}"); */
              controller.getLocaleData();
            },
          ),
        ],
      ),
    );
  }
}
