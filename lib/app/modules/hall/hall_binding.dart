import 'package:get/get.dart';

import 'hall_controller.dart';

class HallBinding extends Binding {
  @override
  List<Bind> dependencies() => [Bind.lazyPut<HallController>(() => HallController())];
}
