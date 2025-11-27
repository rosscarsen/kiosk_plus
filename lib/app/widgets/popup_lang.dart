import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../config.dart';
import '../translations/locale_keys.dart';

class PopupLang extends StatefulWidget {
  const PopupLang({super.key});

  @override
  State<PopupLang> createState() => _PopupLangState();
}

class _PopupLangState extends State<PopupLang> {
  final box = IsolatedHive.box(Config.kioskHiveBox);

  @override
  Widget build(BuildContext context) {
    final String? currentLang = Get.locale?.toString();
    final activeColor = Theme.of(context).primaryColor;
    return MenuAnchor(
      alignmentOffset: const Offset(-50, 0),
      menuChildren: [
        MenuItemButton(
          child: Row(
            spacing: 8,
            children: [
              Text("中文简体", style: TextStyle(color: currentLang == "zh_CN" ? activeColor : null)),
              if (currentLang == "zh_CN") Icon(Icons.check, size: 18, color: activeColor),
            ],
          ),
          onPressed: () async {
            Get.updateLocale(const Locale("zh", "CN"));
            await box.put(Config.localLanguage, "zh_CN");
          },
        ),
        const Divider(),
        MenuItemButton(
          child: Row(
            spacing: 8,
            children: [
              Text("中文繁體", style: TextStyle(color: currentLang == "zh_HK" ? activeColor : null)),
              if (currentLang == "zh_HK") Icon(Icons.check, size: 18, color: activeColor),
            ],
          ),
          onPressed: () async {
            Get.updateLocale(const Locale("zh", "HK"));
            await box.put(Config.localLanguage, "zh_HK");
          },
        ),
        const Divider(),
        MenuItemButton(
          child: Row(
            spacing: 8,
            children: [
              Text("English", style: TextStyle(color: currentLang == "en_US" ? activeColor : null)),
              if (currentLang == "en_US") Icon(Icons.check, size: 18, color: activeColor),
            ],
          ),
          onPressed: () async {
            Get.updateLocale(const Locale("en", "US"));
            await box.put(Config.localLanguage, "en_US");
          },
        ),
      ],
      /* CheckedPopupMenuItem */
      builder: (context, controller, child) {
        return IconButton(
          icon: const Icon(FontAwesomeIcons.language),
          tooltip: LocaleKeys.language.tr,
          onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        );
      },
    );
  }
}
