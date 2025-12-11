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
          cpf: "123.456.789-00",
          telefone: "(64) 99988-7766",
          endereco: "Rua das Igrejas, 100",
          funcao: "Administrador",
          status: "Ativo",
          ultimoAcesso: DateTime(2024, 5, 20, 10, 30, 0),
          pendencia: false,
        ),
        Acesso(
          id: 2,
          nome: "Ana Paula Souza",
          email: "ana.secretaria@paroquia.org",
          cpf: "234.567.890-11",
          telefone: "(64) 98877-6655",
          endereco: "Av. Central, 450",
          funcao: "Secretaria",
          status: "Ativo",
          ultimoAcesso: DateTime(2024, 5, 19, 14, 15, 0),
          pendencia: false,
        ),
        Acesso(
          id: 3,
          nome: "Marcos Oliveira",
          email: "marcos.finan@paroquia.org",
          cpf: "345.678.901-22",
          telefone: "(64) 97766-5544",
          endereco: "Rua Comercial, 230",
          funcao: "Financeiro",
          status: "Ativo",
          ultimoAcesso: DateTime(2024, 5, 18, 9, 0, 0),
          pendencia: false,
        ),
        Acesso(
          id: 4,
          nome: "Maria Eduarda Santos",
          email: "maria.edu@paroquia.org",
          cpf: "456.789.012-33",
          telefone: "(64) 96655-4433",
          endereco: "Praça da Matriz, 50",
          funcao: "Secretaria",
          status: "Inativo",
          ultimoAcesso: DateTime(2024, 4, 15, 11, 45, 0),
          pendencia: false,
        ),
        Acesso(
          id: 5,
          nome: "João Batista",
          email: "joao.batista@paroquia.org",
          cpf: "567.890.123-44",
          telefone: "(64) 95544-3322",
          endereco: "Rua das Flores, 800",
          funcao: "Financeiro",
          status: "Ativo",
          ultimoAcesso: DateTime(2024, 5, 21, 16, 20, 0),
          pendencia: true,
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
      _acessos.add(acesso.copyWith(
        id: _acessos.length + 1,
        pendencia: false, // New users start without password pendencia
      ));
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