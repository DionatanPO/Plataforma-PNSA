import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/data_repository_service.dart';
import '../../../core/services/contribuicao_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../contribuicoes/models/contribuicao_model.dart';
import '../../../domain/models/acesso_model.dart';

class ReportController extends GetxController {
  final _dataRepo = Get.find<DataRepositoryService>();

  final RxList<Contribuicao> contribuicoes = <Contribuicao>[].obs;
  final RxDouble totalArrecadado = 0.0.obs;
  final RxDouble totalDizimos = 0.0.obs;
  final RxDouble totalOfertas = 0.0.obs;
  final RxDouble totalOutros = 0.0.obs;

  final RxDouble totalPix = 0.0.obs;
  final RxDouble totalDinheiro = 0.0.obs;
  final RxDouble totalCartao = 0.0.obs;
  final RxDouble totalTransferencia = 0.0.obs;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTimeRange> selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  ).obs;

  final RxBool isRangeMode = false.obs;
  final RxBool isCompetenceMode = false.obs;
  final RxString selectedCompetenceMonth =
      DateFormat('yyyy-MM').format(DateTime.now()).obs;

  final RxBool _isLocalLoading = false.obs;
  bool get isLoading => _isLocalLoading.value || _dataRepo.isSyncing.value;

  StreamSubscription? _reportSub;
  List<Acesso> get _todosAcessos => _dataRepo.acessos;

  @override
  void onInit() {
    super.onInit();

    // Listen to changes to refetch
    ever(selectedDate, (date) {
      if (!isRangeMode.value && !isCompetenceMode.value) fetchDailyReport(date);
    });

    ever(selectedRange, (range) {
      if (isRangeMode.value) fetchPeriodReport(range);
    });

    ever(selectedCompetenceMonth, (month) {
      if (isCompetenceMode.value) fetchCompetenceReport(month);
    });

    ever(isRangeMode, (mode) {
      if (mode) {
        fetchPeriodReport(selectedRange.value);
      } else if (!isCompetenceMode.value) {
        fetchDailyReport(selectedDate.value);
      }
    });

    ever(isCompetenceMode, (mode) {
      if (mode) {
        fetchCompetenceReport(selectedCompetenceMonth.value);
      } else if (isRangeMode.value) {
        fetchPeriodReport(selectedRange.value);
      } else {
        fetchDailyReport(selectedDate.value);
      }
    });

    // Initial fetch
    _fetchAllInitially();
  }

  void _fetchAllInitially() {
    if (isCompetenceMode.value) {
      fetchCompetenceReport(selectedCompetenceMonth.value);
    } else if (isRangeMode.value) {
      fetchPeriodReport(selectedRange.value);
    } else {
      fetchDailyReport(selectedDate.value);
    }
  }

  @override
  void onClose() {
    _reportSub?.cancel();
    super.onClose();
  }

  void updateDate(DateTime date) {
    isRangeMode.value = false;
    isCompetenceMode.value = false;
    selectedDate.value = date;
  }

  void updateRange(DateTimeRange range) {
    isRangeMode.value = true;
    isCompetenceMode.value = false;
    selectedRange.value = range;
  }

  void updateCompetence(String monthPath) {
    isCompetenceMode.value = true;
    isRangeMode.value = false;
    selectedCompetenceMonth.value = monthPath;
  }

  void fetchDailyReport(DateTime date) {
    _isLocalLoading.value = true;
    _reportSub?.cancel();

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final stream = ContribuicaoService.getContribuicoesByDate(dateStr);

    _reportSub = stream.listen((lista) {
      contribuicoes.assignAll(lista);
      _calculateTotals(lista);
      _isLocalLoading.value = false;
    }, onError: (e) {
      _isLocalLoading.value = false;
      Get.snackbar('Erro', 'Erro ao carregar relatório diário: $e');
    });
  }

  void fetchPeriodReport(DateTimeRange range) {
    _isLocalLoading.value = true;
    _reportSub?.cancel();

    final stream =
        ContribuicaoService.getContribuicoesByPeriod(range.start, range.end);

    _reportSub = stream.listen((lista) {
      contribuicoes.assignAll(lista);
      _calculateTotals(lista);
      _isLocalLoading.value = false;
    }, onError: (e) {
      _isLocalLoading.value = false;
      Get.snackbar('Erro', 'Erro ao carregar relatório por período: $e');
    });
  }

  void fetchCompetenceReport(String monthPath) {
    _isLocalLoading.value = true;
    _reportSub?.cancel();

    final stream = ContribuicaoService.getContribuicoesByCompetence(monthPath);

    _reportSub = stream.listen((lista) {
      contribuicoes.assignAll(lista);
      _calculateTotals(lista);
      _isLocalLoading.value = false;
    }, onError: (e) {
      _isLocalLoading.value = false;
      Get.snackbar('Erro', 'Erro ao carregar relatório por competência: $e');
    });
  }

  void _calculateTotals(List<Contribuicao> lista) {
    double total = 0, dizimos = 0, ofertas = 0, outros = 0;
    double pix = 0, dinheiro = 0, cartao = 0, transferencia = 0;

    for (var c in lista) {
      double valor = c.valor;
      // Se for modo competência, o valor é dividido pelos meses
      if (isCompetenceMode.value && c.mesesCompetencia.length > 1) {
        valor = c.valor / c.mesesCompetencia.length;
      }

      total += valor;
      if (c.tipo.toLowerCase().contains('dízimo') ||
          c.tipo.toLowerCase().contains('dizimo')) {
        dizimos += valor;
      } else if (c.tipo.toLowerCase().contains('oferta')) {
        ofertas += valor;
      } else {
        outros += valor;
      }

      switch (c.metodo.toLowerCase()) {
        case 'pix':
          pix += valor;
          break;
        case 'dinheiro':
          dinheiro += valor;
          break;
        case 'cartão':
        case 'cartao':
          cartao += valor;
          break;
        case 'transferência':
        case 'transferencia':
          transferencia += valor;
          break;
      }
    }

    totalArrecadado.value = total;
    totalDizimos.value = dizimos;
    totalOfertas.value = ofertas;
    totalOutros.value = outros;

    totalPix.value = pix;
    totalDinheiro.value = dinheiro;
    totalCartao.value = cartao;
    totalTransferencia.value = transferencia;
  }

  Future<void> generateDailyReportPdf() async {
    await downloadOrShareDailyReportPdf();
  }

  Future<void> downloadOrShareDailyReportPdf() async {
    try {
      _isLocalLoading.value = true;
      final pdf = await _createPdfDocument();
      final bytes = await pdf.save();
      final fileName =
          'Relatorio_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else if (Platform.isWindows) {
        await _showWindowsExportDialog(bytes, fileName);
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Relatório Financeiro');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao gerar PDF: $e');
    } finally {
      _isLocalLoading.value = false;
    }
  }

  Future<void> downloadOrShareReceiptPdf(Contribuicao contribuicao) async {
    try {
      _isLocalLoading.value = true;
      final agentName = getAgentName(contribuicao.usuarioId);
      final pdf = await _createReceiptPdf(contribuicao, agentName);
      final bytes = await pdf.save();
      final fileName =
          'Recibo_${contribuicao.dizimistaNome.replaceAll(' ', '_')}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else if (Platform.isWindows) {
        await _showWindowsExportDialog(bytes, fileName);
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Recibo de Contribuição');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao gerar recibo: $e');
    } finally {
      _isLocalLoading.value = false;
    }
  }

  Future<void> _showWindowsExportDialog(
      Uint8List bytes, String fileName) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Exportar PDF'),
        content: const Text('Escolha como deseja salvar o relatório.'),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              final dir = await getDownloadsDirectory();
              if (dir != null) {
                final file = File('${dir.path}/$fileName');
                await file.writeAsBytes(bytes);
                Get.snackbar('Sucesso', 'Arquivo salvo em Downloads');
              }
            },
            child: const Text('Salvar em Downloads'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await Printing.sharePdf(bytes: bytes, filename: fileName);
            },
            child: const Text('Compartilhar/Imprimir'),
          ),
        ],
      ),
    );
  }

  Future<pw.Document> _createPdfDocument() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final String periodLabel = isCompetenceMode.value
        ? 'Competência: ${selectedCompetenceMonth.value}'
        : (isRangeMode.value
            ? 'Período: ${DateFormat('dd/MM/yyyy').format(selectedRange.value.start)} a ${DateFormat('dd/MM/yyyy').format(selectedRange.value.end)}'
            : 'Data: ${DateFormat('dd/MM/yyyy').format(selectedDate.value)}');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (pw.Context context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(AppConstants.parishName.toUpperCase(),
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Relatório Financeiro',
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(periodLabel,
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        'Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 20),
          ],
        ),
        build: (pw.Context context) {
          return [
            // Resumo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildModernStatRow('Total Arrecadado',
                    currency.format(totalArrecadado.value), PdfColors.green900),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildModernStatRow('Dízimos',
                    currency.format(totalDizimos.value), PdfColors.blue900),
                _buildModernStatRow('Ofertas',
                    currency.format(totalOfertas.value), PdfColors.orange900),
                _buildModernStatRow('Outros',
                    currency.format(totalOutros.value), PdfColors.grey700),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Text('Métodos de Pagamento',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildModernSubStat('PIX', currency.format(totalPix.value)),
                _buildModernSubStat(
                    'Dinheiro', currency.format(totalDinheiro.value)),
                _buildModernSubStat(
                    'Cartão', currency.format(totalCartao.value)),
                _buildModernSubStat(
                    'Transf.', currency.format(totalTransferencia.value)),
              ],
            ),
            pw.SizedBox(height: 40),
            pw.Table.fromTextArray(
              headers: ['Nome', 'Pagamento', 'Método', 'Status', 'Valor'],
              data: contribuicoes.map((c) {
                double valorCalculado = c.valor;
                if (isCompetenceMode.value && c.mesesCompetencia.length > 1) {
                  valorCalculado = c.valor / c.mesesCompetencia.length;
                }
                return [
                  c.dizimistaNome,
                  DateFormat('dd/MM/yyyy').format(c.dataPagamento),
                  c.metodo,
                  c.status,
                  currency.format(valorCalculado)
                ];
              }).toList(),
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey100),
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
              },
            ),
          ];
        },
      ),
    );
    return pdf;
  }

  pw.Widget _buildModernStatRow(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  pw.Widget _buildModernSubStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  Future<pw.Document> _createReceiptPdf(
      Contribuicao contribuicao, String agentName) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(10)),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
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
                pw.Divider(),
                pw.SizedBox(height: 15),
                pw.RichText(
                  text: pw.TextSpan(
                      style: const pw.TextStyle(fontSize: 12),
                      children: [
                        const pw.TextSpan(text: 'Recebemos de '),
                        pw.TextSpan(
                            text: contribuicao.dizimistaNome.toUpperCase(),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        const pw.TextSpan(text: ' a importância de '),
                        pw.TextSpan(
                            text: currency.format(contribuicao.valor),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        const pw.TextSpan(
                            text: ' referente a contribuição realizada em '),
                        pw.TextSpan(
                            text: DateFormat('dd/MM/yyyy')
                                .format(contribuicao.dataPagamento),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        const pw.TextSpan(text: '.'),
                      ]),
                ),
                pw.Spacer(),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                          border:
                              pw.Border(bottom: pw.BorderSide(width: 0.5)))),
                ]),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 150,
                      child: pw.Center(
                        child: pw.Text('Assinatura / Carimbo',
                            style: const pw.TextStyle(fontSize: 8)),
                      ),
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

  String getAgentName(String uid) {
    if (uid.isEmpty) return 'Sistema';
    try {
      final agent = _todosAcessos.firstWhereOrNull((a) => a.id == uid);
      return agent?.nome ?? 'Usuário Desconhecido';
    } catch (_) {
      return 'Usuário Desconhecido';
    }
  }
}
