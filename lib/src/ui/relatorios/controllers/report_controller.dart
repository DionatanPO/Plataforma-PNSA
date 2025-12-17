import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  Future<void> generateDailyReportPdf() async {
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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logoImage != null)
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(logoImage),
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Paróquia Nossa Senhora Auxiliadora',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Relatório Diário de Contribuições',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Data: ${dateFormat.format(selectedDate.value)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),

            // Summary Section
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfStat(
                    'Total Arrecadado',
                    currency.format(totalArrecadado.value),
                    true,
                  ),
                  _buildPdfStat(
                    'Dízimos',
                    currency.format(totalDizimos.value),
                    false,
                  ),
                  _buildPdfStat(
                    'Ofertas',
                    currency.format(totalOfertas.value),
                    false,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfSubStat(
                  'Dinheiro',
                  currency.format(totalDinheiro.value),
                ),
                _buildPdfSubStat('Pix', currency.format(totalPix.value)),
                _buildPdfSubStat('Cartão', currency.format(totalCartao.value)),
                _buildPdfSubStat(
                  'Transferência',
                  currency.format(totalTransferencia.value),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

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
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {3: pw.Alignment.centerRight},
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

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfStat(String label, String value, bool isMain) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isMain ? 16 : 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfSubStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}
