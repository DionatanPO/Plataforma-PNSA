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

  @override
  void onInit() {
    super.onInit();
    fetchAcessos();
  }

  Future<void> fetchAcessos() async {
    _isLoading.value = true;
    try {
      // Subscreve ao stream de dados do Firestore
      AccessService.getAllAcessos().listen((acessosList) {
        _acessos.assignAll(acessosList);
        _isLoading.value = false;
      }).onError((error) {
        print("Erro ao carregar acessos do Firestore: $error");
        _isLoading.value = false;
      });
    } catch (e) {
      print("Erro ao carregar acessos: $e");
      _isLoading.value = false;
    }
  }

  List<Funcao> getFuncoes() {
    return FuncoesRepository.getFuncoes();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  List<Acesso> get filteredAcessos {
    if (_searchQuery.isEmpty) {
      return _acessos.toList();
    } else {
      return _acessos.where((acesso) =>
        acesso.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        acesso.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        acesso.funcao.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
  }

  Future<void> addAcesso(Acesso acesso) async {
    _isLoading.value = true;
    try {
      await AccessService.addAcesso(acesso);
    } catch (e) {
      print("Erro ao adicionar acesso: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateAcesso(Acesso acesso) async {
    _isLoading.value = true;
    try {
      await AccessService.updateAcesso(acesso);

      // Verificar se o usuário atual está sendo atualizado e se o status foi alterado para Inativo
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      if (currentUser != null && currentUser.uid == acesso.id && acesso.status != 'Ativo') {
        // Se o usuário atual está sendo desativado, fazer logout
        await authService.logout();
        Get.snackbar('Acesso Negado', 'Sua conta foi desativada pelo administrador.');
      }
    } catch (e) {
      print("Erro ao atualizar acesso: $e");
    } finally {
      _isLoading.value = false;
    }
  }



  String formatarData(DateTime data) {
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