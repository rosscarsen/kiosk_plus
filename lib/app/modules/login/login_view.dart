import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../translations/locale_keys.dart';
import '../../widgets/popup_lang.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5FF), Color(0xFFF0F8FF)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 顶部装饰
              Positioned(
                top: 40,
                left: Get.width / 2 - 50,
                child: Container(
                  width: 100,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.transparent, Colors.blue.shade300, Colors.transparent]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: controller.animationController, curve: Curves.easeOutQuint)),
                        child: Container(
                          alignment: Alignment.center,
                          height: 100,
                          margin: EdgeInsets.only(top: 20),
                          child: FittedBox(
                            child: GradientAnimationText(
                              text: Text(
                                'KIOSK',
                                style: TextStyle(fontSize: 45, fontWeight: FontWeight.w800, letterSpacing: 10),
                              ),
                              colors: [Color(0xFF4A90E2), Color(0xFF50E3C2), Color(0xFF4A90E2)],
                              duration: Duration(seconds: 3),
                            ),
                          ),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          double designWidth = constraints.maxWidth > 480 ? 360 : constraints.maxWidth * 0.85;
                          return Container(
                            width: designWidth,
                            margin: EdgeInsets.only(bottom: 20, top: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x154A90E2),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(24),
                            child: buildForm(context),
                          ).marginSymmetric(horizontal: designWidth > 380 ? Get.width * 0.08 : 20);
                        },
                      ),
                      // 版权信息
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 8),
                        child: Text(
                          '© ${DateTime.now().year} Pericles',
                          style: TextStyle(color: Color(0xFF9BA5B7), fontSize: 12, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(right: 16, top: 16, child: PopupLang()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    bool visibility = false;
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          filled: true,
          fillColor: Color(0xFFF7F9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFD1DCE8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFD1DCE8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF4A90E2), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          hintStyle: TextStyle(color: Color(0xFF9BA5B7), fontSize: 14),
          errorStyle: TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      ),
      child: FormBuilder(
        key: controller.formKey,
        child: Column(
          spacing: 4.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                LocaleKeys.login.tr,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
              ),
            ),
            //公司
            FormBuilderTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.apartment, color: Color(0xFF4A90E2)),
                hintText: LocaleKeys.companyID.tr,
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.formKey.currentState!.fields['company']?.reset();
                  },
                  icon: Icon(Icons.cancel),
                ),
              ),
              name: "company",
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: LocaleKeys.companyEmpty.tr),
              ]),
            ),
            //用户
            FormBuilderTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Color(0xFF4A90E2)),
                hintText: LocaleKeys.user.tr,
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.formKey.currentState!.fields['user']?.reset();
                  },
                  icon: Icon(Icons.cancel),
                ),
              ),
              name: "user",
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: LocaleKeys.userEmpty.tr),
              ]),
            ),

            //密码
            StatefulBuilder(
              builder: (BuildContext context, setState) {
                return FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.verified_user, color: Color(0xFF4A90E2)),
                    hintText: LocaleKeys.password.tr,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          visibility = !visibility;
                        });
                      },
                      icon: Icon(!visibility ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  name: "password",
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: LocaleKeys.passwordEmpty.tr),
                  ]),
                  obscureText: !visibility,
                );
              },
            ),

            //记住按钮 - 移除边框
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: FormBuilderCheckbox(
                activeColor: Color(0xFF4A90E2),
                initialValue: true,
                name: "remember",
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.transparent,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                ),
                title: Text(LocaleKeys.rememberMe.tr, style: TextStyle(fontSize: 14, color: Color(0xFF4A5568))),
              ),
            ),
            //登录按钮
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  width: Get.width,
                  color: Color(0xFF4A90E2),
                  successColor: Color(0xFF50E3C2),
                  controller: controller.signInController,
                  onPressed: () async {
                    await controller.signIn();
                  },
                  valueColor: Colors.white,
                  borderRadius: 12,
                  elevation: 0,
                  height: 50,
                  child: Text(
                    LocaleKeys.login.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
