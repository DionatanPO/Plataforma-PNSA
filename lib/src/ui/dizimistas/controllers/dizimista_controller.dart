import 'package:get/get.dart';
import '../models/dizimista_model.dart';

class DizimistaController extends GetxController {
  final _dizimistas = <Dizimista>[].obs;
  final _isLoading = false.obs;
  
  List<Dizimista> get dizimistas => _dizimistas;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    fetchDizimistas();
  }
  
  Future<void> fetchDizimistas() async {
    _isLoading.value = true;
    try {
      // Simulando carregamento de dados
      await Future.delayed(const Duration(seconds: 1));
      
      // Dados de exemplo
      _dizimistas.assignAll([
        Dizimista(
          id: 1,
          nome: "Maria Silva",
          cpf: "123.456.789-00",
          telefone: "(11) 99999-1234",
          email: "maria.silva@email.com",
          status: "Ativo",
          endereco: "Rua das Flores, 123",
          cidade: "Iporá",
          estado: "GO",
          dataRegistro: DateTime(2022, 1, 14),
        ),
        Dizimista(
          id: 2,
          nome: "João Santos",
          cpf: "987.654.321-00",
          telefone: "(11) 98888-5678",
          email: "joao.santos@email.com",
          status: "Ativo",
          endereco: "Av. Principal, 500",
          cidade: "Iporá",
          estado: "GO",
          dataRegistro: DateTime(2023, 3, 9),
        ),
        Dizimista(
          id: 3,
          nome: "Ana Oliveira",
          cpf: "456.789.123-00",
          telefone: "(11) 97777-4321",
          email: "ana.oliveira@email.com",
          status: "Afastado",
          endereco: "Rua do Campo, 45",
          cidade: "Iporá",
          estado: "GO",
          dataRegistro: DateTime(2021, 11, 4),
        ),
        Dizimista(
          id: 4,
          nome: "Pedro Costa",
          cpf: "321.654.987-00",
          telefone: "(11) 96666-9876",
          email: "pedro.costa@email.com",
          status: "Novo Contribuinte",
          endereco: "Alameda dos Anjos, 77",
          cidade: "Iporá",
          estado: "GO",
          dataRegistro: DateTime(2024, 1, 19),
        ),
        Dizimista(
          id: 5,
          nome: "Lúcia Ferreira",
          cpf: "147.258.369-00",
          telefone: "(11) 95555-1111",
          email: "lucia.ferreira@email.com",
          status: "Inativo",
          endereco: "Beco da Paz, 8",
          cidade: "Iporá",
          estado: "GO",
          dataRegistro: DateTime(2020, 5, 14),
        ),
      ]);
    } catch (e) {
      print("Erro ao carregar dizimistas: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> addDizimista(Dizimista dizimista) async {
    _isLoading.value = true;
    try {
      // Simulando adição
      await Future.delayed(const Duration(seconds: 1));
      
      _dizimistas.add(dizimista.copyWith(id: _dizimistas.length + 1));
    } catch (e) {
      print("Erro ao adicionar dizimista: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> updateDizimista(Dizimista dizimista) async {
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _dizimistas.indexWhere((d) => d.id == dizimista.id);
      if (index != -1) {
        _dizimistas[index] = dizimista;
      }
    } catch (e) {
      print("Erro ao atualizar dizimista: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> deleteDizimista(int id) async {
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _dizimistas.removeWhere((d) => d.id == id);
    } catch (e) {
      print("Erro ao deletar dizimista: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  List<Dizimista> searchDizimistas(String query) {
    if (query.isEmpty) return _dizimistas;
    
    return _dizimistas.where((dizimista) {
      return dizimista.nome.toLowerCase().contains(query.toLowerCase()) ||
             dizimista.cpf.contains(query) ||
             dizimista.telefone.contains(query) ||
             dizimista.email.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}