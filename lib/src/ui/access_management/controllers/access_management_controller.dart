import 'package:get/get.dart';
import '../models/acesso_model.dart';
import '../models/funcao_model.dart';

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
      // Simulating API delay
      await Future.delayed(const Duration(seconds: 1));

      // Sample data
      _acessos.assignAll([
        Acesso(
          id: 1,
          nome: "Pe. Carlos Silva",
          email: "padre.carlos@paroquia.org",
          funcao: "Administrador",
          status: "Ativo",
          ultimoAcesso: DateTime(2024, 5, 20, 10, 30, 0),
        ),
        Acesso(
          id: 2,
          nome: "Ana Paula Souza",
          email: "ana.secretaria@paroquia.org",
          funcao: "Secretaria",
          status: "Ativo",
          ultimoAcesso: DateTime(2024, 5, 19, 14, 15, 0),
        ),
        Acesso(
          id: 3,
          nome: "Marcos Oliveira",
          email: "marcos.finan@paroquia.org",
          funcao: "Financeiro",
          status: "Ativo",
          ultimoAcesso: DateTime(2024, 5, 18, 9, 0, 0),
        ),
        Acesso(
          id: 4,
          nome: "Maria Eduarda Santos",
          email: "maria.edu@paroquia.org",
          funcao: "Secretaria",
          status: "Inativo",
          ultimoAcesso: DateTime(2024, 4, 15, 11, 45, 0),
        ),
        Acesso(
          id: 5,
          nome: "João Batista",
          email: "joao.batista@paroquia.org",
          funcao: "Financeiro",
          status: "Ativo",
          ultimoAcesso: DateTime(2024, 5, 21, 16, 20, 0),
        ),
      ]);
    } catch (e) {
      print("Erro ao carregar acessos: $e");
    } finally {
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
      await Future.delayed(const Duration(seconds: 1));
      _acessos.add(acesso.copyWith(id: _acessos.length + 1));
    } catch (e) {
      print("Erro ao adicionar acesso: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateAcesso(Acesso acesso) async {
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      final index = _acessos.indexWhere((a) => a.id == acesso.id);
      if (index != -1) {
        _acessos[index] = acesso;
      }
    } catch (e) {
      print("Erro ao atualizar acesso: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAcesso(int id) async {
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      _acessos.removeWhere((acesso) => acesso.id == id);
    } catch (e) {
      print("Erro ao deletar acesso: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  String formatarData(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}, "
        "${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}:${data.second.toString().padLeft(2, '0')}";
  }

  String getInitials(String name) {
    var nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    } else if (nameParts.length == 1) {
      return nameParts[0].substring(0, 2).toUpperCase();
    } else {
      return "";
    }
  }
}