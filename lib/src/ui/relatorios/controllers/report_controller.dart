import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/services/contribuicao_service.dart';
import '../../../data/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  void onInit() {
    super.onInit();
    // Load data when controller is initialized
    fetchDailyReport(selectedDate.value);

    // Listen to date changes to refetch
    ever(selectedDate, (date) => fetchDailyReport(date));
  }

  void updateDate(DateTime date) {
    selectedDate.value = date;
  }

  Future<void> fetchDailyReport(DateTime date) async {
    isLoading.value = true;
    try {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final stream = ContribuicaoService.getContribuicoesByPeriod(
        startOfDay,
        endOfDay,
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
      total += c.valor;
      if (c.tipo.toLowerCase().contains('dízimo') ||
          c.tipo.toLowerCase().contains('dizimo')) {
        dizimos += c.valor;
      } else if (c.tipo.toLowerCase().contains('oferta')) {
        ofertas += c.valor;
      }

      final metodo = c.metodo.toLowerCase();
      if (metodo.contains('dinheiro') || metodo.contains('espécie')) {
        dinheiro += c.valor;
      } else if (metodo.contains('pix')) {
        pix += c.valor;
      } else if (metodo.contains('cartão') ||
          metodo.contains('cartao') ||
          metodo.contains('crédito') ||
          metodo.contains('débito')) {
        cartao += c.valor;
      } else if (metodo.contains('transferência') ||
          metodo.contains('transferencia') ||
          metodo.contains('ted') ||
          metodo.contains('doc')) {
        transferencia += c.valor;
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

  void shareDailyReportWhatsApp() async {
    final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate.value);
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    final message =
        '''
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

    final text = Uri.encodeComponent(message);
    final url = Uri.parse("https://wa.me/?text=$text");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Erro',
        'Não foi possível abrir o WhatsApp.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<void> generateDailyReportPdf() async {
    try {
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
                        'RELATÓRIO DIÁRIO',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.Text(
                        'PARÓQUIA NOSSA SENHORA AUXILIADORA',
                        style: pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 9,
                          letterSpacing: 2.0,
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
                      dateFormat.format(selectedDate.value),
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
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
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
                  return [
                    c.dizimistaNome.isNotEmpty ? c.dizimistaNome : 'Anônimo',
                    c.tipo,
                    c.metodo,
                    currency.format(c.valor),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.black,
                ),
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
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
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

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
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
}
