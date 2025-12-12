import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../config.dart';
import '../model/api_data_model/data_result_model.dart';
import '../model/login/login_data_model.dart';
import '../utils/logger.dart';
import 'dio_api_client.dart';
import 'dio_api_result.dart';

class DataSyncService extends GetxService {
  static DataSyncService get to => Get.find<DataSyncService>();
  final ApiClient apiClient = ApiClient();
  final box = IsolatedHive.box(Config.kioskHiveBox);
  Timer? _timer;
  bool _isFetching = false; // 防重叠标志

  @override
  void onInit() {
    super.onInit();
    _startBackgroundJob();
  }

  void _startBackgroundJob() {
    _fetchDataSafe();

    _timer = Timer.periodic(const Duration(minutes: 3), (_) {
      _fetchDataSafe();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _fetchDataSafe() {
    if (_isFetching) return;
    _isFetching = true;
    getData()
        .catchError((e) {
          logger.e('Error in background fetch: $e');
        })
        .whenComplete(() {
          _isFetching = false;
        });
  }

  Future<void> getData() async {
    if (!const bool.fromEnvironment("dart.vm.product")) {
      logger.i("==>请求数据…");
    }
    final loginInfo = await box.get(Config.loginData) as LoginDataModel?;
    if (loginInfo == null && loginInfo?.company == null && loginInfo?.dsn == null) {
      logger.i('登录信息不存在, 无法请求数据');
      return;
    }
    try {
      final DioApiResult response = await apiClient.get(Config.getDataList);
      if (response.success && response.data != null) {
        final parsed = await compute(parseJson, response.data.toString());

        await box.putAll({
          Config.calendarDiscount: double.tryParse(parsed.calendarDiscount ?? '0') ?? 0.0,
          if (parsed.companyInfo != null) Config.companyInfo: parsed.companyInfo,
          if (parsed.categoryTreeProduct?.isNotEmpty ?? false) Config.categoryTreeProduct: parsed.categoryTreeProduct,
          if (parsed.productRemarks?.isNotEmpty ?? false) Config.productRemarks: parsed.productRemarks,
        });
      } else {
        logger.w('API call returned null or failed: ${response.error}');
      }
    } catch (e) {
      logger.e('Error in getData: $e');
    }
  }
}

Future<DataResultModel> parseJson(String jsonString) async {
  return dataResultModelFromJson(jsonString);
}
