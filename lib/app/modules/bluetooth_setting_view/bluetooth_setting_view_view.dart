import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../translations/locale_keys.dart';
import 'bluetooth_setting_view_controller.dart';

class BluetoothSettingViewView extends GetView<BluetoothSettingViewController> {
  const BluetoothSettingViewView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(LocaleKeys.bluetoothSetting.tr, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    controller.scanDevices();
                  },
                  child: Text(LocaleKeys.searchDevice.tr, style: const TextStyle(color: Colors.white)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    try {
                      await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
                    } catch (e) {
                      Get.snackbar(LocaleKeys.openSettingsFailed.tr, e.toString(), snackPosition: SnackPosition.bottom);
                    }
                  },
                  child: Text(LocaleKeys.openSettings.tr, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: GetBuilder<BluetoothSettingViewController>(
          init: BluetoothSettingViewController(),
          id: "searchDevices",
          initState: (_) {},
          builder: (_) {
            if (controller.devices.isEmpty) {
              return Center(child: Text("No device found".tr));
            } //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
            return ListView.separated(
              itemCount: controller.devices.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                final device = controller.devices[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Text("${device.deviceName}"),
                  subtitle: Text("${device.address}"),
                  leading: const Icon(Icons.bluetooth, color: Color.fromARGB(255, 100, 151, 193)),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await controller.innerPrinter(device);
                    },
                    child: Text(LocaleKeys.testPrint.tr),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
