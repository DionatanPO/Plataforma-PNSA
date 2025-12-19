import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/contribuicao_service.dart';
import '../../../core/services/dizimista_service.dart';
import '../../../core/services/access_service.dart';
import '../../contribuicoes/models/contribuicao_model.dart';
import '../../dizimistas/models/dizimista_model.dart';
import '../../../domain/models/acesso_model.dart';

class DashboardController extends GetxController {
  // Observáveis para dados brutos
  final RxList<Contribuicao> _todasContribuicoes = <Contribuicao>[].obs;
  final RxList<Dizimista> _todosDizimistas = <Dizimista>[].obs;
  final RxList<Acesso> _todosAcessos = <Acesso>[].obs;
  final RxBool isLoading = true.obs;

  // Streams subscripts
  StreamSubscription? _contribuicoesSub;
  StreamSubscription? _dizimistasSub;
  StreamSubscription? _acessosSub;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  @override
  void onClose() {
    _contribuicoesSub?.cancel();
    _dizimistasSub?.cancel();
    _acessosSub?.cancel();
    super.onClose();
  }

  void _startListening() {
    isLoading.value = true;

    _contribuicoesSub =
        ContribuicaoService.getAllContribuicoes().listen((list) {
      _todasContribuicoes.value = list;
      _checkLoading();
    });

    _dizimistasSub = DizimistaService.getAllDizimistas().listen((list) {
      _todosDizimistas.value = list;
      _checkLoading();
    });

    _acessosSub = AccessService.getAllAcessos().listen((list) {
      _todosAcessos.value = list;
      _checkLoading();
    });
  }

  void _checkLoading() {
    if (_todasContribuicoes.isNotEmpty ||
        _todosDizimistas.isNotEmpty ||
        _todosAcessos.isNotEmpty) {
      isLoading.value = false;
    }
    // Note: If collections are empty, it might stay loading forever if we don't handle empty case.
    // However, usually these streams emit even if empty.
  }

  // Getters para KPIs Financeiros
  double get arrecadacaoDia {
    final now = DateTime.now();
    return _todasContribuicoes
        .where((c) =>
            c.dataRegistro.year == now.year &&
            c.dataRegistro.month == now.month &&
            c.dataRegistro.day == now.day)
        .fold(0.0, (sum, c) => sum + c.valor);
  }

  double get arrecadacaoMesAtual {
    final now = DateTime.now();
    return _todasContribuicoes
        .where((c) =>
            c.dataRegistro.year == now.year &&
            c.dataRegistro.month == now.month)
        .fold(0.0, (sum, c) => sum + c.valor);
  }

  double get arrecadacaoAno {
    final now = DateTime.now();
    return _todasContribuicoes
        .where((c) => c.dataRegistro.year == now.year)
        .fold(0.0, (sum, c) => sum + c.valor);
  }

  double get arrecadacaoMesAnterior {
    final now = DateTime.now();
    final firstDayCurrentMonth = DateTime(now.year, now.month, 1);
    final lastDayLastMonth =
        firstDayCurrentMonth.subtract(const Duration(days: 1));
    return _todasContribuicoes
        .where((c) =>
            c.dataRegistro.year == lastDayLastMonth.year &&
            c.dataRegistro.month == lastDayLastMonth.month)
        .fold(0.0, (sum, c) => sum + c.valor);
  }

  double get variacaoArrecadacao {
    if (arrecadacaoMesAnterior == 0) return 0.0;
    return ((arrecadacaoMesAtual - arrecadacaoMesAnterior) /
            arrecadacaoMesAnterior) *
        100;
  }

  double get ticketMedio {
    final now = DateTime.now();
    final contribuicoesMes = _todasContribuicoes
        .where((c) =>
            c.dataRegistro.year == now.year &&
            c.dataRegistro.month == now.month)
        .toList();
    if (contribuicoesMes.isEmpty) return 0.0;
    return arrecadacaoMesAtual / contribuicoesMes.length;
  }

  // Getters para Status de Fiel
  int get totalDizimistas => _todosDizimistas.length;
  int get ativosDizimistas =>
      _todosDizimistas.where((d) => d.status.toLowerCase() == 'ativo').length;
  int get inativosDizimistas =>
      _todosDizimistas.where((d) => d.status.toLowerCase() == 'inativo').length;
  int get afastadosDizimistas => _todosDizimistas
      .where((d) => d.status.toLowerCase() == 'afastado')
      .length;

  int get totalAcessos => _todosAcessos.length;

  List<Contribuicao> get ultimasContribuicoes =>
      _todasContribuicoes.take(5).toList();

  String formatCurrency(double value) {
    return NumberFormat.simpleCurrency(locale: 'pt_BR').format(value);
  }

  String formatPercent(double value) {
    return "${value > 0 ? '+' : ''}${value.toStringAsFixed(1)}%";
  }
}
