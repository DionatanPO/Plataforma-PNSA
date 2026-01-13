import 'package:get/get.dart';
import '../../../core/services/data_repository_service.dart';
import '../../../data/services/auth_service.dart';
import '../../contribuicoes/models/contribuicao_model.dart';

class NotificationController extends GetxController {
  final _dataRepo = Get.find<DataRepositoryService>();

  final notifications = <Contribuicao>[].obs;

  // Permissão: Agentes de dízimo podem ver, mas não interagir
  bool get canInteract {
    final auth = Get.find<AuthService>();
    final role = auth.currentUserData?.funcao ?? '';
    return role == 'Administrador' || role == 'Financeiro';
  }

  @override
  void onInit() {
    super.onInit();
    // Reage a mudanças nas contribuições para atualizar as notificações
    ever(_dataRepo.contribuicoes, (_) => _updateNotifications());
    _updateNotifications();
  }

  void _updateNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filtra contribuições "A Receber" que estão a 3 dias ou menos da data de pagamento
    // ou que já estão atrasadas.
    final filtered = _dataRepo.contribuicoes.where((c) {
      if (c.status != 'A Receber') return false;

      final paymentDate = DateTime(
        c.dataPagamento.year,
        c.dataPagamento.month,
        c.dataPagamento.day,
      );

      // Diferença em dias
      final difference = paymentDate.difference(today).inDays;

      // Notifica se faltar 3 dias ou menos, ou se já passou da data
      return difference <= 3;
    }).toList();

    // Ordena por data de pagamento (mais próximas primeiro)
    filtered.sort((a, b) => a.dataPagamento.compareTo(b.dataPagamento));

    notifications.assignAll(filtered);
  }

  int get notificationCount => notifications.length;

  Future<void> refreshNotifications() async {
    _dataRepo.refreshData();
  }
}
