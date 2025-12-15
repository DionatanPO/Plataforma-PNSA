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
    };
  }

  // Converter documento do Firestore para Contribuicao
  static Contribuicao _fromFirestoreDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contribuicao(
      id: doc.id, // Usar o ID do documento Firestore como ID do objeto (agora string)
      dizimistaId: data['dizimistaId']?.toString() ?? '',
      dizimistaNome: data['dizimistaNome'] ?? '',
      tipo: data['tipo'] ?? '',
      valor: (data['valor'] is int) ? (data['valor'] as int).toDouble() : data['valor']?.toDouble() ?? 0.0,
      metodo: data['metodo'] ?? '',
      dataRegistro: DateTime.fromMillisecondsSinceEpoch(data['dataRegistro'] ?? 0),
    );
  }

  // Obter todas as contribuições
  static Stream<List<Contribuicao>> getAllContribuicoes() {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .orderBy('dataRegistro', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }

  // Obter contribuições por ID de dizimista
  static Stream<List<Contribuicao>> getContribuicoesByDizimistaId(String dizimistaId) {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .where('dizimistaId', isEqualTo: dizimistaId)
        .orderBy('dataRegistro', descending: true)
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
    final docRef = await FirebaseFirestore.instance.collection(_collectionName).add({
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
  static Stream<List<Contribuicao>> getContribuicoesByPeriod(DateTime startDate, DateTime endDate) {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .where('dataRegistro', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .where('dataRegistro', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .orderBy('dataRegistro', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }
}