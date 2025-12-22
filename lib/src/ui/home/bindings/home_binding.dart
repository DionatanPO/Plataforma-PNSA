import 'package:get/get.dart';
import '../controlles/home_controller.dart';
import '../../dizimistas/controllers/dizimista_controller.dart';
import '../../contribuicoes/controllers/contribuicao_controller.dart';
import '../../access_management/controllers/access_management_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DizimistaController>(() => DizimistaController(), fenix: true);
    Get.lazyPut<ContribuicaoController>(() => ContribuicaoController(),
        fenix: true);
    Get.lazyPut<AccessManagementController>(() => AccessManagementController(),
        fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
  }
}
