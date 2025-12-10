import 'package:get/get.dart';

import 'product_detail_controller.dart';

class ProductDetailBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [Bind.lazyPut<ProductDetailController>(() => ProductDetailController())];
  }
}
