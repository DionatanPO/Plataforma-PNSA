import 'package:get/get.dart';
import '../controllers/access_management_controller.dart';

class AccessManagementBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccessManagementController>(() => AccessManagementController());
  }
}