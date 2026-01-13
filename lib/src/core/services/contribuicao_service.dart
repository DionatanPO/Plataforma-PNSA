import 'package:cloud_firestore/cloud_firestore.dart';

import '../../ui/contribuicoes/models/contribuicao_model.dart';

class ContribuicaoService {
  static const String _collectionName = 'contribuicoes';

  // Converter Contribuicao para Map para armazenamento no Firestore
  static Map<String, dynamic> _toFirestoreMap(Contribuicao contribuicao) {
    return {
      'dizimistaId': contribuicao.dizimistaId,
      'dizimistaNome': contribuicao.dizimistaNome,
      'tipo': contribuicao.tipo,
      'valor': contribuicao.valor,
      'metodo': contribuicao.metodo,
      'dataRegistro': contribuicao.dataRegistro.millisecondsSinceEpoch,
      'dataPagamento': contribuicao.dataPagamento.millisecondsSinceEpoch,
      'status': contribuicao.status,
      'usuarioId': contribuicao.usuarioId,
      'observacao': contribuicao.observacao,
      'competencias': contribuicao.competencias.map((c) => c.toMap()).toList(),
      'mesesCompetencia': contribuicao.mesesCompetencia,
    };
  }

  // Converter documento do Firestore para Contribuicao
  static Contribuicao _fromFirestoreDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contribuicao(
      id: doc.id,
      dizimistaId: data['dizimistaId']?.toString() ?? '',
      dizimistaNome: data['dizimistaNome'] ?? '',
      tipo: data['tipo'] ?? '',
      valor: (data['valor'] is int)
          ? (data['valor'] as int).toDouble()
          : data['valor']?.toDouble() ?? 0.0,
      metodo: data['metodo'] ?? '',
      dataRegistro:
          DateTime.fromMillisecondsSinceEpoch(data['dataRegistro'] ?? 0),
      dataPagamento: DateTime.fromMillisecondsSinceEpoch(
          data['dataPagamento'] ?? data['dataRegistro'] ?? 0),
      status: data['status'] ?? 'Pago',
      usuarioId: data['usuarioId'] ?? '',
      observacao: data['observacao'],
      competencias: data['competencias'] != null
          ? List<ContribuicaoCompetencia>.from(data['competencias']
              .map((x) => ContribuicaoCompetencia.fromMap(x)))
          : [],
      mesesCompetencia: data['mesesCompetencia'] != null
          ? List<String>.from(data['mesesCompetencia'])
          : [],
    );
  }

  // Obter todas as contribuições
  static Stream<List<Contribuicao>> getAllContribuicoes() {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .orderBy('dataPagamento', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }

  // Obter contribuições por ID de dizimista
  static Stream<List<Contribuicao>> getContribuicoesByDizimistaId(
      String dizimistaId) {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .where('dizimistaId', isEqualTo: dizimistaId)
        .orderBy('dataPagamento', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }

  // Obter contribuição por ID
  static Future<Contribuicao?> getContribuicaoById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(id)
        .get();

    if (doc.exists) {
      return _fromFirestoreDocument(doc);
    }
    return null;
  }

  // Adicionar nova contribuição
  static Future<String> addContribuicao(Contribuicao contribuicao) async {
    final docRef =
        await FirebaseFirestore.instance.collection(_collectionName).add({
      ..._toFirestoreMap(contribuicao),
    });
    return docRef.id; // Retorna o ID do documento criado
  }

  // Atualizar contribuição existente
  static Future<void> updateContribuicao(Contribuicao contribuicao) async {
    await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(contribuicao.id) // Usando o ID como string para o doc
        .update(_toFirestoreMap(contribuicao));
  }

  // Excluir contribuição
  static Future<void> deleteContribuicao(String id) async {
    await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(id)
        .delete();
  }

  // Obter contribuições por período
  static Stream<List<Contribuicao>> getContribuicoesByPeriod(
      DateTime startDate, DateTime endDate) {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .where('dataPagamento',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .where('dataPagamento',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .orderBy('dataPagamento', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }

  // Obter contribuições por mês de competência (Referência)
  static Stream<List<Contribuicao>> getContribuicoesByCompetence(
      String mesReferencia) {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .where('mesesCompetencia', arrayContains: mesReferencia)
        .orderBy('dataPagamento', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }

  // Obter contribuições por data específica (yyyy-MM-dd)
  static Stream<List<Contribuicao>> getContribuicoesByDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    return getContribuicoesByPeriod(startOfDay, endOfDay);
  }
}
