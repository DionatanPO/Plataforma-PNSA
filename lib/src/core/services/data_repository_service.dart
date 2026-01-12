import 'dart:async';
import 'package:get/get.dart';
import '../services/dizimista_service.dart';
import '../services/contribuicao_service.dart';
import '../services/access_service.dart';
import '../../data/services/auth_service.dart';
import '../../ui/dizimistas/models/dizimista_model.dart';
import '../../ui/contribuicoes/models/contribuicao_model.dart';
import '../../domain/models/acesso_model.dart';

class DataRepositoryService extends GetxService {
  // Dados Reativos Globais
  final dizimistas = <Dizimista>[].obs;
  final contribuicoes = <Contribuicao>[].obs;
  final acessos = <Acesso>[].obs;

  // Estados de Carregamento
  final isSyncing = false.obs;
  final hasError = false.obs;

  // Flags internas para garantir uma única subscrição por fonte
  StreamSubscription? _dizimistasSub;
  StreamSubscription? _contribuicoesSub;
  StreamSubscription? _acessosSub;

  // Controle de primeira carga para parar o loader apenas quando todos responderem
  bool _dizimistasLoaded = false;
  bool _contribuicoesLoaded = false;
  bool _acessosLoaded = false;

  @override
  void onInit() {
    super.onInit();
    final authService = Get.find<AuthService>();

    // Reage ao estado de login globalmente
    ever(authService.userData, (userData) {
      if (userData != null) {
        _startAllStreams();
      } else {
        _stopAllStreams();
      }
    });

    // Caso o usuário já esteja logado no início (Refresh/F5)
    if (authService.userData.value != null) {
      _startAllStreams();
    }
  }

  void _startAllStreams() {
    if (isSyncing.value) return;

    print('[DataRepository] Iniciando sincronização global de dados...');
    isSyncing.value = true;
    hasError.value = false;

    // Resetar flags e subscrições se existirem
    _dizimistasLoaded = false;
    _contribuicoesLoaded = false;
    _acessosLoaded = false;
    _stopAllStreams();

    try {
      // 1. Stream de Dizimistas
      _dizimistasSub = DizimistaService.getAllDizimistas().listen(
        (list) {
          dizimistas.assignAll(list);
          _dizimistasLoaded = true;
          _checkIfAllLoaded();
        },
        onError: (e) => _handleError('Dizimistas', e),
      );

      // 2. Stream de Contribuições
      _contribuicoesSub = ContribuicaoService.getAllContribuicoes().listen(
        (list) {
          contribuicoes.assignAll(list);
          _contribuicoesLoaded = true;
          _checkIfAllLoaded();
        },
        onError: (e) => _handleError('Contribuições', e),
      );

      // 3. Stream de Acessos
      _acessosSub = AccessService.getAllAcessos().listen(
        (list) {
          acessos.assignAll(list);
          _acessosLoaded = true;
          _checkIfAllLoaded();
        },
        onError: (e) => _handleError('Acessos', e),
      );
    } catch (e) {
      _handleError('Setup', e);
    }
  }

  void _checkIfAllLoaded() {
    if (_dizimistasLoaded && _contribuicoesLoaded && _acessosLoaded) {
      if (isSyncing.value) {
        print('[DataRepository] Sincronização inicial concluída.');
        isSyncing.value = false;
      }
    }
  }

  void _handleError(String source, dynamic e) {
    print('[DataRepository] Erro em $source: $e');
    hasError.value = true;
    isSyncing.value = false;
  }

  void _stopAllStreams() {
    print('[DataRepository] Cancelando todas as subscrições.');
    _dizimistasSub?.cancel();
    _contribuicoesSub?.cancel();
    _acessosSub?.cancel();
    _dizimistasSub = null;
    _contribuicoesSub = null;
    _acessosSub = null;

    dizimistas.clear();
    contribuicoes.clear();
    acessos.clear();
    isSyncing.value = false;
  }

  void refreshData() {
    _startAllStreams();
  }

  @override
  void onClose() {
    _stopAllStreams();
    super.onClose();
  }
}
