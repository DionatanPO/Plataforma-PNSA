import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../contribuicoes/models/contribuicao_model.dart';
import '../../dizimistas/models/dizimista_model.dart';
import '../../../domain/models/acesso_model.dart';
import '../../home/controlles/home_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/data_repository_service.dart';

class DashboardController extends GetxController {
  final _dataRepo = Get.find<DataRepositoryService>();

  // Getters para dados brutos
  List<Contribuicao> get _todasContribuicoes => _dataRepo.contribuicoes;
  List<Dizimista> get _todosDizimistas => _dataRepo.dizimistas;
  List<Acesso> get _todosAcessos => _dataRepo.acessos;

  final searchTerms = ''.obs;

  bool get isLoading => _dataRepo.isSyncing.value;

  @override
  void onInit() {
    super.onInit();
    // Dashboard agora apenas observa o repositório central
  }

  // Getters para KPIs Financeiros
  double get arrecadacaoDia {
    final now = DateTime.now();
    return _todasContribuicoes
        .where((c) =>
            c.dataPagamento.year == now.year &&
            c.dataPagamento.month == now.month &&
            c.dataPagamento.day == now.day)
        .fold(0.0, (sum, c) => sum + c.valor);
  }

  double _calculateCompetenceValue(String mesRef) {
    return _todasContribuicoes
        .where((c) => c.mesesCompetencia.contains(mesRef))
        .fold(0.0, (sum, c) {
      if (c.mesesCompetencia.isEmpty) return sum;
      return sum + (c.valor / c.mesesCompetencia.length);
    });
  }

  double _calculateCompetenceValueForYear(int year) {
    double total = 0;
    for (var c in _todasContribuicoes) {
      int countInYear =
          c.mesesCompetencia.where((m) => m.startsWith('$year-')).length;
      if (countInYear > 0 && c.mesesCompetencia.isNotEmpty) {
        total += (c.valor / c.mesesCompetencia.length) * countInYear;
      }
    }
    return total;
  }

  double get arrecadacaoMesAtual {
    final now = DateTime.now();
    final currentMesRef = DateFormat('yyyy-MM').format(now);
    return _calculateCompetenceValue(currentMesRef);
  }

  double get arrecadacaoAno {
    final now = DateTime.now();
    return _calculateCompetenceValueForYear(now.year);
  }

  double get arrecadacaoMesAnterior {
    final now = DateTime.now();
    final firstDayCurrentMonth = DateTime(now.year, now.month, 1);
    final lastMonthDate =
        firstDayCurrentMonth.subtract(const Duration(days: 1));
    final lastMesRef = DateFormat('yyyy-MM').format(lastMonthDate);
    return _calculateCompetenceValue(lastMesRef);
  }

  double get variacaoArrecadacao {
    if (arrecadacaoMesAnterior == 0) return 0.0;
    return ((arrecadacaoMesAtual - arrecadacaoMesAnterior) /
            arrecadacaoMesAnterior) *
        100;
  }

  double get ticketMedio {
    final now = DateTime.now();
    final currentMesRef = DateFormat('yyyy-MM').format(now);
    final contribuicoesMes = _todasContribuicoes
        .where((c) => c.mesesCompetencia.contains(currentMesRef))
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

  // Getters para Contribuições
  int get totalContribuicoes => _todasContribuicoes.length;
  int get contribuicoesPagas =>
      _todasContribuicoes.where((c) => c.status == 'Pago').length;
  int get contribuicoesAReceber =>
      _todasContribuicoes.where((c) => c.status == 'A Receber').length;

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
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

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
                    pw.Text(AppConstants.parishName.toUpperCase(),
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('RECIBO DE CONTRIBUIÇÃO',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 15),
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
                      const pw.TextSpan(
                          text: ' referente a contribuição realizada em '),
                      pw.TextSpan(
                          text: DateFormat('dd/MM/yyyy')
                              .format(contribuicao.dataPagamento),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      const pw.TextSpan(text: '.'),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
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
}
