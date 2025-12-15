import 'package:get/get.dart';
import '../models/contribuicao_model.dart';
import '../../dizimistas/models/dizimista_model.dart'; // Ajuste se necessário
import '../../dizimistas/controllers/dizimista_controller.dart';

class ContribuicaoController extends GetxController {
  // Estado privado
  final _contribuicoes = <Contribuicao>[].obs;
  final _dizimistas = <Dizimista>[].obs;
  final _isLoading = false.obs;
  final _valorInput = ''.obs;

  // Getters públicos
  List<Contribuicao> get contribuicoes => _contribuicoes;
  List<Dizimista> get dizimistas => _dizimistas;
  bool get isLoading => _isLoading.value;
  String get valorInput => _valorInput.value;

  // ==================================================================
  // VARIÁVEIS DO FORMULÁRIO
  // ==================================================================

  // Seleção do Dízimista
  final dizimistaSelecionado = Rxn<Dizimista>();

  // Data selecionada (ADICIONADO PARA CORRIGIR O ERRO)
  final dataSelecionada = DateTime.now().obs;

  // Campos simples (Strings)
  String mesReferencia = '12/2025';
  String tipo = 'Dízimo Regular';
  String metodo = 'PIX';
  String valor = '';
  double valorNumerico = 0.0;

  @override
  void onInit() {
    super.onInit();
    fetchContribuicoes();
    fetchDizimistas();
  }

  Future<void> fetchContribuicoes() async {
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Dados de exemplo
      _contribuicoes.assignAll([
        Contribuicao(
          id: 1,
          dizimistaId: 1,
          dizimistaNome: "João Santos",
          tipo: "Dízimo Regular",
          valor: 200.00,
          metodo: "Dinheiro",
          dataRegistro: DateTime(2024, 5, 11),
        ),
        Contribuicao(
          id: 2,
          dizimistaId: 2,
          dizimistaNome: "Maria Silva",
          tipo: "Dízimo Regular",
          valor: 150.00,
          metodo: "PIX",
          dataRegistro: DateTime(2024, 5, 9),
        ),
        // Adicionei mais itens para testar o scroll se precisar...
        Contribuicao(id: 3, dizimistaId: 4, dizimistaNome: "Pedro Costa", tipo: "Oferta", valor: 50.00, metodo: "Cartão", dataRegistro: DateTime(2024, 5, 4)),
        Contribuicao(id: 4, dizimistaId: 1, dizimistaNome: "João Santos",tipo: "Dízimo", valor: 200.00, metodo: "Dinheiro", dataRegistro: DateTime(2024, 4, 11)),
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
      await Future.delayed(const Duration(seconds: 1));

      _dizimistas.assignAll([
        Dizimista(
          id: 1,
          nome: "João Santos",
          cpf: "123.456.789-00",
          telefone: "(11) 99999-1234",
          email: "joao@email.com",
          status: "Ativo",
          rua: "Rua A",
          bairro: "Centro",
          cidade: "Iporá",
          estado: "GO",
          dataRegistro: DateTime(2022, 1, 14),
          consentimento: true,
        ),
        Dizimista(
          id: 2,
          nome: "Maria Silva",
          cpf: "987.654.321-00",
          telefone: "(11) 98888-5678",
          email: "maria@email.com",
          status: "Ativo",
          rua: "Rua B",
          bairro: "Centro",
          cidade: "Iporá",
          estado: "GO",
          dataRegistro: DateTime(2023, 3, 9),
          consentimento: true,
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
      await Future.delayed(const Duration(seconds: 1));

      // Insere no topo da lista
      _contribuicoes.insert(0, contribuicao.copyWith(id: _contribuicoes.length + 1));

    } catch (e) {
      print("Erro ao adicionar contribuição: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  List<Contribuicao> getUltimosLancamentos() {
    // Ordena por data (mais recente primeiro) e pega os 5 primeiros
    final sorted = _contribuicoes.toList()..sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
    return sorted.take(5).toList();
  }

  String formatarMoeda(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  List<Dizimista> searchDizimistas(String query) {
    if (query.isEmpty) return _dizimistas;

    return _dizimistas.where((dizimista) {
      return dizimista.nome.toLowerCase().contains(query.toLowerCase()) ||
             dizimista.cpf.contains(query) ||
             dizimista.telefone.contains(query) ||
             (dizimista.email?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (dizimista.rua?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (dizimista.bairro?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             dizimista.cidade.toLowerCase().contains(query.toLowerCase()) ||
             (dizimista.observacoes?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  // Método para obter os dados de um dizimista pelo ID
  Dizimista? getDizimistaById(int id) {
    final controller = Get.find<DizimistaController>();
    try {
      return controller.dizimistas.firstWhere((dizimista) => dizimista.id == id);
    } catch (e) {
      return null;
    }
  }
}