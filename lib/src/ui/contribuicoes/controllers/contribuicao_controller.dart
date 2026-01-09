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
import '../../dizimistas/controllers/dizimista_controller.dart';
import '../../../core/services/dizimista_service.dart';
import '../../../core/services/contribuicao_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';

class ContribuicaoController extends GetxController {
  // Estado privado
  final _contribuicoes = <Contribuicao>[].obs;
  final _dizimistas = <Dizimista>[].obs;
  final _isLoading = false.obs;

  // Getters públicos
  List<Contribuicao> get contribuicoes => _contribuicoes;
  List<Dizimista> get dizimistas => _dizimistas;
  bool get isLoading => _isLoading.value;

  StreamSubscription? _contribuicoesSub;
  StreamSubscription? _dizimistasSub;

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
  final valor = ''.obs; // Transformar em observável
  final observacao = ''.obs;

  // Lista de competências (mês/ano e valor)
  final competencias = <ContribuicaoCompetencia>[].obs;

  double valorNumerico = 0.0;

  // Método para adicionar uma competência
  void adicionarCompetencia(String mesAno, double valor) {
    // Se já existe, remove primeiro
    competencias.removeWhere((c) => c.mesReferencia == mesAno);
    competencias
        .add(ContribuicaoCompetencia(mesReferencia: mesAno, valor: valor));
    competencias.sort((a, b) => a.mesReferencia.compareTo(b.mesReferencia));
  }

  // Método para remover uma competência
  void removerCompetencia(String mesAno) {
    competencias.removeWhere((c) => c.mesReferencia == mesAno);

    // Recalcular se houver valor
    if (valor.value.isNotEmpty) {
      dividirValorEntreCompetencias();
    }
  }

  // Método para limpar competências
  void limparCompetencias() {
    competencias.clear();
  }

  // Método para dividir o valor total igualmente entre as competências selecionadas
  void dividirValorEntreCompetencias() {
    if (competencias.isEmpty) return;

    String valorLimpo = valor.value
        .replaceAll('.', '')
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.');

    double total = double.tryParse(valorLimpo) ?? 0.0;
    if (total <= 0) return;

    double valorPorMes = total / competencias.length;

    // Atualizar a lista mantendo a ordem mas com novos valores
    final novosMeses = competencias.map((c) => c.mesReferencia).toList();
    competencias.clear();
    for (var mes in novosMeses) {
      competencias
          .add(ContribuicaoCompetencia(mesReferencia: mes, valor: valorPorMes));
    }
  }

  @override
  void onInit() {
    super.onInit();

    final authService = Get.find<AuthService>();

    // Reage a mudanças no login
    ever(authService.userData, (userData) {
      if (userData != null) {
        _startListening();
      } else {
        _stopListening();
      }
    });

    // Se já estiver logado (ex: F5)
    if (authService.userData.value != null) {
      _startListening();
    }

    // Recalcular divisão quando o valor mudar
    ever(valor, (_) => dividirValorEntreCompetencias());

    // Gerenciar competências baseado no tipo
    ever(tipo, (String? novoTipo) {
      if (novoTipo == 'Dízimo Regular') {
        _sugerirMesAtual();
      } else {
        // Se for Atrasado, deixa o usuário escolher (limpa a sugestão automática)
        competencias.clear();
      }
    });

    // Inicialização
    if (tipo.value == 'Dízimo Regular') {
      _sugerirMesAtual();
    }
  }

  void _startListening() {
    _stopListening();
    fetchContribuicoes();
    fetchDizimistas();
  }

  void _stopListening() {
    _contribuicoesSub?.cancel();
    _dizimistasSub?.cancel();
    _contribuicoes.clear();
    _dizimistas.clear();
  }

  @override
  void onClose() {
    _stopListening();
    super.onClose();
  }

  void adicionarVariasCompetencias(List<String> meses) {
    // Mantém os valores se já existirem, ou adiciona novos com 0
    final novos = <ContribuicaoCompetencia>[];
    for (var mes in meses) {
      novos.add(ContribuicaoCompetencia(mesReferencia: mes, valor: 0));
    }
    competencias.assignAll(novos);
    competencias.sort((a, b) => a.mesReferencia.compareTo(b.mesReferencia));
    dividirValorEntreCompetencias();
  }

  void _sugerirMesAtual() {
    final now = DateTime.now();
    final mesRef = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    competencias.clear();
    adicionarCompetencia(mesRef, 0);
    dividirValorEntreCompetencias();
  }

  void resetForm() {
    dizimistaSelecionado.value = null;
    dataSelecionada.value = DateTime.now();
    valor.value = '';
    observacao.value = '';
    tipo.value = 'Dízimo Regular';
    metodo.value = 'PIX';
    _sugerirMesAtual();
  }

  Future<void> fetchContribuicoes() async {
    _isLoading.value = true;
    try {
      // Buscar contribuições reais do Firestore usando stream
      final contribuicoesStream = ContribuicaoService.getAllContribuicoes();

      // Escutar o stream e atualizar a lista local
      _contribuicoesSub = contribuicoesStream.listen(
        (contribuicoesList) {
          _contribuicoes.assignAll(contribuicoesList);
        },
        onError: (error) {
          print("Erro ao carregar contribuições do Firestore: $error");
        },
      );
    } catch (e) {
      print("Erro ao carregar contribuições: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchDizimistas() async {
    _isLoading.value = true;
    try {
      // Buscar diretamente do Firestore usando o serviço
      final dizimistasStream = DizimistaService.getAllDizimistas();

      // Escutar o stream e atualizar a lista local
      _dizimistasSub = dizimistasStream.listen(
        (dizimistasList) {
          _dizimistas.assignAll(dizimistasList);
        },
        onError: (error) {
          print("Erro ao carregar dizimistas do Firestore: $error");
        },
      );
    } catch (e) {
      print("Erro ao carregar dizimistas: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Contribuicao> addContribuicao(Contribuicao contribuicao) async {
    _isLoading.value = true;
    try {
      // Salvar no Firestore e obter o ID do documento criado
      final docId = await ContribuicaoService.addContribuicao(contribuicao);

      // Criar uma nova contribuição com o ID do documento do Firestore
      final contribuicaoComId = contribuicao.copyWith(id: docId);

      // Atualizar a lista local adicionando no topo
      _contribuicoes.insert(0, contribuicaoComId);

      return contribuicaoComId;
    } catch (e) {
      print("Erro ao adicionar contribuição no Firestore: $e");
      rethrow; // Re-lançar o erro para que a view possa tratar
    } finally {
      _isLoading.value = false;
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

    final queryLower = query.toLowerCase().trim();

    return _dizimistas.where((dizimista) {
      return dizimista.nome.toLowerCase().contains(queryLower) ||
          dizimista.cpf.contains(query) ||
          dizimista.telefone.contains(query) ||
          (dizimista.email?.toLowerCase().contains(queryLower) ?? false) ||
          (dizimista.rua?.toLowerCase().contains(queryLower) ?? false) ||
          (dizimista.numero?.toLowerCase().contains(queryLower) ?? false) ||
          (dizimista.bairro?.toLowerCase().contains(queryLower) ?? false) ||
          dizimista.cidade.toLowerCase().contains(queryLower) ||
          dizimista.estado.toLowerCase().contains(queryLower) ||
          (dizimista.cep?.contains(query) ?? false) ||
          (dizimista.nomeConjugue?.toLowerCase().contains(queryLower) ??
              false) ||
          (dizimista.estadoCivil?.toLowerCase().contains(queryLower) ??
              false) ||
          (dizimista.observacoes?.toLowerCase().contains(queryLower) ??
              false) ||
          dizimista.status.toLowerCase().contains(queryLower);
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

  // Método para obter os dados de um dizimista pelo ID
  Dizimista? getDizimistaById(String id) {
    final controller = Get.find<DizimistaController>();
    try {
      return controller.dizimistas.firstWhere(
        (dizimista) => dizimista.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Validações
  bool validateForm() {
    if (dizimistaSelecionado.value == null) {
      print("Erro: Nenhum dizimista selecionado");
      return false;
    }

    if (valor.value.isEmpty) {
      print("Erro: Valor não informado");
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
      print("Erro: Valor inválido");
      return false;
    }

    // Verificar se o método de pagamento foi selecionado
    if (metodo.value.isEmpty) {
      print("Erro: Método de pagamento não selecionado");
      return false;
    }

    return true;
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
      _isLoading.value = true;
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
      _isLoading.value = false;
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
                        text: contribuicao.tipo.toUpperCase(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      if (contribuicao.competencias.isNotEmpty) ...[
                        const pw.TextSpan(text: ' ('),
                        pw.TextSpan(
                          text: contribuicao.competencias
                              .map((c) => _formatMesReferencia(c.mesReferencia))
                              .join(', '),
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

  // Criar uma nova contribuição a partir dos dados do formulário
  Contribuicao createContribuicaoFromForm() {
    final dizimista = dizimistaSelecionado.value!;
    final user = Get.find<AuthService>().currentUser;

    // Limpa o valor formatado para obter o valor numérico
    String valorLimpo = valor.value
        .replaceAll('.', '') // Remove separador de milhar
        .replaceAll('R\$', '') // Remove simbolo
        .replaceAll(' ', '') // Remove espaços
        .replaceAll(',', '.'); // Troca vírgula por ponto

    final valorDouble = double.tryParse(valorLimpo) ?? 0.0;

    return Contribuicao(
      id: '', // O ID será definido pelo Firestore
      dizimistaId: dizimista.id,
      dizimistaNome: dizimista.nome,
      tipo: tipo.value,
      valor: valorDouble,
      metodo: metodo.value,
      dataRegistro: DateTime.now(),
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
}
