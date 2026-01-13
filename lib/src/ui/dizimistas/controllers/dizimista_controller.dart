import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/dizimista_service.dart';
import '../../../core/services/data_repository_service.dart';
import '../../../core/services/contribuicao_service.dart';
import '../../../data/services/auth_service.dart';
import '../../contribuicoes/models/contribuicao_model.dart';
import '../../../domain/models/acesso_model.dart';
import '../models/dizimista_model.dart';

class DizimistaController extends GetxController {
  final _dataRepo = Get.find<DataRepositoryService>();

  // Estado privado derivado do repositório
  List<Dizimista> get _dizimistas => _dataRepo.dizimistas;
  List<Contribuicao> get _contribuicoes => _dataRepo.contribuicoes;
  List<Acesso> get _todosAcessos => _dataRepo.acessos;

  bool get isLoading => _dataRepo.isSyncing.value;

  List<Dizimista> get dizimistas => _dizimistas;
  List<Contribuicao> get contribuicoes => _contribuicoes;
  final searchQuery = ''.obs;

  // Paginação
  final int pageSize = 20;
  final RxInt displayedCount = 20.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;

  // Verificação de permissão para apagar
  bool get isAuthorizedToDelete {
    final auth = Get.find<AuthService>();
    final role = auth.currentUserData?.funcao ?? '';
    return role == 'Administrador' || role == 'Financeiro';
  }

  // Método para obter o histórico de contribuições de um dizimista
  List<Contribuicao> historicoContribuicoes(String dizimistaId) {
    final list =
        _contribuicoes.where((c) => c.dizimistaId == dizimistaId).toList();

    // Ordena pelo mês de referência (decrescente: mais recente primeiro)
    list.sort((a, b) {
      String mesA = '';
      String mesB = '';

      if (a.mesesCompetencia.isNotEmpty) mesA = a.mesesCompetencia.first;
      if (b.mesesCompetencia.isNotEmpty) mesB = b.mesesCompetencia.first;

      // Se ambos tiverem mês, compara como strings (YYYY-MM funciona lexicograficamente)
      if (mesA.isNotEmpty && mesB.isNotEmpty) {
        return mesB.compareTo(mesA);
      }

      // Se não tiver mês, usa data de registro como fallback
      return b.dataRegistro.compareTo(a.dataRegistro);
    });

    return list;
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

  // Lista paginada para exibição
  List<Dizimista> get paginatedDizimistas {
    final allFiltered = filteredDizimistas;
    final count = displayedCount.value;

    if (allFiltered.length <= count) {
      return allFiltered;
    }

    return allFiltered.take(count).toList();
  }

  void loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    displayedCount.value += pageSize;
    isLoadingMore.value = false;
  }

  void resetPagination() {
    displayedCount.value = pageSize;
    hasMore.value = true;
  }

  @override
  void onInit() {
    super.onInit();

    // Reset da paginação ao buscar
    Timer? searchDebounce;
    ever(searchQuery, (query) {
      searchDebounce?.cancel();
      searchDebounce = Timer(const Duration(milliseconds: 300), () {
        resetPagination();
      });
    });

    // Atualiza hasMore
    void updateHasMore(_) {
      final allFiltered = filteredDizimistas;
      hasMore.value = allFiltered.length > displayedCount.value;
    }

    ever(_dataRepo.dizimistas, updateHasMore);
    ever(displayedCount, updateHasMore);
    ever(searchQuery, updateHasMore);
  }

  // Método para obter a data da última contribuição de um dizimista
  DateTime? getLastContributionDate(String dizimistaId) {
    try {
      final filtered =
          _contribuicoes.where((c) => c.dizimistaId == dizimistaId).toList();
      if (filtered.isEmpty) return null;
      return filtered.first.dataRegistro;
    } catch (_) {
      return null;
    }
  }

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

  int getMonthsOfDelay(String dizimistaId) {
    final lastDate = getLastContributionDate(dizimistaId);
    if (lastDate == null) return 999;

    final now = DateTime.now();
    return ((now.year - lastDate.year) * 12) + now.month - lastDate.month;
  }

  Future<void> fetchDizimistas() async {
    _dataRepo.refreshData();
  }

  Future<void> addDizimista(Dizimista dizimista) async {
    _dataRepo.isSyncing.value = true;
    try {
      if (dizimista.nome.isEmpty)
        throw Exception('O Nome Completo é obrigatório.');

      // Validar duplicidade de Número de Registro (se informado)
      if (dizimista.numeroRegistro.isNotEmpty) {
        final existente = await DizimistaService.getDizimistaByRegistro(
            dizimista.numeroRegistro);
        if (existente != null) {
          throw Exception(
              'O número de registro "${dizimista.numeroRegistro}" já pertence a: ${existente.nome}.');
        }
      }

      await DizimistaService.addDizimista(dizimista);
      searchQuery.value = '';
    } catch (e) {
      print("Erro ao adicionar dizimista: $e");
      rethrow;
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  Future<void> updateDizimista(Dizimista dizimista) async {
    _dataRepo.isSyncing.value = true;
    try {
      if (dizimista.nome.isEmpty)
        throw Exception('O Nome Completo é obrigatório.');

      // Validar duplicidade de Número de Registro ao atualizar
      if (dizimista.numeroRegistro.isNotEmpty) {
        final existente = await DizimistaService.getDizimistaByRegistro(
            dizimista.numeroRegistro);
        if (existente != null && existente.id != dizimista.id) {
          throw Exception(
              'O número de registro "${dizimista.numeroRegistro}" já pertence a outro fiel: ${existente.nome}.');
        }
      }

      await DizimistaService.updateDizimista(dizimista);
    } catch (e) {
      print("Erro ao atualizar dizimista: $e");
      rethrow;
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  Future<void> deleteDizimistaComHistorico(Dizimista dizimista) async {
    if (!isAuthorizedToDelete) {
      Get.snackbar(
        'Acesso Negado',
        'Você não tem permissão para excluir registros.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _dataRepo.isSyncing.value = true;
    try {
      // 1. Buscar todas as contribuições do dizimista
      final historico =
          _contribuicoes.where((c) => c.dizimistaId == dizimista.id).toList();

      // 2. Apagar cada contribuição
      for (var c in historico) {
        await ContribuicaoService.deleteContribuicao(c.id);
      }

      // 3. Apagar o dizimista
      await DizimistaService.deleteDizimista(dizimista.id);

      Get.snackbar(
        'Sucesso',
        'Fiel e todo seu histórico foram removidos.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Erro ao excluir dizimista e histórico: $e");
      Get.snackbar(
        'Erro',
        'Não foi possível concluir a exclusão: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  void onViewReady() {}

  Stream<List<Dizimista>> searchDizimistas(String query) {
    if (query.isEmpty) {
      return DizimistaService.getAllDizimistas();
    } else {
      return DizimistaService.advancedSearch(query);
    }
  }

  String getAgentName(String uid) {
    if (uid.isEmpty) return 'Sistema';
    try {
      final agent = _todosAcessos.firstWhereOrNull((a) => a.id == uid);
      return agent?.nome ?? 'Usuário Desconhecido';
    } catch (_) {
      return 'Usuário Desconhecido';
    }
  }

  String getAgentFunction(String uid) {
    if (uid.isEmpty) return 'Automático';
    try {
      final agent = _todosAcessos.firstWhereOrNull((a) => a.id == uid);
      return agent?.funcao ?? 'Agente';
    } catch (_) {
      return 'Agente';
    }
  }
}
