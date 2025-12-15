import 'dart:async';

import 'package:get/get.dart';
import '../models/contribuicao_model.dart';
import '../../dizimistas/models/dizimista_model.dart'; // Ajuste se necessário
import '../../dizimistas/controllers/dizimista_controller.dart';
import '../../../core/services/dizimista_service.dart';
import '../../../core/services/contribuicao_service.dart';

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
      // Buscar contribuições reais do Firestore usando stream
      final contribuicoesStream = ContribuicaoService.getAllContribuicoes();

      // Escutar o stream e atualizar a lista local
      contribuicoesStream.listen((contribuicoesList) {
        _contribuicoes.assignAll(contribuicoesList);
      }).onError((error) {
        print("Erro ao carregar contribuições do Firestore: $error");
      });

    } catch (e) {
      print("Erro ao carregar contribuições: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchDizimistas() async {
    _isLoading.value = true;
    try {
      // Buscar diretamente do Firestore usando o serviço
      final dizimistasStream = DizimistaService.getAllDizimistas();

      // Escutar o stream e atualizar a lista local
      dizimistasStream.listen((dizimistasList) {
        _dizimistas.assignAll(dizimistasList);
      }).onError((error) {
        print("Erro ao carregar dizimistas do Firestore: $error");
      });
    } catch (e) {
      print("Erro ao carregar dizimistas: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addContribuicao(Contribuicao contribuicao) async {
    _isLoading.value = true;
    try {
      // Salvar no Firestore e obter o ID do documento criado
      final docId = await ContribuicaoService.addContribuicao(contribuicao);

      // Criar uma nova contribuição com o ID do documento do Firestore
      final contribuicaoComId = contribuicao.copyWith(id: docId);

      // Atualizar a lista local adicionando no topo
      _contribuicoes.insert(0, contribuicaoComId);

    } catch (e) {
      print("Erro ao adicionar contribuição no Firestore: $e");
      rethrow; // Re-lançar o erro para que a view possa tratar
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

    final queryLower = query.toLowerCase().trim();

    return _dizimistas.where((dizimista) {
      return dizimista.nome.toLowerCase().contains(queryLower) ||
             dizimista.cpf.contains(query) ||
             dizimista.telefone.contains(query) ||
             (dizimista.email?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.rua?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.numero?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.bairro?.toLowerCase().contains(queryLower) ?? false) ||
             dizimista.cidade.toLowerCase().contains(queryLower) ||
             dizimista.estado.toLowerCase().contains(queryLower) ||
             (dizimista.cep?.contains(query) ?? false) ||
             (dizimista.nomeConjugue?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.estadoCivil?.toLowerCase().contains(queryLower) ?? false) ||
             (dizimista.observacoes?.toLowerCase().contains(queryLower) ?? false) ||
             dizimista.status.toLowerCase().contains(queryLower);
    }).toList();
  }

  // Método para busca direta no Firestore
  Future<List<Dizimista>> searchDizimistasFirestore(String query) async {
    if (query.isEmpty) {
      // Se não houver consulta, retornar todos
      final dizimistasStream = DizimistaService.getAllDizimistas();
      final completer = Completer<List<Dizimista>>();

      dizimistasStream.listen((dizimistasList) {
        if (!completer.isCompleted) {
          completer.complete(dizimistasList);
        }
      }).onError((error) {
        if (!completer.isCompleted) {
          completer.complete([]);
        }
      });

      return completer.future;
    } else {
      // Se houver consulta, usar busca avançada
      final dizimistasStream = DizimistaService.advancedSearch(query);
      final completer = Completer<List<Dizimista>>();

      dizimistasStream.listen((dizimistasList) {
        if (!completer.isCompleted) {
          completer.complete(dizimistasList);
        }
      }).onError((error) {
        if (!completer.isCompleted) {
          completer.complete([]);
        }
      });

      return completer.future;
    }
  }

  // Método para obter os dados de um dizimista pelo ID
  Dizimista? getDizimistaById(String id) {
    final controller = Get.find<DizimistaController>();
    try {
      return controller.dizimistas.firstWhere((dizimista) => dizimista.id == id);
    } catch (e) {
      return null;
    }
  }

  // Validações
  bool validateForm() {
    if (dizimistaSelecionado.value == null) {
      print("Erro: Nenhum dizimista selecionado");
      return false;
    }

    if (valor.isEmpty) {
      print("Erro: Valor não informado");
      return false;
    }

    final valorDouble = double.tryParse(valor);
    if (valorDouble == null || valorDouble <= 0) {
      print("Erro: Valor inválido");
      return false;
    }

    return true;
  }

  // Criar uma nova contribuição a partir dos dados do formulário
  Contribuicao createContribuicaoFromForm() {
    final dizimista = dizimistaSelecionado.value!;
    final valorDouble = double.tryParse(valor) ?? 0.0;

    return Contribuicao(
      id: '', // O ID será definido pelo Firestore
      dizimistaId: dizimista.id,
      dizimistaNome: dizimista.nome,
      tipo: tipo,
      valor: valorDouble,
      metodo: metodo,
      dataRegistro: dataSelecionada.value,
    );
  }
}