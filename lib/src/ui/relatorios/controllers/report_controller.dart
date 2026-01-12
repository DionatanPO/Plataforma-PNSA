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
import '../../dizimistas/models/dizimista_model.dart';
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

  Future<void> downloadOrShareDizimistaHistoryPdf(
      Dizimista dizimista, List<Contribuicao> history) async {
    try {
      _isLocalLoading.value = true;
      final pdf = await _createDizimistaHistoryPdf(dizimista, history);
      final bytes = await pdf.save();
      final fileName = 'Historico_${dizimista.nome.replaceAll(' ', '_')}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else if (Platform.isWindows) {
        await _showWindowsExportDialog(bytes, fileName);
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Histórico de Contribuições - ${dizimista.nome}');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao gerar histórico: $e');
    } finally {
      _isLocalLoading.value = false;
    }
  }

  Future<pw.Document> _createDizimistaHistoryPdf(
      Dizimista dizimista, List<Contribuicao> history) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    // Calculate totals for this specific history
    double total = 0;
    int count = 0;
    for (var c in history) {
      if (c.status == 'Pago') {
        total += c.valor;
        count++;
      }
    }

    // Colors
    final primaryColor = PdfColors.blue900;
    final accentColor = PdfColors.blue50;
    final textColor = PdfColors.grey900;
    final mutedColor = PdfColors.grey600;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (pw.Context context) => pw.Column(
          children: [
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 0),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 1),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        AppConstants.parishName.toUpperCase(),
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Extrato de Contribuições'.toUpperCase(),
                        style: pw.TextStyle(
                          color: mutedColor,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Emitido em',
                        style: pw.TextStyle(color: mutedColor, fontSize: 8),
                      ),
                      pw.Text(
                        DateFormat('dd/MM/yyyy • HH:mm').format(DateTime.now()),
                        style: pw.TextStyle(color: textColor, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
          ],
        ),
        build: (pw.Context context) {
          return [
            // Header do Dizimista (Card Moderno)
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: pw.BorderRadius.circular(8),
                border:
                    pw.Border.all(color: primaryColor.flatten(), width: 0.5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'DIZIMISTA',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        dizimista.nome.toUpperCase(),
                        style: pw.TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        dizimista.numeroRegistro.isNotEmpty
                            ? 'Reg: ${dizimista.numeroRegistro}'
                            : 'Sem registro',
                        style: pw.TextStyle(color: mutedColor, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Container(
                    width: 1,
                    height: 40,
                    color: PdfColors.grey300,
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PERÍODO',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Geral (Histórico)',
                        style: pw.TextStyle(color: textColor, fontSize: 12),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(children: [
                        pw.Text(
                          '$count contribuições',
                          style: pw.TextStyle(color: mutedColor, fontSize: 10),
                        ),
                      ])
                    ],
                  ),
                  pw.Container(
                    width: 1,
                    height: 40,
                    color: PdfColors.grey300,
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'TOTAL ACUMULADO',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        currency.format(total),
                        style: pw.TextStyle(
                          color: PdfColors.green800,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Título Tabela
            pw.Text(
              'Detalhamento das Contribuições',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: textColor,
              ),
            ),
            pw.SizedBox(height: 10),

            // Tabela
            pw.Table.fromTextArray(
              headers: ['Data', 'Competência', 'Método', 'Valor'],
              data: history.map((c) {
                final dateStr =
                    DateFormat('dd/MM/yyyy').format(c.dataPagamento);
                final compStr = c.competencias.isNotEmpty
                    ? c.competencias
                        .map((k) => _formatMesReferencia(k.mesReferencia))
                        .join(', ')
                    : (c.mesesCompetencia.isNotEmpty
                        ? c.mesesCompetencia
                            .map((m) => _formatMesReferencia(m))
                            .join(', ')
                        : '-');

                return [dateStr, compStr, c.metodo, currency.format(c.valor)];
              }).toList(),
              headerStyle: pw.TextStyle(
                color: primaryColor,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey50,
                border:
                    pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
              ),
              rowDecoration: const pw.BoxDecoration(
                border:
                    pw.Border(bottom: pw.BorderSide(color: PdfColors.grey100)),
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey800,
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
            ),

            // Footer (Total na base da tabela)
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total deste relatório: ',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600),
                ),
                pw.Text(
                  currency.format(total),
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: textColor),
                ),
              ],
            ),

            // Disclaimer
            pw.Spacer(),
            pw.Divider(color: PdfColors.grey200),
            pw.SizedBox(height: 10),
            pw.Text(
              'Documento gerado eletronicamente. Não possui valor fiscal.',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              textAlign: pw.TextAlign.center,
            ),
          ];
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
