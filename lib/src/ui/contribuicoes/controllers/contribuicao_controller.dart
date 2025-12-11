import 'package:get/get.dart';
import '../models/contribuicao_model.dart';
import '../../dizimistas/models/dizimista_model.dart';

class ContribuicaoController extends GetxController {
  final _contribuicoes = <Contribuicao>[].obs;
  final _dizimistas = <Dizimista>[].obs;
  final _isLoading = false.obs;
  final _valorInput = ''.obs;
  
  List<Contribuicao> get contribuicoes => _contribuicoes;
  List<Dizimista> get dizimistas => _dizimistas;
  bool get isLoading => _isLoading.value;
  String get valorInput => _valorInput.value;
  
  // Variáveis para o formulário
  final dizimistaSelecionado = Rxn<Dizimista>();
  String mesReferencia = '12/2025';
  String tipo = 'Dízimo Regular';
  String metodo = 'PIX';
  String valor = '';

  @override
  void onInit() {
    super.onInit();
    fetchContribuicoes();
    fetchDizimistas();
  }
  
  Future<void> fetchContribuicoes() async {
    _isLoading.value = true;
    try {
      // Simulando carregamento de dados
      await Future.delayed(const Duration(seconds: 1));
      
      // Dados de exemplo
      _contribuicoes.assignAll([
        Contribuicao(
          id: 1,
          dizimistaId: 1,
          dizimistaNome: "João Santos",
          mesReferencia: "05/2024",
          tipo: "Dízimo Regular",
          valor: 200.00,
          metodo: "Dinheiro",
          dataRegistro: DateTime(2024, 5, 11),
        ),
        Contribuicao(
          id: 2,
          dizimistaId: 2,
          dizimistaNome: "Maria Silva",
          mesReferencia: "05/2024",
          tipo: "Dízimo Regular",
          valor: 150.00,
          metodo: "PIX",
          dataRegistro: DateTime(2024, 5, 9),
        ),
        Contribuicao(
          id: 3,
          dizimistaId: 4,
          dizimistaNome: "Pedro Costa",
          mesReferencia: "05/2024",
          tipo: "Oferta de Devolução",
          valor: 50.00,
          metodo: "Cartão de Débito",
          dataRegistro: DateTime(2024, 5, 4),
        ),
        Contribuicao(
          id: 4,
          dizimistaId: 1,
          dizimistaNome: "João Santos",
          mesReferencia: "04/2024",
          tipo: "Dízimo Regular",
          valor: 200.00,
          metodo: "Dinheiro",
          dataRegistro: DateTime(2024, 4, 11),
        ),
        Contribuicao(
          id: 5,
          dizimistaId: 2,
          dizimistaNome: "Maria Silva",
          mesReferencia: "04/2024",
          tipo: "Dízimo Regular",
          valor: 150.00,
          metodo: "PIX",
          dataRegistro: DateTime(2024, 4, 9),
        ),
        Contribuicao(
          id: 6,
          dizimistaId: 3,
          dizimistaNome: "Ana Oliveira",
          mesReferencia: "02/2024",
          tipo: "Dízimo Regular",
          valor: 100.00,
          metodo: "Cartão de Débito",
          dataRegistro: DateTime(2024, 2, 14),
        ),
      ]);
    } catch (e) {
      print("Erro ao carregar contribuições: $e");
    } finally {
      _isLoading.value = false;
    }
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
          nome: "João Santos",
          cpf: "123.456.789-00",
          telefone: "(11) 99999-1234",
          email: "joao.santos@email.com",
          status: "Ativo",
          endereco: "Rua das Flores, 123",
          cidade: "Iporá",
          estado: "GO",
          dataRegistro: DateTime(2022, 1, 14),
        ),
        Dizimista(
          id: 2,
          nome: "Maria Silva",
          cpf: "987.654.321-00",
          telefone: "(11) 98888-5678",
          email: "maria.silva@email.com",
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
      ]);
    } catch (e) {
      print("Erro ao carregar dizimistas: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> addContribuicao(Contribuicao contribuicao) async {
    _isLoading.value = true;
    try {
      // Simulando adição
      await Future.delayed(const Duration(seconds: 1));
      
      _contribuicoes.insert(0, contribuicao.copyWith(id: _contribuicoes.length + 1));
    } catch (e) {
      print("Erro ao adicionar contribuição: $e");
    } finally {
      _isLoading.value = false;
    }
  }
  
  List<Contribuicao> getUltimosLancamentos() {
    // Retorna as últimas 5 contribuições ordenadas por data
    final sorted = _contribuicoes.toList()..sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
    return sorted.take(5).toList();
  }
  
  String formatarMoeda(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }
}