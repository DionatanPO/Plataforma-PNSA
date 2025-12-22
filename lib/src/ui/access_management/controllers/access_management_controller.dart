import 'dart:async';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../domain/models/acesso_model.dart';
import '../../../domain/models/funcao_model.dart';
import '../../../core/services/access_service.dart';

class AccessManagementController extends GetxController {
  final _acessos = <Acesso>[].obs;
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;

  List<Acesso> get acessos => _acessos;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;

  StreamSubscription? _acessosSub;

  @override
  void onInit() {
    super.onInit();

    final authService = Get.find<AuthService>();

    // Escutar mudanças no login
    ever(authService.userData, (userData) {
      if (userData != null) {
        _setupAcessosStream();
      } else {
        _stopListening();
      }
    });

    // Se já estiver logado (ex: F5)
    if (authService.userData.value != null) {
      _setupAcessosStream();
    }
  }

  void _setupAcessosStream() {
    _stopListening();
    _isLoading.value = true;
    final authService = Get.find<AuthService>();

    // Subscreve ao stream de dados do Firestore uma única vez
    _acessosSub = AccessService.getAllAcessos().listen((acessosList) {
      final currentUserId = authService.currentUser?.uid;

      if (currentUserId != null) {
        final filteredList =
            acessosList.where((acesso) => acesso.id != currentUserId).toList();
        _acessos.assignAll(filteredList);
      } else {
        _acessos.assignAll(acessosList);
      }
      _isLoading.value = false;
    }, onError: (error) {
      print("Erro no stream de acessos: $error");
      _isLoading.value = false;
    });
  }

  void _stopListening() {
    _acessosSub?.cancel();
    _acessos.clear();
  }

  @override
  void onClose() {
    _stopListening();
    super.onClose();
  }

  // Removido o método fetchAcessos manual para evitar inconsistências

  List<Funcao> getFuncoes() {
    return FuncoesRepository.getFuncoes();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  List<Acesso> get filteredAcessos {
    final authService = Get.find<AuthService>();
    final currentUser = authService.currentUser;
    final currentUserId = currentUser?.uid;

    List<Acesso> baseList = _acessos.toList();

    // Filtrar o usuário logado da lista base
    if (currentUserId != null) {
      baseList =
          baseList.where((acesso) => acesso.id != currentUserId).toList();
    }

    if (_searchQuery.isEmpty) {
      return baseList;
    } else {
      return baseList
          .where(
            (acesso) =>
                acesso.nome.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                acesso.email.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                acesso.funcao.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }
  }

  Future<void> addAcesso(Acesso acesso) async {
    _isLoading.value = true;
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
      // Limpa a busca para que o novo usuário apareça imediatamente
      setSearchQuery('');
    } catch (e) {
      print("Erro ao adicionar acesso: $e");
      rethrow; // Repassar o erro para a View tratar
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateAcesso(Acesso acesso) async {
    _isLoading.value = true;
    try {
      // 1. Verificar duplicidade de CPF (se mudou o CPF)
      final cpfLimpo = acesso.cpf.replaceAll(RegExp(r'[^0-9]'), '');
      final existingCpf = await AccessService.getAcessoByCpf(cpfLimpo);

      if (existingCpf != null && existingCpf.id != acesso.id) {
        throw Exception(
            'Este CPF já está sendo usado por outro usuário (${existingCpf.nome}).');
      }

      // 2. Verificar duplicidade de E-mail (se mudou o e-mail)
      final existingEmail = await AccessService.getAcessoByEmail(acesso.email);
      if (existingEmail != null && existingEmail.id != acesso.id) {
        throw Exception(
            'Este e-mail já está sendo usado por outro usuário (${existingEmail.nome}).');
      }

      await AccessService.updateAcesso(acesso);

      // Verificar se o usuário atual está sendo atualizado e se o status foi alterado para Inativo
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      if (currentUser != null &&
          currentUser.uid == acesso.id &&
          acesso.status != 'Ativo') {
        // Se o usuário atual está sendo desativado, fazer logout
        await authService.logout();
        Get.snackbar(
          'Acesso Negado',
          'Sua conta foi desativada pelo administrador.',
        );
      }
    } catch (e) {
      print("Erro ao atualizar acesso: $e");
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  String formatarData(DateTime? data) {
    if (data == null) return "Nunca acessou";
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}, "
        "${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}:${data.second.toString().padLeft(2, '0')}";
  }

  String getInitials(String name) {
    if (name == null || name.isEmpty) {
      return "";
    }

    var nameParts = name.split(' ').where((part) => part.isNotEmpty).toList();

    if (nameParts.length >= 2) {
      String firstInitial = nameParts[0].isNotEmpty ? nameParts[0][0] : '';
      String secondInitial = nameParts[1].isNotEmpty ? nameParts[1][0] : '';
      return (firstInitial + secondInitial).toUpperCase();
    } else if (nameParts.length == 1) {
      if (nameParts[0].length >= 2) {
        return nameParts[0].substring(0, 2).toUpperCase();
      } else if (nameParts[0].isNotEmpty) {
        return nameParts[0][0].toUpperCase();
      } else {
        return "";
      }
    } else {
      return "";
    }
  }
}
