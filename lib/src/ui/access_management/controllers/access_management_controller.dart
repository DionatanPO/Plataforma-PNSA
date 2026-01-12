import 'dart:async';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../domain/models/acesso_model.dart';
import '../../../domain/models/funcao_model.dart';
import '../../../core/services/access_service.dart';
import '../../../core/services/data_repository_service.dart';

class AccessManagementController extends GetxController {
  final _dataRepo = Get.find<DataRepositoryService>();
  final _searchQuery = ''.obs;

  List<Acesso> get acessos => _dataRepo.acessos;
  bool get isLoading => _dataRepo.isSyncing.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    // Passivo, observando o repositório central
  }

  List<Funcao> getFuncoes() {
    return FuncoesRepository.getFuncoes();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  List<Acesso> get filteredAcessos {
    final authService = Get.find<AuthService>();
    final currentUserId = authService.currentUser?.uid;

    List<Acesso> baseList = acessos.toList();

    // Filtrar o usuário logado da lista base
    if (currentUserId != null) {
      baseList =
          baseList.where((acesso) => acesso.id != currentUserId).toList();
    }

    if (_searchQuery.isEmpty) {
      return baseList;
    } else {
      final query = _searchQuery.value.toLowerCase();
      return baseList
          .where(
            (acesso) =>
                acesso.nome.toLowerCase().contains(query) ||
                acesso.email.toLowerCase().contains(query) ||
                acesso.funcao.toLowerCase().contains(query),
          )
          .toList();
    }
  }

  Future<void> addAcesso(Acesso acesso) async {
    _dataRepo.isSyncing.value = true;
    try {
      // 1. Verificar duplicidade de CPF antes de cadastrar
      final cpfLimpo = acesso.cpf.replaceAll(RegExp(r'[^0-9]'), '');
      final existingCpf = await AccessService.getAcessoByCpf(cpfLimpo);

      if (existingCpf != null) {
        throw Exception(
            'Este CPF já está cadastrado para outro usuário (${existingCpf.nome}).');
      }

      // 2. Verificar duplicidade de E-mail antes de cadastrar
      final existingEmail = await AccessService.getAcessoByEmail(acesso.email);
      if (existingEmail != null) {
        throw Exception(
            'Este e-mail já está em uso por outro usuário (${existingEmail.nome}).');
      }

      await AccessService.addAcesso(acesso);
      setSearchQuery('');
    } catch (e) {
      print("Erro ao adicionar acesso: $e");
      rethrow;
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  Future<void> updateAcesso(Acesso acesso) async {
    _dataRepo.isSyncing.value = true;
    try {
      final cpfLimpo = acesso.cpf.replaceAll(RegExp(r'[^0-9]'), '');
      final existingCpf = await AccessService.getAcessoByCpf(cpfLimpo);

      if (existingCpf != null && existingCpf.id != acesso.id) {
        throw Exception(
            'Este CPF já está sendo usado por outro usuário (${existingCpf.nome}).');
      }

      final existingEmail = await AccessService.getAcessoByEmail(acesso.email);
      if (existingEmail != null && existingEmail.id != acesso.id) {
        throw Exception(
            'Este e-mail já está sendo usado por outro usuário (${existingEmail.nome}).');
      }

      await AccessService.updateAcesso(acesso);

      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      if (currentUser != null &&
          currentUser.uid == acesso.id &&
          acesso.status != 'Ativo') {
        await authService.logout();
      }
    } catch (e) {
      print("Erro ao atualizar acesso: $e");
      rethrow;
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  String formatarData(DateTime? data) {
    if (data == null) return "Nunca acessou";
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}, "
        "${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}:${data.second.toString().padLeft(2, '0')}";
  }

  String getInitials(String name) {
    if (name.isEmpty) return "";
    var nameParts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (nameParts.length >= 2) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    } else if (nameParts.length == 1) {
      return nameParts[0]
          .substring(0, nameParts[0].length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return "";
  }
}
