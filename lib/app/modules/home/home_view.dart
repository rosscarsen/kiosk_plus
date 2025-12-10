import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../../config.dart';
import '../../model/login/login_data_model.dart';
import '../../routes/app_pages.dart';
import '../../translations/locale_keys.dart';
import '../../utils/custom_alert.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = context.height;
    double width = context.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/kiosk_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.multiply),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.1, horizontal: width * 0.08),
                child: Align(alignment: Alignment.topCenter, child: _buildMainView(context)),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    final triggered = controller.handleSecretTap();
                    if (triggered && !(Get.isDialogOpen ?? false)) {
                      await openAppSet();
                    }
                  },
                  child: SizedBox(
                    width: width * 0.3,
                    height: height * 0.3,
                    // child: Container(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openAppSet() async {
    final TextEditingController pwdController = TextEditingController();
    final box = IsolatedHive.box(Config.kioskHiveBox);
    final loginInfo = await box.get(Config.loginData) as LoginDataModel?;
    final String loginPwd = loginInfo?.pwd ?? "";
    Get.defaultDialog(
      barrierDismissible: false,
      title: LocaleKeys.unlockSetting.tr,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          autofocus: true,
          controller: pwdController,
          decoration: InputDecoration(
            hintText: LocaleKeys.pleaseInputLoginPassword.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
      ),
      textCancel: LocaleKeys.close.tr,
      textConfirm: LocaleKeys.unlock.tr,
      onConfirm: () async {
        Get.closeDialog();
        final String inputPwd = pwdController.text;
        if (inputPwd == loginPwd) {
          await Get.defaultDialog(
            title: LocaleKeys.setting.tr,
            content: Column(
              spacing: 8.0,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Divider(),
                FilledButton(
                  onPressed: () {
                    Get.closeDialog();
                    Get.toNamed(Routes.BLUETOOTH_SETTING_VIEW);
                  },
                  child: Text(LocaleKeys.bluetoothSetting.tr),
                ),
                FilledButton(
                  onPressed: () async {
                    Get.closeDialog();
                    final box = IsolatedHive.box(Config.kioskHiveBox);
                    final loginData = await box.get(Config.loginData) as LoginDataModel?;
                    loginData?.dsn = null;
                    await box.put(Config.loginData, loginData);
                    await box.deleteAll([
                      Config.calendarDiscount,
                      Config.companyInfo,
                      Config.categoryTreeProduct,
                      Config.productRemarks,
                      Config.productSetMeal,
                      Config.productSetMealLimit,
                    ]);
                    Get.offAllNamed(Routes.LOGIN);
                  },
                  child: Text(LocaleKeys.loginOut.tr),
                ),
                Divider(),
              ],
            ),
            textConfirm: LocaleKeys.close.tr,
            onConfirm: () => Get.closeDialog(),
          );
        } else {
          CustomAlert.iosAlert(title: LocaleKeys.systemMessage.tr, message: LocaleKeys.passwordError.tr);
        }
      },
    );
  }

  Widget _buildMainView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        //欢迎语
        Text(
          LocaleKeys.welcomeToTheSelfServiceOrderingSystem.tr,
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: const [Shadow(offset: Offset(1.5, 1.5), blurRadius: 3, color: Colors.black45)],
          ),
          textAlign: TextAlign.center,
        ),

        Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            spacing: 12.0,
            children: <Widget>[
              // 点餐按钮
              _glassButton(
                context,
                onTap: () => Get.toNamed(Routes.HALL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8.0,
                  children: [
                    AnimatedBuilder(
                      animation: controller.animCtrl,
                      builder: (_, _) {
                        final t = controller.animCtrl.value;
                        final t2 = (t + 0.5) % 1.0;

                        Widget ring(double tt, double baseSize, double stroke) {
                          final opacity = (1.0 - tt).clamp(0.0, 1.0);
                          final scale = 0.6 + tt * 1.6;
                          return Opacity(
                            opacity: opacity * 0.9,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: baseSize,
                                height: baseSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.28 * opacity),
                                    width: stroke,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ring(t2, 60, 2.0),
                              ring(t, 60, 2.6),
                              ScaleTransition(
                                scale: controller.scaleAnimation,
                                child: const Icon(Icons.touch_app, color: Colors.white, size: 32),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Column(
                      children: [
                        Text(
                          '點擊開始點餐',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text('Click to Order', style: TextStyle(fontSize: 25, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
              ),
              // 语言切换按钮
              _glassButton(
                context,
                onTap: () {
                  final box = IsolatedHive.box(Config.kioskHiveBox);
                  Get.dialog(
                    AlertDialog(
                      title: Text(LocaleKeys.language.tr),
                      content: Theme(
                        data: ThemeData(
                          listTileTheme: ListTileThemeData(contentPadding: EdgeInsets.zero, horizontalTitleGap: 0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text("中文简体"),
                              trailing: Get.locale?.toString() == "zh_CN"
                                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                                  : null,
                              onTap: () async {
                                await box.put(Config.localLanguage, "zh_CN");
                                await Get.updateLocale(const Locale("zh", "CN"));
                                Get.closeDialog();
                              },
                            ),
                            Divider(),
                            ListTile(
                              title: Text("中文繁體"),
                              trailing: Get.locale?.toString() == "zh_HK"
                                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                                  : null,
                              onTap: () async {
                                await box.put(Config.localLanguage, "zh_HK");
                                await Get.updateLocale(const Locale("zh", "HK"));
                                Get.closeDialog();
                              },
                            ),
                            Divider(),
                            ListTile(
                              title: Text("English"),
                              trailing: Get.locale?.toString() == "en_US"
                                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                                  : null,
                              onTap: () async {
                                await box.put(Config.localLanguage, "en_US");
                                await Get.updateLocale(const Locale("en", "US"));
                                Get.closeDialog();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  spacing: 8.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FontAwesomeIcons.language, color: Colors.white),
                    Text(
                      LocaleKeys.language.tr,
                      style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 统一的玻璃态按钮组件
  Widget _glassButton(
    BuildContext context, {
    required Widget child,
    required VoidCallback onTap,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withValues(alpha: 0.06), Colors.white.withValues(alpha: 0.02)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.2),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.38), blurRadius: 20, offset: const Offset(0, 10)),
                BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
              ],
            ),
            child: DefaultTextStyle.merge(
              style: const TextStyle(),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
