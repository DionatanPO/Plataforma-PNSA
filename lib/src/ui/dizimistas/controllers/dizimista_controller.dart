import 'package:get/get.dart';
import '../../../core/services/dizimista_service.dart';
import '../../../core/services/contribuicao_service.dart';
import '../../contribuicoes/models/contribuicao_model.dart';
import '../models/dizimista_model.dart';

class DizimistaController extends GetxController {
  final _dizimistas = <Dizimista>[].obs;
  final _contribuicoes = <Contribuicao>[].obs;
  final _isLoading = false.obs;

  List<Dizimista> get dizimistas => _dizimistas;
  List<Contribuicao> get contribuicoes => _contribuicoes;
  bool get isLoading => _isLoading.value;
  final searchQuery = ''.obs;

  // Método para obter o histórico de contribuições de um dizimista
  List<Contribuicao> historicoContribuicoes(String dizimistaId) {
    return _contribuicoes.where((c) => c.dizimistaId == dizimistaId).toList();
  }

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
            (dizimista.nomeConjugue?.toLowerCase().contains(queryLower) ??
                false) ||
            (dizimista.estadoCivil?.toLowerCase().contains(queryLower) ??
                false) ||
            (dizimista.observacoes?.toLowerCase().contains(queryLower) ??
                false) ||
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

    // Escutar mudanças em tempo real nas contribuições
    ContribuicaoService.getAllContribuicoes().listen((contribuicaoList) {
      _contribuicoes.assignAll(contribuicaoList);
    }).onError((error) {
      print("Erro ao carregar contribuições do Firestore: $error");
    });

    // Observar mudanças na pesquisa para atualizar a lista filtrada
    ever(searchQuery, (_) {
      // A atualização é automática graças ao getter filteredDizimistas
    });
  }

  // Método para obter a data da última contribuição de um dizimista
  DateTime? getLastContributionDate(String dizimistaId) {
    try {
      final filtered =
          _contribuicoes.where((c) => c.dizimistaId == dizimistaId).toList();
      if (filtered.isEmpty) return null;

      // Como a lista já vem ordenada por dataRegistro desc do serviço, o primeiro é o mais recente
      return filtered.first.dataRegistro;
    } catch (_) {
      return null;
    }
  }

  // Método para formatar quanto tempo faz desde a última contribuição
  String getTimeSinceLastContribution(String dizimistaId) {
    final lastDate = getLastContributionDate(dizimistaId);
    if (lastDate == null) return 'Nenhuma';

    final now = DateTime.now();
    final difference = now.difference(lastDate);

    if (difference.inDays == 0) return 'Hoje';
    if (difference.inDays == 1) return 'Ontem';
    if (difference.inDays < 30) return '${difference.inDays} dias';

    final months = (difference.inDays / 30).floor();
    if (months == 1) return '1 mês';
    if (months < 12) return '$months meses';

    final years = (months / 12).floor();
    if (years == 1) return '1 ano';
    return '$years anos';
  }

  // Método para obter meses de atraso (para lógica de status se precisar)
  int getMonthsOfDelay(String dizimistaId) {
    final lastDate = getLastContributionDate(dizimistaId);
    if (lastDate == null) return 999; // Nunca contribuiu

    final now = DateTime.now();
    return ((now.year - lastDate.year) * 12) + now.month - lastDate.month;
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
      // 1. Verificar Número de Registro (Obrigatório e Único)
      if (dizimista.numeroRegistro.isEmpty) {
        throw Exception('O Nº de Registro Paroquial é obrigatório.');
      }
      final existingRegistro = await DizimistaService.getDizimistaByRegistro(
          dizimista.numeroRegistro);
      if (existingRegistro != null) {
        throw Exception(
            'Este Nº de Registro Paroquial já pertence a ${existingRegistro.nome}.');
      }

      // 2. Verificar CPF (Único se preenchido)
      if (dizimista.cpf.isNotEmpty) {
        final existingCpf =
            await DizimistaService.getDizimistaByCpf(dizimista.cpf);
        if (existingCpf != null) {
          throw Exception(
              'Este CPF já está cadastrado para ${existingCpf.nome}.');
        }
      }

      // 3. Verificar E-mail (Único se preenchido)
      if (dizimista.email != null && dizimista.email!.isNotEmpty) {
        final existingEmail =
            await DizimistaService.getDizimistaByEmail(dizimista.email!);
        if (existingEmail != null) {
          throw Exception(
              'Este e-mail já está em uso por ${existingEmail.nome}.');
        }
      }

      await DizimistaService.addDizimista(dizimista);
      // Limpa a busca para garantir que o novo fiel apareça na lista
      searchQuery.value = '';
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
      // 1. Verificar Número de Registro (Único)
      if (dizimista.numeroRegistro.isNotEmpty) {
        final existingRegistro = await DizimistaService.getDizimistaByRegistro(
            dizimista.numeroRegistro);
        if (existingRegistro != null && existingRegistro.id != dizimista.id) {
          throw Exception(
              'Este Nº de Registro Paroquial já pertence a ${existingRegistro.nome}.');
        }
      }

      // 2. Verificar CPF (Único se preenchido)
      if (dizimista.cpf.isNotEmpty) {
        final existingCpf =
            await DizimistaService.getDizimistaByCpf(dizimista.cpf);
        if (existingCpf != null && existingCpf.id != dizimista.id) {
          throw Exception(
              'Este CPF já está sendo usado por ${existingCpf.nome}.');
        }
      }

      // 3. Verificar E-mail (Único se preenchido)
      if (dizimista.email != null && dizimista.email!.isNotEmpty) {
        final existingEmail =
            await DizimistaService.getDizimistaByEmail(dizimista.email!);
        if (existingEmail != null && existingEmail.id != dizimista.id) {
          throw Exception(
              'Este e-mail já está sendo usado por ${existingEmail.nome}.');
        }
      }

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
