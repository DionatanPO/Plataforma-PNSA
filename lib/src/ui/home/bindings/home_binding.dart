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
    // DizimistaController deve ser criado imediatamente pois DizimistaView usa Get.find() no initState
    Get.put<DizimistaController>(DizimistaController(), permanent: true);
    Get.lazyPut<ContribuicaoController>(() => ContribuicaoController(),
        fenix: true);
    // AccessManagementController deve ser criado imediatamente
    Get.put<AccessManagementController>(AccessManagementController(),
        permanent: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
  }
}
