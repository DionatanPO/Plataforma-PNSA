import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/contribuicao_service.dart';
import '../../../core/services/dizimista_service.dart';
import '../../../core/services/access_service.dart';
import '../../../data/services/auth_service.dart';
import '../../contribuicoes/models/contribuicao_model.dart';
import '../../dizimistas/models/dizimista_model.dart';
import '../../../domain/models/acesso_model.dart';
import '../../home/controlles/home_controller.dart';

class DashboardController extends GetxController {
  // Observáveis para dados brutos
  final RxList<Contribuicao> _todasContribuicoes = <Contribuicao>[].obs;
  final RxList<Dizimista> _todosDizimistas = <Dizimista>[].obs;
  final RxList<Acesso> _todosAcessos = <Acesso>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchTerms = ''.obs;

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

  List<Contribuicao> get filteredContribuicoes {
    if (searchTerms.value.isEmpty) return _todasContribuicoes;
    final term = searchTerms.value.toLowerCase();
    return _todasContribuicoes.where((c) {
      return c.dizimistaNome.toLowerCase().contains(term) ||
          c.tipo.toLowerCase().contains(term) ||
          c.metodo.toLowerCase().contains(term) ||
          getAgentName(c.usuarioId).toLowerCase().contains(term);
    }).toList();
  }

  String getAgentName(String uid) {
    if (uid.isEmpty) return 'Sistema';
    try {
      return _todosAcessos.firstWhere((a) => a.id == uid).nome;
    } catch (_) {
      return 'Usuário Desconhecido';
    }
  }

  String getAgentFunction(String uid) {
    if (uid.isEmpty) return 'Automático';
    try {
      return _todosAcessos.firstWhere((a) => a.id == uid).funcao;
    } catch (_) {
      return 'Agente';
    }
  }

  void goToContribuicoes() {
    final homeController = Get.find<HomeController>();
    // Encontrar o índice da página de Contribuições (index 2 na HomeView)
    homeController.selectedIndex.value = 2;
  }

  String formatCurrency(double value) {
    return NumberFormat.simpleCurrency(locale: 'pt_BR').format(value);
  }

  String formatPercent(double value) {
    return "${value > 0 ? '+' : ''}${value.toStringAsFixed(1)}%";
  }

  Future<void> downloadOrShareReceiptPdf(Contribuicao contribuicao) async {
    try {
      isLoading.value = true;
      final pdf = await _createReceiptPdf(contribuicao);
      final bytes = await pdf.save();
      final fileName =
          'recibo_${contribuicao.dizimistaNome.replaceAll(' ', '_')}_${DateFormat('ddMMyyyy').format(contribuicao.dataRegistro)}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'application/pdf')],
          text: 'Recibo de Contribuição - ${contribuicao.dizimistaNome}',
          subject: 'Recibo - Paróquia Nossa Senhora Auxiliadora',
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
      isLoading.value = false;
    }
  }

  Future<pw.Document> _createReceiptPdf(Contribuicao contribuicao) async {
    final pdf = pw.Document();
    final authService = Get.find<AuthService>();
    final user = authService.currentUser;
    String agentName = user?.displayName ?? 'Usuário do Sistema';

    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    // Logo
    pw.ImageProvider? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/logo.jpg');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      print('Erro ao carregar logo: $e');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5.landscape,
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
                              'PARÓQUIA NOSSA SENHORA AUXILIADORA',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: PdfColors.blue900,
                              ),
                            ),
                            pw.Text(
                              'Endereço da Paróquia, Cidade - UF',
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
                        'RECIBO nº ${contribuicao.id.length > 8 ? contribuicao.id.substring(0, 8).toUpperCase() : "NOVO"}',
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
                        text: contribuicao.tipo.toUpperCase(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      const pw.TextSpan(text: '.'),
                    ],
                  ),
                ),

                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(contribuicao.dataRegistro)}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Forma de Pagamento: ${contribuicao.metodo}',
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
                              bottom: pw.BorderSide(color: PdfColors.black),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          agentName,
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Responsável',
                          style: const pw.TextStyle(fontSize: 8),
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
}
