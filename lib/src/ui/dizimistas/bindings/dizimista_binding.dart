import 'package:get/get.dart';
import '../controllers/dizimista_controller.dart';

class DizimistaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DizimistaController>(() => DizimistaController());
  }
}