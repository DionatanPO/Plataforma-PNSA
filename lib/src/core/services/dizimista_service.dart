import 'package:cloud_firestore/cloud_firestore.dart';
import '../../ui/dizimistas/models/dizimista_model.dart';

class DizimistaService {
  static const String _collectionName = 'dizimistas';

  // Converter Dizimista para Map para armazenamento no Firestore
  static Map<String, dynamic> _toFirestoreMap(Dizimista dizimista) {
    return {
      'numero_registro': dizimista.numeroRegistro,
      'nome': dizimista.nome,
      'cpf': dizimista.cpf,
      'data_nascimento': dizimista.dataNascimento?.millisecondsSinceEpoch,
      'sexo': dizimista.sexo,
      'telefone': dizimista.telefone,
      'email': dizimista.email,
      'rua': dizimista.rua,
      'numero': dizimista.numero,
      'bairro': dizimista.bairro,
      'cidade': dizimista.cidade,
      'estado': dizimista.estado,
      'cep': dizimista.cep,
      'estado_civil': dizimista.estadoCivil,
      'nome_conjugue': dizimista.nomeConjugue,
      'data_casamento': dizimista.dataCasamento?.millisecondsSinceEpoch,
      'data_nascimento_conjugue':
          dizimista.dataNascimentoConjugue?.millisecondsSinceEpoch,
      'observacoes': dizimista.observacoes,
      'consentimento': dizimista.consentimento,
      'status': dizimista.status,
      'data_registro': dizimista.dataRegistro.millisecondsSinceEpoch,
    };
  }

  // Converter documento do Firestore para Dizimista
  static Dizimista _fromFirestoreDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Dizimista(
      id: doc.id, // Usar o ID do documento Firestore como ID do objeto
      numeroRegistro: data['numero_registro'] ?? '',
      nome: data['nome'] ?? '',
      cpf: data['cpf'] ?? '',
      dataNascimento: data['data_nascimento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['data_nascimento'])
          : null,
      sexo: data['sexo'],
      telefone: data['telefone'] ?? '',
      email: data['email'],
      rua: data['rua'],
      numero: data['numero'],
      bairro: data['bairro'],
      cidade: data['cidade'] ?? '',
      estado: data['estado'] ?? '',
      cep: data['cep'],
      estadoCivil: data['estado_civil'],
      nomeConjugue: data['nome_conjugue'],
      dataCasamento: data['data_casamento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['data_casamento'])
          : null,
      dataNascimentoConjugue: data['data_nascimento_conjugue'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              data['data_nascimento_conjugue'])
          : null,
      observacoes: data['observacoes'],
      consentimento: data['consentimento'] ?? false,
      status: data['status'] ?? '',
      dataRegistro:
          DateTime.fromMillisecondsSinceEpoch(data['data_registro'] ?? 0),
    );
  }

  // Obter todos os dizimistas
  static Stream<List<Dizimista>> getAllDizimistas() {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }

  // Obter dizimista por ID
  static Future<Dizimista?> getDizimistaById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(id)
        .get();

    if (doc.exists) {
      return _fromFirestoreDocument(doc);
    }
    return null;
  }

  // Adicionar novo dizimista
  static Future<void> addDizimista(Dizimista dizimista) async {
    await FirebaseFirestore.instance.collection(_collectionName).add({
      ..._toFirestoreMap(dizimista),
    });
  }

  // Atualizar dizimista existente
  static Future<void> updateDizimista(Dizimista dizimista) async {
    await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(dizimista.id.toString()) // Usando o ID como string para o doc
        .update(_toFirestoreMap(dizimista));
  }

  // Excluir dizimista
  static Future<void> deleteDizimista(String id) async {
    await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(id)
        .delete();
  }

  // Pesquisar dizimistas por nome, cpf ou telefone
  static Stream<List<Dizimista>> searchDizimistas(String query) {
    if (query.isEmpty) {
      return getAllDizimistas();
    }

    return FirebaseFirestore.instance
        .collection(_collectionName)
        .where(
          'nome',
          isGreaterThanOrEqualTo: query.toLowerCase(),
        )
        .where(
          'nome',
          isLessThanOrEqualTo: '${query.toLowerCase()}zz',
        )
        .orderBy('nome') // Adicionado para ordenar resultados de busca
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }

  // Método para busca avançada que busca em múltiplos campos
  static Stream<List<Dizimista>> advancedSearch(String query) {
    if (query.isEmpty) {
      return getAllDizimistas();
    }

    // Realiza a busca em múltiplos campos
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
      final allDocs =
          snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();

      // Filtra os resultados localmente nos campos relevantes
      final queryLower = query.toLowerCase();
      final filteredDocs = allDocs.where((dizimista) {
        return dizimista.nome.toLowerCase().contains(queryLower) ||
            dizimista.cpf.contains(query) ||
            dizimista.numeroRegistro.contains(query) ||
            dizimista.telefone.contains(query) ||
            (dizimista.email?.toLowerCase().contains(queryLower) ?? false) ||
            dizimista.cidade.toLowerCase().contains(queryLower) ||
            dizimista.estado.toLowerCase().contains(queryLower) ||
            (dizimista.nomeConjugue?.toLowerCase().contains(queryLower) ??
                false) ||
            (dizimista.estadoCivil?.toLowerCase().contains(queryLower) ??
                false) ||
            (dizimista.observacoes?.toLowerCase().contains(queryLower) ??
                false) ||
            dizimista.status.toLowerCase().contains(queryLower);
      }).toList();

      return filteredDocs;
    });
  }

  // Verificar se um CPF já existe
  static Future<Dizimista?> getDizimistaByCpf(String cpf) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('cpf', isEqualTo: cpf)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return _fromFirestoreDocument(snapshot.docs.first);
    }
    return null;
  }

  // Verificar se um E-mail já existe
  static Future<Dizimista?> getDizimistaByEmail(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return _fromFirestoreDocument(snapshot.docs.first);
    }
    return null;
  }

  // Verificar se um Número de Registro já existe
  static Future<Dizimista?> getDizimistaByRegistro(String registro) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(_collectionName)
        .where('numero_registro', isEqualTo: registro)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return _fromFirestoreDocument(snapshot.docs.first);
    }
    return null;
  }
}
