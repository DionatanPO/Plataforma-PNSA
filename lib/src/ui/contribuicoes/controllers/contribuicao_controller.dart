import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/contribuicao_model.dart';
import '../../dizimistas/models/dizimista_model.dart';
import '../../../core/services/dizimista_service.dart';
import '../../../core/services/contribuicao_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/data_repository_service.dart';

enum DistribuicaoModo { integral, rateado }

class ContribuicaoController extends GetxController {
  final _dataRepo = Get.find<DataRepositoryService>();

  // Estado privado derivado do repositório
  List<Contribuicao> get _contribuicoes => _dataRepo.contribuicoes;
  List<Dizimista> get _dizimistas => _dataRepo.dizimistas;

  bool get isLoading => _dataRepo.isSyncing.value;
  final _isLoadingMore = false.obs;

  // Filtros e Pesquisa
  final searchQuery = ''.obs;
  final displayedCount = 20.obs;
  final pageSize = 20;
  final hasMore = true.obs;

  // Ordenação
  final sortColumn = 'dataPagamento'.obs;
  final isAscending = false.obs;

  void toggleSort(String column) {
    if (sortColumn.value == column) {
      isAscending.value = !isAscending.value;
    } else {
      sortColumn.value = column;
      isAscending.value = true;
    }
  }

  // Getters públicos
  List<Contribuicao> get contribuicoes => _contribuicoes;
  List<Dizimista> get dizimistas => _dizimistas;
  bool get isLoadingMore => _isLoadingMore.value;

  // Listagem filtrada e paginada
  List<Contribuicao> get filteredContribuicoes {
    List<Contribuicao> listToFilter;

    if (searchQuery.value.isEmpty) {
      listToFilter = List<Contribuicao>.from(_contribuicoes);
    } else {
      final query = _normalize(searchQuery.value);
      listToFilter = _contribuicoes.where((c) {
        return _normalize(c.dizimistaNome).contains(query) ||
            _normalize(c.tipo).contains(query) ||
            _normalize(c.metodo).contains(query) ||
            c.id.toLowerCase().contains(query);
      }).toList();
    }

    return _applySorting(listToFilter);
  }

  List<Contribuicao> _applySorting(List<Contribuicao> list) {
    final col = sortColumn.value;
    final asc = isAscending.value;

    list.sort((a, b) {
      int result = 0;
      switch (col) {
        case 'dataPagamento':
          result = a.dataPagamento.compareTo(b.dataPagamento);
          break;
        case 'dizimistaNome':
          result = _normalize(a.dizimistaNome)
              .compareTo(_normalize(b.dizimistaNome));
          break;
        case 'metodo':
          result = a.metodo.toLowerCase().compareTo(b.metodo.toLowerCase());
          break;
        case 'status':
          result = a.status.toLowerCase().compareTo(b.status.toLowerCase());
          break;
        case 'valor':
          result = a.valor.compareTo(b.valor);
          break;
        case 'mesReferencia':
          // Ordena pelo primeiro mês de competência se existir
          final aMes =
              a.mesesCompetencia.isNotEmpty ? a.mesesCompetencia.first : '';
          final bMes =
              b.mesesCompetencia.isNotEmpty ? b.mesesCompetencia.first : '';
          result = aMes.compareTo(bMes);
          break;
        default:
          result = a.id.compareTo(b.id);
      }
      return asc ? result : -result;
    });

    return list;
  }

  List<Contribuicao> get paginatedContribuicoes {
    final allFiltered = filteredContribuicoes;
    final count = displayedCount.value;

    if (allFiltered.length <= count) {
      return allFiltered;
    }

    return allFiltered.take(count).toList();
  }

  // Removido subscrições redundantes

  // ==================================================================
  // VARIÁVEIS DO FORMULÁRIO
  // ==================================================================

  // Seleção do Dízimista
  final dizimistaSelecionado = Rxn<Dizimista>();

  // Data selecionada (ADICIONADO PARA CORRIGIR O ERRO)
  final dataSelecionada = DateTime.now().obs;

  // Campos simples (Strings)

  final tipo = 'Dízimo Regular'.obs; // Transformar em observável
  final metodo = 'PIX'.obs; // Transformar em observável
  final status = 'Pago'.obs; // ex: 'Pago', 'A Receber'
  final valor = ''.obs; // Transformar em observável
  final observacao = ''.obs;
  final distribuicaoModo = DistribuicaoModo.integral.obs;

  // Lista de competências (mês/ano e valor)
  final competencias = <ContribuicaoCompetencia>[].obs;

  double valorNumerico = 0.0;

  double get totalContribuicao =>
      competencias.fold(0.0, (sum, item) => sum + item.valor);

  // Método para adicionar uma competência
  void adicionarCompetencia(String mesAno, double valor) {
    final list = List<ContribuicaoCompetencia>.from(competencias);
    list.removeWhere((c) => c.mesReferencia == mesAno);
    list.add(ContribuicaoCompetencia(
        mesReferencia: mesAno,
        valor: valor,
        dataPagamento: dataSelecionada.value));
    list.sort((a, b) => a.mesReferencia.compareTo(b.mesReferencia));

    competencias.assignAll(list);
    atribuirValorEntreCompetencias();
  }

  // Método para atualizar a data de uma competência específica
  void atualizarDataCompetencia(String mesAno, DateTime novaData) {
    final index = competencias.indexWhere((c) => c.mesReferencia == mesAno);
    if (index != -1) {
      final compExistente = competencias[index];
      competencias[index] = ContribuicaoCompetencia(
        mesReferencia: compExistente.mesReferencia,
        valor: compExistente.valor,
        dataPagamento: novaData,
      );
      // Sincroniza a data principal do lançamento
      dataSelecionada.value = novaData;
    }
  }

  // Método para remover uma competência
  void removerCompetencia(String mesAno) {
    competencias.removeWhere((c) => c.mesReferencia == mesAno);

    // Recalcular se houver valor
    if (valor.value.isNotEmpty) {
      atribuirValorEntreCompetencias();
    }
  }

  // Método para limpar competências
  void limparCompetencias() {
    competencias.clear();
  }

  // Método para atualizar o valor de uma competência específica
  void atualizarValorCompetencia(String mesAno, double novoValor) {
    final index = competencias.indexWhere((c) => c.mesReferencia == mesAno);
    if (index != -1) {
      final comp = competencias[index];
      competencias[index] = ContribuicaoCompetencia(
          mesReferencia: comp.mesReferencia,
          valor: novoValor,
          dataPagamento: comp.dataPagamento);
    }
    // Opcional: Atualizar o valor "macro" se todos forem iguais?
    // Por enquanto não vamos mexer no valor.value para não causar loops ou confusão
  }

  // Método para aplicar o valor informado em cada uma das competências selecionadas
  void atribuirValorEntreCompetencias() {
    if (competencias.isEmpty) return;

    String valorLimpo = valor.value
        .replaceAll('.', '')
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.');

    double valorInformado = double.tryParse(valorLimpo) ?? 0.0;
    if (valorInformado <= 0) return;

    // Decide o valor por mês baseado no modo
    double valorPorMes = valorInformado;
    if (distribuicaoModo.value == DistribuicaoModo.rateado) {
      valorPorMes = valorInformado / competencias.length;
    }

    // Atualizar a lista mantendo a ordem mas com novos valores e mantendo as datas se existirem
    final novosDados = competencias
        .map((c) => {
              'mes': c.mesReferencia,
              'data': c.dataPagamento ?? dataSelecionada.value
            })
        .toList();

    final novasComps = novosDados
        .map((item) => ContribuicaoCompetencia(
              mesReferencia: item['mes'] as String,
              valor: valorPorMes,
              dataPagamento: item['data'] as DateTime,
            ))
        .toList();

    competencias.assignAll(novasComps);
  }

  @override
  void onInit() {
    super.onInit();
    // Contribuição agora é passiva e observa o repositório central

    // Recalcular atribuição quando o valor mudar ou o modo de distribuição mudar
    ever(valor, (_) => atribuirValorEntreCompetencias());
    ever(distribuicaoModo, (_) => atribuirValorEntreCompetencias());

    // Gerenciar competências e categorização automática
    ever<String>(tipo, (novoTipo) {
      // Se não for dízimo, garante que competências fiquem limpas
      if (!novoTipo.startsWith('Dízimo')) {
        if (competencias.isNotEmpty) {
          competencias.clear();
        }
      }
    });

    // Categorizar automaticamente o sub-tipo de dízimo quando as competências mudarem
    ever(competencias, (_) {
      // Só auto-categoriza se já for um tipo de Dízimo ou estiver vazio
      if (tipo.value.isEmpty || tipo.value.startsWith('Dízimo')) {
        final novoSubTipo = _calcularTipoDizimoAutomatico();
        if (tipo.value != novoSubTipo) {
          tipo.value = novoSubTipo;
        }
      }
    });

    // Workers para listagem
    ever(searchQuery, (_) => resetPagination());

    void updateHasMore(_) {
      final allFiltered = filteredContribuicoes;
      hasMore.value = allFiltered.length > displayedCount.value;
    }

    ever(_dataRepo.contribuicoes, updateHasMore);
    ever(displayedCount, updateHasMore);
    ever(searchQuery, updateHasMore);

    print('[ContribuicaoController] onInit: Check initial state...');
  }

  @override
  void onReady() {
    super.onReady();
  }

  String _calcularTipoDizimoAutomatico() {
    if (competencias.isEmpty) return 'Dízimo';

    final now = DateTime.now();
    final currentMesRef = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    bool temAnterior = false;
    bool temAtual = false;
    bool temFuturo = false;

    for (var comp in competencias) {
      if (comp.mesReferencia == currentMesRef) {
        temAtual = true;
      } else if (comp.mesReferencia.compareTo(currentMesRef) < 0) {
        temAnterior = true;
      } else {
        temFuturo = true;
      }
    }

    if (temAnterior && !temAtual && !temFuturo) return 'Dízimo Atrasado';
    if (temFuturo && !temAtual && !temAnterior) return 'Dízimo Antecipado';
    if (temAtual && !temAnterior && !temFuturo) return 'Dízimo Regular';

    return 'Dízimo';
  }

  void loadMore() async {
    if (_isLoadingMore.value || !hasMore.value) return;

    _isLoadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    displayedCount.value += pageSize;
    _isLoadingMore.value = false;
  }

  void resetPagination() {
    displayedCount.value = pageSize;
  }

  void _startListening() {
    // Agora gerenciado pelo DataRepositoryService
  }

  void _stopListening() {
    // Agora gerenciado pelo DataRepositoryService
  }

  @override
  void onClose() {
    _stopListening();
    super.onClose();
  }

  void adicionarVariasCompetencias(Map<String, DateTime> mesesComDatas) {
    // Mantém os valores se já existirem, ou adiciona novos com 0 e a data fornecida
    final novos = <ContribuicaoCompetencia>[];

    mesesComDatas.forEach((mes, data) {
      final existente =
          competencias.firstWhereOrNull((c) => c.mesReferencia == mes);
      novos.add(ContribuicaoCompetencia(
          mesReferencia: mes,
          valor: existente?.valor ?? 0,
          dataPagamento: data));
    });

    competencias.assignAll(novos);
    competencias.sort((a, b) => a.mesReferencia.compareTo(b.mesReferencia));

    // Atualiza a data principal do lançamento com a data da primeira competência selecionada
    if (competencias.isNotEmpty && competencias.first.dataPagamento != null) {
      dataSelecionada.value = competencias.first.dataPagamento!;
    }

    atribuirValorEntreCompetencias();
  }

  void _sugerirMesAtual() {
    final now = DateTime.now();
    final mesRef = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    competencias.clear();
    adicionarCompetencia(mesRef, 0);
    atribuirValorEntreCompetencias();
  }

  void resetForm() {
    dizimistaSelecionado.value = null;
    dataSelecionada.value = DateTime.now();
    valor.value = '';
    observacao.value = '';
    tipo.value = 'Dízimo Regular';
    metodo.value = 'PIX';
    status.value = 'Pago';
    distribuicaoModo.value = DistribuicaoModo.integral;
    competencias.clear();
  }

  Future<void> fetchContribuicoes() async {
    _dataRepo.refreshData();
  }

  Future<void> fetchDizimistas() async {
    _dataRepo.refreshData();
  }

  Future<Contribuicao> addContribuicao(Contribuicao contribuicao) async {
    _dataRepo.isSyncing.value = true;
    try {
      final docId = await ContribuicaoService.addContribuicao(contribuicao);
      final contribuicaoComId = contribuicao.copyWith(id: docId);
      return contribuicaoComId;
    } catch (e) {
      print("Erro ao adicionar contribuição no Firestore: $e");
      rethrow;
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  // Novo método para adicionar várias contribuições de uma vez
  Future<List<Contribuicao>> addContribuicoes(
      List<Contribuicao> listContribuicoes) async {
    _dataRepo.isSyncing.value = true;
    final List<Contribuicao> salvas = [];
    try {
      for (var c in listContribuicoes) {
        final docId = await ContribuicaoService.addContribuicao(c);
        salvas.add(c.copyWith(id: docId));
      }
      return salvas;
    } catch (e) {
      print("Erro ao adicionar lote de contribuições: $e");
      rethrow;
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  Future<void> deleteContribuicao(String id) async {
    try {
      _dataRepo.isSyncing.value = true;
      await ContribuicaoService.deleteContribuicao(id);
      Get.snackbar(
        'Sucesso',
        'Lançamento de dízimo removido com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Erro ao excluir contribuição: $e");
      Get.snackbar(
        'Erro',
        'Não foi possível excluir o lançamento.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  Future<void> toggleStatus(Contribuicao c) async {
    try {
      _dataRepo.isSyncing.value = true;
      final newStatus = c.status == 'Pago' ? 'A Receber' : 'Pago';
      final updated = c.copyWith(status: newStatus);

      await ContribuicaoService.updateContribuicao(updated);

      Get.snackbar(
        'Status Atualizado',
        'O dízimo agora está marcado como $newStatus.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: newStatus == 'Pago' ? Colors.green : Colors.orange,
        colorText: Colors.white,
        icon: Icon(
          newStatus == 'Pago' ? Icons.check_circle : Icons.pending,
          color: Colors.white,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  List<Contribuicao> getUltimosLancamentos() {
    // Ordena por data (mais recente primeiro) e pega os 5 primeiros
    final sorted = _contribuicoes.toList()
      ..sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
    return sorted.take(5).toList();
  }

  String formatarMoeda(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}";
  }

  List<Dizimista> searchDizimistas(String query) {
    if (query.isEmpty) return _dizimistas;

    final queryNorm = _normalize(query);

    return _dizimistas.where((dizimista) {
      final nomeNorm = _normalize(dizimista.nome);
      final cpf = dizimista.cpf.replaceAll(RegExp(r'[^0-9]'), '');
      final queryNumbers = queryNorm.replaceAll(RegExp(r'[^0-9]'), '');

      return nomeNorm.contains(queryNorm) ||
          dizimista.numeroRegistro.contains(query) ||
          (queryNumbers.isNotEmpty && cpf.contains(queryNumbers)) ||
          dizimista.telefone.contains(query);
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

  // Método para obter os dados de um dizimista pelo ID direto do repositório
  Dizimista? getDizimistaById(String id) {
    try {
      return _dataRepo.dizimistas.firstWhere(
        (dizimista) => dizimista.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Validações
  bool validateForm() {
    if (dizimistaSelecionado.value == null) {
      _showValidationError('Campo Obrigatório', 'Selecione um dízimista.');
      return false;
    }

    if (valor.value.isEmpty) {
      _showValidationError(
          'Campo Obrigatório', 'Informe o valor da contribuição.');
      return false;
    }

    // Limpa o valor formatado para validação numérica
    String valorLimpo = valor.value
        .replaceAll('.', '') // Remove separador de milhar
        .replaceAll('R\$', '') // Remove simbolo
        .replaceAll(' ', '') // Remove espaços
        .replaceAll(',', '.'); // Troca vírgula por ponto

    final valorDouble = double.tryParse(valorLimpo);
    if (valorDouble == null || valorDouble <= 0) {
      _showValidationError(
          'Valor Inválido', 'O valor da contribuição deve ser maior que zero.');
      return false;
    }

    // Verificar se o método de pagamento foi selecionado
    if (metodo.value.isEmpty) {
      _showValidationError(
          'Campo Obrigatório', 'Selecione o método de pagamento.');
      return false;
    }

    return true;
  }

  void _showValidationError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      borderRadius: 12,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
    );
  }

  String _formatMesReferencia(String mesRef) {
    // 2024-03 -> Março/2024
    final parts = mesRef.split('-');
    if (parts.length != 2) return mesRef;

    final year = parts[0];
    final month = int.tryParse(parts[1]) ?? 1;

    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];

    return '${months[month - 1]}/$year';
  }

  // ==================================================================
  // GERAÇÃO DE RECIBO PDF
  // ==================================================================

  Future<void> downloadOrShareReceiptPdf(Contribuicao contribuicao) async {
    try {
      _dataRepo.isSyncing.value = true;
      final pdf = await _createReceiptPdf(contribuicao);
      final bytes = await pdf.save();
      final fileName =
          'recibo_${contribuicao.dizimistaNome.replaceAll(' ', '_')}_${DateFormat('ddMMyyyy').format(contribuicao.dataRegistro)}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else if (!kIsWeb && Platform.isWindows) {
        await _showWindowsExportDialog(
            bytes, fileName, 'Recibo de ${contribuicao.dizimistaNome}');
      } else {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'application/pdf')],
          text: 'Recibo de Contribuição - ${contribuicao.dizimistaNome}',
          subject: 'Recibo - ${AppConstants.parishName}',
        );

        Future.delayed(const Duration(seconds: 10), () {
          if (file.existsSync()) {
            file.deleteSync();
          }
        });
      }
    } catch (e) {
      print('Erro ao processar recibo: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível processar o recibo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _dataRepo.isSyncing.value = false;
    }
  }

  Future<pw.Document> _createReceiptPdf(Contribuicao contribuicao) async {
    final pdf = pw.Document();
    final authService = Get.find<AuthService>();
    final user = authService.currentUser;
    String agentName = user?.displayName ?? 'Usuário do Sistema';

    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    // Fontes
    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    // Logo (opcional)
    pw.ImageProvider? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/logo.jpg');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      print('Erro ao carregar logo: $e');
    }

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        pageFormat: PdfPageFormat.a5.landscape, // Recibos costumam ser menores
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 2),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        if (logoImage != null)
                          pw.Container(
                            width: 50,
                            height: 50,
                            margin: const pw.EdgeInsets.only(right: 15),
                            child: pw.Image(logoImage),
                          ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              AppConstants.parishName.toUpperCase(),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: PdfColors.blue900,
                              ),
                            ),
                            pw.Text(
                              'CNPJ: ${AppConstants.parishCnpj}',
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.Text(
                              '${AppConstants.parishAddress} | ${AppConstants.parishPhone}',
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Text(
                        'RECIBO nº ${contribuicao.id.substring(0, 8).toUpperCase()}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 20),

                // Content
                pw.RichText(
                  text: pw.TextSpan(
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.black,
                    ),
                    children: [
                      const pw.TextSpan(text: 'Recebemos de '),
                      pw.TextSpan(
                        text: contribuicao.dizimistaNome.toUpperCase(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      const pw.TextSpan(text: ' a importância de '),
                      pw.TextSpan(
                        text: currency.format(contribuicao.valor),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      pw.TextSpan(text: ' referente a '),
                      pw.TextSpan(
                        text: contribuicao.tipo.startsWith('Dízimo')
                            ? 'DÍZIMO'
                            : contribuicao.tipo.toUpperCase(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      if (contribuicao.competencias.isNotEmpty) ...[
                        const pw.TextSpan(text: ' ('),
                        pw.TextSpan(
                          text: contribuicao.competencias.map((c) {
                            final mes = _formatMesReferencia(c.mesReferencia);
                            if (c.dataPagamento != null) {
                              final data = DateFormat('dd/MM/yy')
                                  .format(c.dataPagamento!);
                              return '$mes ($data)';
                            }
                            return mes;
                          }).join(', '),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        const pw.TextSpan(text: ')'),
                      ],
                      const pw.TextSpan(text: '.'),
                    ],
                  ),
                ),

                if (contribuicao.observacao != null &&
                    contribuicao.observacao!.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 8),
                    child: pw.Text(
                      'Obs: ${contribuicao.observacao}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),

                pw.SizedBox(height: 15),
                pw.Row(
                  children: [
                    pw.Text(
                      'Forma de Pagamento: ',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      contribuicao.metodo,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                // Footer e Assinatura Eletrônica
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.blue100),
                            borderRadius: pw.BorderRadius.circular(4),
                            color: PdfColors.blue50,
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'ASSINATURA ELETRÔNICA',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 7,
                                  color: PdfColors.blue800,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                '${AppConstants.pdfAuthBy}: $agentName',
                                style: const pw.TextStyle(fontSize: 6),
                              ),
                              pw.Text(
                                '${AppConstants.pdfValidatedVia} ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                                style: const pw.TextStyle(fontSize: 6),
                              ),
                              pw.Text(
                                '${AppConstants.pdfVerificacaoCode}: ${contribuicao.id.hashCode.toRadixString(16).toUpperCase()}',
                                style: const pw.TextStyle(fontSize: 6),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Data: ${DateFormat('dd/MM/yyyy').format(contribuicao.dataRegistro)}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 150,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                color: PdfColors.black,
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Assinatura / Carimbo',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  List<Contribuicao> createContribuicoesFromFormSplit() {
    final dizimista = dizimistaSelecionado.value!;
    final user = Get.find<AuthService>().currentUser;
    final now = DateTime.now();

    return competencias.map((comp) {
      final baseDate = comp.dataPagamento ?? dataSelecionada.value;
      // Combina a data selecionada com a hora atual do sistema
      final dataComHora = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        now.hour,
        now.minute,
        now.second,
      );

      return Contribuicao(
        id: '',
        dizimistaId: dizimista.id,
        dizimistaNome: dizimista.nome,
        tipo: tipo.value,
        valor: comp.valor,
        metodo: metodo.value,
        dataRegistro: now, // Auditoria: quando foi digitado
        dataPagamento: dataComHora, // Contábil: quando foi pago
        status: status.value,
        usuarioId: user?.uid ?? '',
        observacao: observacao.value.isEmpty ? null : observacao.value,
        competencias: [comp],
        mesesCompetencia: [comp.mesReferencia],
      );
    }).toList();
  }

  // Criar uma única contribuição agregada (usado para o recibo consolidado)
  Contribuicao createContribuicaoFromForm() {
    final dizimista = dizimistaSelecionado.value!;
    final user = Get.find<AuthService>().currentUser;

    // O valor total da contribuição agora é a soma de todas as competências
    final valorTotalCalculado =
        competencias.fold(0.0, (sum, item) => sum + item.valor);

    final now = DateTime.now();
    final baseDate = dataSelecionada.value;
    final dataComHora = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    return Contribuicao(
      id: '', // O ID será definido pelo Firestore
      dizimistaId: dizimista.id,
      dizimistaNome: dizimista.nome,
      tipo: tipo.value,
      valor: valorTotalCalculado,
      metodo: metodo.value,
      dataRegistro: now, // Auditoria: quando foi digitado
      dataPagamento: dataComHora, // Contábil: quando foi pago
      status: status.value,
      usuarioId: user?.uid ?? '',
      observacao: observacao.value.isEmpty ? null : observacao.value,
      competencias: List<ContribuicaoCompetencia>.from(competencias),
      mesesCompetencia: competencias.map((c) => c.mesReferencia).toList(),
    );
  }

  Future<void> _showWindowsExportDialog(
      Uint8List bytes, String fileName, String subject) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Exportar PDF'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Arquivo: $fileName'),
            const SizedBox(height: 16),
            const Text('Escolha como deseja prosseguir:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              // Abre a prévia de impressão que permite "Salvar como PDF" em qualquer lugar
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => bytes,
                name: fileName,
              );
            },
            child: const Text('Imprimir / Salvar Como...'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final downloadsDir = await getDownloadsDirectory();
              if (downloadsDir != null) {
                final filePath = '${downloadsDir.path}/$fileName';
                final file = File(filePath);
                await file.writeAsBytes(bytes);
                Get.snackbar(
                  'Sucesso',
                  'Arquivo salvo em Downloads: $fileName',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 5),
                  mainButton: TextButton(
                    onPressed: () => launchUrl(Uri.file(downloadsDir.path)),
                    child: const Text('Abrir Pasta',
                        style: TextStyle(color: Colors.white)),
                  ),
                );
              }
            },
            child: const Text('Salvar em Downloads'),
          ),
        ],
      ),
    );
  }

  String _normalize(String text) {
    if (text.isEmpty) return '';
    var s = text.toLowerCase();
    s = s.replaceAll(RegExp(r'[áàâãä]'), 'a');
    s = s.replaceAll(RegExp(r'[éèêë]'), 'e');
    s = s.replaceAll(RegExp(r'[íìîï]'), 'i');
    s = s.replaceAll(RegExp(r'[óòôõö]'), 'o');
    s = s.replaceAll(RegExp(r'[úùûü]'), 'u');
    s = s.replaceAll(RegExp(r'[ç]'), 'c');
    return s.trim();
  }
}
