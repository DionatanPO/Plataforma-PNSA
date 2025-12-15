import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plataforma_pnsa/src/domain/models/acesso_model.dart';

class AccessService {
  static const String _collectionName = 'usuarios';

  // Converter Acesso para Map para armazenamento no Firestore
  static Map<String, dynamic> _toFirestoreMap(Acesso acesso) {
    return {
      'nome': acesso.nome,
      'email': acesso.email,
      'cpf': acesso.cpf,
      'telefone': acesso.telefone,
      'endereco': acesso.endereco,
      'funcao': acesso.funcao,
      'status': acesso.status,
      'ultimoAcesso': acesso.ultimoAcesso.millisecondsSinceEpoch,
      'pendencia': acesso.pendencia,
    };
  }

  // Converter documento do Firestore para Acesso
  static Acesso _fromFirestoreDocument(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Acesso(
      id: doc.id, // Usar o ID do documento Firestore como ID do objeto
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      cpf: data['cpf'] ?? '',
      telefone: data['telefone'] ?? '',
      endereco: data['endereco'] ?? '',
      funcao: data['funcao'] ?? '',
      status: data['status'] ?? '',
      ultimoAcesso: DateTime.fromMillisecondsSinceEpoch(
        data['ultimoAcesso']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      pendencia: data['pendencia'] ?? true,
    );
  }

  // Obter todos os acessos
  static Stream<List<Acesso>> getAllAcessos() {
    return FirebaseFirestore.instance
        .collection(_collectionName)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }

  // Obter acesso por ID
  static Future<Acesso?> getAcessoById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(id)
        .get();

    if (doc.exists) {
      // Como doc é um DocumentSnapshot e não QueryDocumentSnapshot, vamos converter os dados manualmente
      final data = doc.data() as Map<String, dynamic>;
      return Acesso(
        id: doc.id,  // Usar o ID do documento Firestore
        nome: data['nome'] ?? '',
        email: data['email'] ?? '',
        cpf: data['cpf'] ?? '',
        telefone: data['telefone'] ?? '',
        endereco: data['endereco'] ?? '',
        funcao: data['funcao'] ?? '',
        status: data['status'] ?? '',
        ultimoAcesso: DateTime.fromMillisecondsSinceEpoch(
          (data['ultimoAcesso'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
        ),
        pendencia: data['pendencia'] ?? false,
      );
    }
    return null;
  }

  // Adicionar novo acesso
  static Future<void> addAcesso(Acesso acesso) async {
    try {
      // Primeiro criar o usuário no Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: acesso.email,
        password: '123456', // Senha temporária
      );

      // Depois salvar os dados complementares no Firestore
      await FirebaseFirestore.instance.collection(_collectionName).doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        ..._toFirestoreMap(acesso)
      });
    } on FirebaseAuthException catch (e) {
      // Tratar erros de autenticação
      throw Exception('Erro ao criar usuário: ${e.message}');
    }
  }

  // Atualizar acesso existente
  static Future<void> updateAcesso(Acesso acesso) async {
    await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(acesso.id)  // O ID agora é o UID do Firebase Auth
        .update(_toFirestoreMap(acesso));
  }

  // Excluir acesso
  static Future<void> deleteAcesso(String id) async {
    // Remover do Firestore
    await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(id)
        .delete();
  }

  // Pesquisar acessos por nome, email ou função
  static Stream<List<Acesso>> searchAcessos(String query) {
    if (query.isEmpty) {
      return getAllAcessos();
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
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }
}