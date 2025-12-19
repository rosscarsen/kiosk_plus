import 'package:get/get.dart';

import 'cart_controller.dart';

class CartBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut<CartController>(() => CartController())];
}
