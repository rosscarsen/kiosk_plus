import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app/config.dart';
import 'app/model/login/login_data_model.dart';
import 'app/routes/app_pages.dart';
import 'app/service/data_sync_service.dart';
import 'app/translations/app_translations.dart';
import 'hive_registrar.g.dart';

void main() async {
  /// 设置UI
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  /// 初始hive
  await IsolatedHive.initFlutter();
  IsolatedHive.registerAdapters();
  await IsolatedHive.openBox(Config.kioskHiveBox);

  /// 检测本地登录信息
  final (hasLogin, localLangString) = await checkInLocalInfo();

  Locale initialLocale = localLangString == "zh_CN"
      ? const Locale("zh", "CN")
      : localLangString == "zh_HK"
      ? const Locale("zh", "HK")
      : const Locale("en", "US");

  final String initialRoute = hasLogin ? Routes.HOME : Routes.LOGIN;
  Get.put<DataSyncService>(DataSyncService()); // 初始化数据同步服务
  runApp(MyApp(initialRoute: initialRoute, initialLocale: initialLocale));
}

/// 检测本地登录信息
Future<(bool, String)> checkInLocalInfo() async {
  // 判断是否登录
  final box = IsolatedHive.box(Config.kioskHiveBox);
  final loginData = await box.get(Config.loginData) as LoginDataModel?;
  final hasLogin = loginData?.dsn != null;

  // 默认语言

  final localLangString = await box.get(Config.localLanguage) as String? ?? "zh_HK";

  return (hasLogin, localLangString);
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final Locale initialLocale;
  const MyApp({super.key, required this.initialRoute, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Kiosk",
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: initialLocale,
      supportedLocales: const [Locale('zh', 'CN'), Locale('zh', 'HK'), Locale('en', 'US')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      defaultTransition: Transition.noTransition,
      builder: (context, child) {
        child = MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0), alwaysUse24HourFormat: true),
          child: child!,
        );
        child = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );

        /// 提示框
        child = FlutterSmartDialog.init()(context, child);
        return child;
      },
    );
  }
}
