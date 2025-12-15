import 'package:get/get.dart';
import '../../../core/services/dizimista_service.dart';
import '../models/dizimista_model.dart';

class DizimistaController extends GetxController {
  final _dizimistas = <Dizimista>[].obs;
  final _isLoading = false.obs;
  
  List<Dizimista> get dizimistas => _dizimistas;
  bool get isLoading => _isLoading.value;
  final searchQuery = ''.obs;

  List<Dizimista> get filteredDizimistas {
    if (searchQuery.value.isEmpty) {
      return _dizimistas;
    } else {
      final queryLower = searchQuery.value.toLowerCase().trim();
      return _dizimistas.where((dizimista) {
        return dizimista.nome.toLowerCase().contains(queryLower) ||
               dizimista.cpf.contains(searchQuery.value) ||
               dizimista.numeroRegistro.contains(searchQuery.value) ||
               dizimista.telefone.contains(searchQuery.value) ||
               (dizimista.email?.toLowerCase().contains(queryLower) ?? false) ||
               (dizimista.rua?.toLowerCase().contains(queryLower) ?? false) ||
               (dizimista.numero?.toLowerCase().contains(queryLower) ?? false) ||
               (dizimista.bairro?.toLowerCase().contains(queryLower) ?? false) ||
               dizimista.cidade.toLowerCase().contains(queryLower) ||
               dizimista.estado.toLowerCase().contains(queryLower) ||
               (dizimista.cep?.contains(searchQuery.value) ?? false) ||
               (dizimista.nomeConjugue?.toLowerCase().contains(queryLower) ?? false) ||
               (dizimista.estadoCivil?.toLowerCase().contains(queryLower) ?? false) ||
               (dizimista.observacoes?.toLowerCase().contains(queryLower) ?? false) ||
               dizimista.status.toLowerCase().contains(queryLower);
      }).toList();
    }
  }
  
  @override
  void onInit() {
    super.onInit();

    // Escutar mudanças em tempo real no Firestore
    DizimistaService.getAllDizimistas().listen((dizimistasList) {
      _dizimistas.assignAll(dizimistasList);
    }).onError((error) {
      print("Erro ao carregar dizimistas do Firestore: $error");
    });

    // Observar mudanças na pesquisa para atualizar a lista filtrada
    ever(searchQuery, (_) {
      // A atualização é automática graças ao getter filteredDizimistas
    });
  }

  Future<void> fetchDizimistas() async {
    // Esta função agora é opcional já que estamos usando escuta em tempo real
    // Pode ser usada para forçar um refresh se necessário
    _isLoading.value = true;
    try {
      // A atualização é feita automaticamente pela escuta em tempo real
    } catch (e) {
      print("Erro ao carregar dizimistas: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addDizimista(Dizimista dizimista) async {
    _isLoading.value = true;
    try {
      await DizimistaService.addDizimista(dizimista);
    } catch (e) {
      print("Erro ao adicionar dizimista no Firestore: $e");
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateDizimista(Dizimista dizimista) async {
    _isLoading.value = true;
    try {
      await DizimistaService.updateDizimista(dizimista);
    } catch (e) {
      print("Erro ao atualizar dizimista no Firestore: $e");
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // Método para busca com base na pesquisa
  Stream<List<Dizimista>> searchDizimistas(String query) {
    if (query.isEmpty) {
      return DizimistaService.getAllDizimistas();
    } else {
      return DizimistaService.advancedSearch(query);
    }
  }
}