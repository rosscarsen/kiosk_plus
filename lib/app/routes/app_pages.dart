import 'package:get/get.dart';

import '../modules/bluetooth_setting_view/bluetooth_setting_view_binding.dart';
import '../modules/bluetooth_setting_view/bluetooth_setting_view_view.dart';
import '../modules/cart/cart_binding.dart';
import '../modules/cart/cart_view.dart';
import '../modules/hall/hall_binding.dart';
import '../modules/hall/hall_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/payment/payment_binding.dart';
import '../modules/payment/payment_view.dart';
import '../modules/payment_type/payment_type_binding.dart';
import '../modules/payment_type/payment_type_view.dart';
import '../modules/privacy/privacy_binding.dart';
import '../modules/privacy/privacy_view.dart';
import '../modules/product_detail/product_detail_binding.dart';
import '../modules/product_detail/product_detail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
        name: _Paths.HOME,
        page: () => const HomeView(),
        binding: HomeBinding()),
    GetPage(
        name: _Paths.LOGIN,
        page: () => const LoginView(),
        binding: LoginBinding()),
    GetPage(
      name: _Paths.BLUETOOTH_SETTING_VIEW,
      page: () => const BluetoothSettingViewView(),
      binding: BluetoothSettingViewBinding(),
    ),
    GetPage(
      name: _Paths.HALL,
      page: () => const HallView(),
      binding: HallBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAIL,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACY,
      page: () => const PrivacyView(),
      binding: PrivacyBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT,
      page: () => const PaymentView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_TYPE,
      page: () => const PaymentTypeView(),
      binding: PaymentTypeBinding(),
    ),
  ];
}
