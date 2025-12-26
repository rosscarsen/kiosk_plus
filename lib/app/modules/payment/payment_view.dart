import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import '../../translations/locale_keys.dart';
import 'payment_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Obx(() {
          if (!controller.isDataReady.value) {
            return CircularProgressIndicator();
          }
          if (controller.hasDiscoveryPrinter.value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Opacity(
                  opacity: 0,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    focusNode: controller.focusNode,
                    autofocus: true,
                    onChanged: (value) {
                      controller.cardNo.value = value;
                    },
                  ),
                ),
                Text(
                  LocaleKeys.payReadCard.tr,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 5),
                  textAlign: TextAlign.center,
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0XFFeb0022),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    LocaleKeys.back.tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: .5, color: Colors.white),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.contactCounter.tr,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                    color: Color(0XFFeb0022),
                  ),
                ),
                SizedBox(height: 30),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0XFFeb0022),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    LocaleKeys.back.tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: .5, color: Colors.white),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
