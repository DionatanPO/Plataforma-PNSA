import 'dart:io';
import 'package:flutter/material.dart';
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
import '../../../data/services/auth_service.dart';
import '../../contribuicoes/models/contribuicao_model.dart';

class ReportController extends GetxController {
  final RxList<Contribuicao> contribuicoes = <Contribuicao>[].obs;
  final RxDouble totalArrecadado = 0.0.obs;
  final RxDouble totalDizimos = 0.0.obs;
  final RxDouble totalOfertas = 0.0.obs;

  // Payment Method Totals
  final RxDouble totalDinheiro = 0.0.obs;
  final RxDouble totalPix = 0.0.obs;
  final RxDouble totalCartao = 0.0.obs;
  final RxDouble totalTransferencia = 0.0.obs;

  final RxBool isLoading = false.obs;

  // Date selection
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rxn<DateTimeRange> selectedRange = Rxn<DateTimeRange>();
  final RxBool isRangeMode = false.obs;
  final RxBool isCompetenceMode = false.obs;
  final RxString selectedCompetenceMonth =
      DateFormat('yyyy-MM').format(DateTime.now()).obs;

  @override
  void onInit() {
    super.onInit();
    // Load data when controller is initialized
    fetchDailyReport(selectedDate.value);

    // Listen to changes to refetch
    ever(selectedDate, (date) {
      if (!isRangeMode.value) fetchDailyReport(date);
    });

    ever(selectedRange, (range) {
      if (isRangeMode.value && range != null) {
        fetchPeriodReport(range.start, range.end);
      }
    });

    ever(isRangeMode, (rangeMode) {
      if (rangeMode) {
        isCompetenceMode.value = false;
        if (selectedRange.value != null) {
          fetchPeriodReport(
              selectedRange.value!.start, selectedRange.value!.end);
        }
      } else {
        fetchDailyReport(selectedDate.value);
      }
    });

    ever(isCompetenceMode, (compMode) {
      if (compMode) {
        isRangeMode.value = false;
        fetchCompetenceReport(selectedCompetenceMonth.value);
      } else {
        fetchDailyReport(selectedDate.value);
      }
    });

    ever(selectedCompetenceMonth, (month) {
      if (isCompetenceMode.value) fetchCompetenceReport(month);
    });
  }

  void updateDate(DateTime date) {
    isRangeMode.value = false;
    selectedDate.value = date;
  }

  void updateRange(DateTimeRange range) {
    // Ajustar o fim do período para o último segundo do dia selecionado
    final adjustedEnd = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
    );
    final adjustedRange = DateTimeRange(start: range.start, end: adjustedEnd);

    isRangeMode.value = true;
    selectedRange.value = adjustedRange;
  }

  Future<void> fetchDailyReport(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    await fetchPeriodReport(startOfDay, endOfDay);
  }

  Future<void> fetchPeriodReport(DateTime start, DateTime end) async {
    isLoading.value = true;
    try {
      final stream = ContribuicaoService.getContribuicoesByPeriod(
        start,
        end,
      );

      stream.listen(
        (lista) {
          contribuicoes.value = lista;
          _calculateTotals(lista);
          isLoading.value = false;
        },
        onError: (e) {
          print("Erro ao buscar contribuições: $e");
          isLoading.value = false;
        },
      );
    } catch (e) {
      print("Erro no controller: $e");
      isLoading.value = false;
    }
  }

  Future<void> fetchCompetenceReport(String month) async {
    isLoading.value = true;
    try {
      final stream = ContribuicaoService.getContribuicoesByCompetence(month);

      stream.listen(
        (lista) {
          contribuicoes.value = lista;
          _calculateTotals(lista);
          isLoading.value = false;
        },
        onError: (e) {
          print("Erro ao buscar competências: $e");
          isLoading.value = false;
        },
      );
    } catch (e) {
      print("Erro no controller (competência): $e");
      isLoading.value = false;
    }
  }

  void _calculateTotals(List<Contribuicao> lista) {
    double total = 0;
    double dizimos = 0;
    double ofertas = 0;

    // Calcular totais por método
    double dinheiro = 0;
    double pix = 0;
    double cartao = 0;
    double transferencia = 0;

    for (var c in lista) {
      double valorCalculado = c.valor;

      // Se estiver em modo competência, usar apenas o valor daquela competência
      if (isCompetenceMode.value) {
        try {
          final comp = c.competencias.firstWhere(
            (cp) => cp.mesReferencia == selectedCompetenceMonth.value,
          );
          valorCalculado = comp.valor;
        } catch (_) {
          // Se não achar (não deveria acontecer pelo filtro), pula ou usa 0
          valorCalculado = 0;
        }
      }

      total += valorCalculado;
      if (c.tipo.toLowerCase().contains('dízimo') ||
          c.tipo.toLowerCase().contains('dizimo')) {
        dizimos += valorCalculado;
      } else if (c.tipo.toLowerCase().contains('oferta')) {
        ofertas += valorCalculado;
      }

      final metodo = c.metodo.toLowerCase();
      if (metodo.contains('dinheiro') || metodo.contains('espécie')) {
        dinheiro += valorCalculado;
      } else if (metodo.contains('pix')) {
        pix += valorCalculado;
      } else if (metodo.contains('cartão') ||
          metodo.contains('cartao') ||
          metodo.contains('crédito') ||
          metodo.contains('débito')) {
        cartao += valorCalculado;
      } else if (metodo.contains('transferência') ||
          metodo.contains('transferencia') ||
          metodo.contains('ted') ||
          metodo.contains('doc')) {
        transferencia += valorCalculado;
      }
    }

    totalArrecadado.value = total;
    totalDizimos.value = dizimos;
    totalOfertas.value = ofertas;

    totalDinheiro.value = dinheiro;
    totalPix.value = pix;
    totalCartao.value = cartao;
    totalTransferencia.value = transferencia;
  }

  Future<void> downloadOrShareDailyReportPdf() async {
    try {
      isLoading.value = true;
      final pdf = await _createPdfDocument();
      final bytes = await pdf.save();
      final dateStr = DateFormat('ddMMyyyy').format(selectedDate.value);
      final fileName = 'relatorio_diario_$dateStr.pdf';

      if (kIsWeb) {
        // Na web, vamos forçar o download direto
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        // Para mobile e desktop, salvar temporariamente e compartilhar
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'application/pdf')],
          text: isRangeMode.value
              ? 'Relatório por Período'
              : 'Relatório diário - ${DateFormat('dd/MM/yyyy').format(selectedDate.value)}',
          subject: 'Relatório Paróquia Nossa Senhora Auxiliadora',
        );

        // Limpeza após um delay
        Future.delayed(const Duration(seconds: 10), () {
          if (file.existsSync()) {
            file.deleteSync();
          }
        });
      }
    } catch (e) {
      print('Erro ao processar relatório: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível processar o relatório: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Creates a PDF document for the daily report
  Future<pw.Document> _createPdfDocument() async {
    final pdf = pw.Document();
    final authService = Get.find<AuthService>();
    final user = authService.currentUser;
    // Tenta pegar o nome do user model se possível, senão usa display name ou email
    String userName = user?.displayName ?? 'Usuário do Sistema';
    if (user?.email != null) {
      userName += ' (${user!.email})';
    }

    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    // Load logo
    pw.ImageProvider? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/logo.jpg');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      print('Erro ao carregar logo: $e');
    }

    // Load font for PDF
    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            // Minimalist Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logoImage != null)
                  pw.Container(
                    width: 45,
                    height: 45,
                    margin: const pw.EdgeInsets.only(right: 15),
                    child: pw.ClipRRect(
                      horizontalRadius: 8,
                      verticalRadius: 8,
                      child: pw.Image(logoImage),
                    ),
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      isCompetenceMode.value
                          ? 'RELATÓRIO DE COMPETÊNCIA'
                          : isRangeMode.value
                              ? 'RELATÓRIO POR PERÍODO'
                              : 'RELATÓRIO DIÁRIO',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.Text(
                      isCompetenceMode.value
                          ? 'MÊS DE REFERÊNCIA: ${selectedCompetenceMonth.value}'
                          : 'PARÓQUIA NOSSA SENHORA AUXILIADORA',
                      style: pw.TextStyle(
                        color: PdfColors.grey600,
                        fontSize: 9,
                        letterSpacing: isCompetenceMode.value ? 1.0 : 2.0,
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    isCompetenceMode.value
                        ? 'COMPETÊNCIA'
                        : isRangeMode.value && selectedRange.value != null
                            ? '${DateFormat('dd/MM/yy').format(selectedRange.value!.start)} - ${DateFormat('dd/MM/yy').format(selectedRange.value!.end)}'
                            : dateFormat.format(selectedDate.value),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            pw.SizedBox(height: 30),

            // Summary Grid - Modern & Clean
            pw.Container(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Main Totals
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RESUMO GERAL',
                          style: pw.TextStyle(
                            color: PdfColors.grey500,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        _buildModernStatRow(
                          'Total Arrecadado',
                          currency.format(totalArrecadado.value),
                          isTotal: true,
                        ),
                        pw.SizedBox(height: 6),
                        _buildModernStatRow(
                          'Total de Dízimos',
                          currency.format(totalDizimos.value),
                        ),
                        pw.SizedBox(height: 6),
                        _buildModernStatRow(
                          'Total de Ofertas',
                          currency.format(totalOfertas.value),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 30),
                  // Right: Payment Methods
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'FORMAS DE PAGAMENTO',
                          style: pw.TextStyle(
                            color: PdfColors.grey500,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildModernSubStat(
                              'DINHEIRO',
                              currency.format(totalDinheiro.value),
                            ),
                            _buildModernSubStat(
                              'PIX',
                              currency.format(totalPix.value),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildModernSubStat(
                              'CARTÃO',
                              currency.format(totalCartao.value),
                            ),
                            _buildModernSubStat(
                              'TRANSF.',
                              currency.format(totalTransferencia.value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 40),

            // Table
            pw.Table.fromTextArray(
              headers: ['Nome', 'Tipo', 'Método', 'Valor'],
              data: contribuicoes.map((c) {
                double valorCalculado = c.valor;
                if (isCompetenceMode.value) {
                  try {
                    final comp = c.competencias.firstWhere(
                      (cp) => cp.mesReferencia == selectedCompetenceMonth.value,
                    );
                    valorCalculado = comp.valor;
                  } catch (_) {
                    valorCalculado = 0;
                  }
                }

                return [
                  c.dizimistaNome.isNotEmpty ? c.dizimistaNome : 'Anônimo',
                  c.tipo,
                  c.metodo,
                  currency.format(valorCalculado),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                ),
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey800,
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 5,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
              },
            ),

            pw.SizedBox(height: 40),

            // Footer / Signature
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Este documento foi gerado automaticamente pelo sistema.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Gerado em: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(now)}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'Assinado digitalmente por: $userName',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Fallback method to share as text if file sharing isn't available
  Future<void> _fallbackToTextSharing() async {
    final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate.value);
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    final message = '''
*Relatório Diário - $dateStr*
Paróquia Nossa Senhora Auxiliadora

*RESUMO GERAL*
💰 *Total:* ${currency.format(totalArrecadado.value)}
🙏 *Dízimos:* ${currency.format(totalDizimos.value)}
✨ *Ofertas:* ${currency.format(totalOfertas.value)}

*FORMAS DE PAGAMENTO*
💵 *Dinheiro:* ${currency.format(totalDinheiro.value)}
💠 *Pix:* ${currency.format(totalPix.value)}
💳 *Cartão:* ${currency.format(totalCartao.value)}
🏦 *Transf.:* ${currency.format(totalTransferencia.value)}

_Gerado automaticamente pelo sistema_
''';

    await Share.share(
      message,
      subject: 'Relatório Diário Paróquia Nossa Senhora Auxiliadora',
    );
  }

  Future<void> generateDailyReportPdf() async {
    try {
      isLoading.value = true;
      final pdf = await _createPdfDocument();
      final dateStr = DateFormat('ddMMyyyy').format(selectedDate.value);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'relatorio_diario_$dateStr.pdf',
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível gerar o PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );
      print('Erro ao gerar PDF: $e');
    } finally {
      isLoading.value = false;
    }
  }

  pw.Widget _buildModernStatRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: isTotal ? PdfColors.black : PdfColors.grey700,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isTotal ? 12 : 10,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: isTotal ? 12 : 10,
            color: isTotal ? PdfColors.green700 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildModernSubStat(String label, String value) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(5),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColors.grey500,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }
  // ==================================================================
  // GERAÇÃO DE RECIBO INDIVIDUAL
  // ==================================================================

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

    // Fontes
    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

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
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
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
                                'Autenticado por: $agentName',
                                style: const pw.TextStyle(fontSize: 6),
                              ),
                              pw.Text(
                                'Validado via Plataforma PNSA em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                                style: const pw.TextStyle(fontSize: 6),
                              ),
                              pw.Text(
                                'Código de Verificação: ${contribuicao.id.hashCode.toRadixString(16).toUpperCase()}',
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
}
