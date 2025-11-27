import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../../config.dart';
import '../../model/api_data_model/data_result_model.dart';
import '../../service/data_sync_service.dart';
import '../../service/dio_api_client.dart';

class HallController extends GetxController {
  final box = IsolatedHive.box(Config.kioskHiveBox);
  final ApiClient apiClient = ApiClient();
  RxBool isLoading = false.obs;
  List<CategoryTreeProduct> categoryTreeProductList = [];
  RxString companyName = "".obs;

  @override
  void onInit() {
    super.onInit();
    getLocaleData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    categoryTreeProductList.clear();
    super.onClose();
  }

  Future<void> getLocaleData() async {
    isLoading.value = true;
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
    isLoading.value = false;
  }
}
