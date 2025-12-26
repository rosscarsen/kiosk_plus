import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:get/get.dart';
import 'package:kiosk_plus/app/routes/app_pages.dart';
import 'package:kiosk_plus/app/utils/constants.dart';
import 'package:kiosk_plus/app/utils/custom_dialog.dart';

import '../../translations/locale_keys.dart';
import 'payment_type_controller.dart';

class PaymentTypeView extends GetView<PaymentTypeController> {
  const PaymentTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.paymentType.tr), centerTitle: true),
      body: Theme(
        data: Theme.of(context).copyWith(
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.kPrimary;
              }
              return Colors.grey.shade400;
            }),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FormBuilder(
                  child: FormBuilderRadioGroup<String>(
                    name: "paymentType",
                    orientation: OptionsOrientation.vertical,
                    decoration: const InputDecoration(border: InputBorder.none),
                    itemDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                      boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 6))],
                    ),

                    activeColor: AppColors.kPrimary,
                    wrapSpacing: 12,
                    wrapRunSpacing: 12,
                    initialValue: controller.paymentType,
                    valueTransformer: (String? value) => (value ?? '').trim(),
                    onChanged: (value) {
                      controller.paymentType = value ?? '';
                    },
                    options: [
                      _option('VISA/MASTER', 'assets/visaMaster.png'),
                      _option('SAMSUNG', 'assets/samSungPay.png'),
                      _option('OCTOPUS', 'assets/octopus.png'),
                      _option('GOOGLEPAY', 'assets/googlePay.png'),
                      _option('APPLEPAY', 'assets/applePay.png'),
                      _option('WECHATPAY', 'assets/wechatPay.png'),
                      _option('ALIPAYHK', 'assets/alipayHK.png'),
                      FormBuilderFieldOption(
                        value: 'POINTS',
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          height: 64,
                          child: Text(
                            LocaleKeys.pointsConsumption.tr,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  /// 支付方式选项
  FormBuilderFieldOption<String> _option(String value, String image) {
    return FormBuilderFieldOption(
      value: value,
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: Image.asset(image, fit: BoxFit.contain, alignment: Alignment.center),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Column(
      children: [
        Divider(height: 1, color: Colors.grey.shade300),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0XFFeb0022),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  Get.back();
                },
                child: Text(LocaleKeys.back.tr),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0XFF1aab18),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  if (controller.paymentType.isNotEmpty) {
                    Get.toNamed(Routes.PAYMENT, parameters: {'paymentMethod': controller.paymentType});
                  } else {
                    CustomDialog.warning(LocaleKeys.pleaseSelectPaymentType.tr);
                  }
                },
                child: Text(LocaleKeys.confirm.tr),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
