import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:plataforma_pnsa/src/domain/models/acesso_model.dart';

class AccessService {
  // Variável estática para indicar quando estamos criando um novo usuário
  // Isso ajuda a evitar trocas de sessão indesejadas
  static bool _creatingNewUser = false;
  static String? _originalUserUid;

  static bool get isCreatingNewUser => _creatingNewUser;
  static String? get originalUserUid => _originalUserUid;
  static const String _collectionName = 'usuarios';

  // Converter Acesso para Map para armazenamento no Firestore (usado para dados complementares)
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
        pendencia: data['pendencia'] ?? true,
      );
    }
    return null;
  }

  // Adicionar novo acesso
  static Future<void> addAcesso(Acesso acesso) async {
    // Obter o usuário atual antes de criar o novo usuário
    final currentUser = FirebaseAuth.instance.currentUser;
    _originalUserUid = currentUser?.uid;

    // Marcar que estamos criando um novo usuário
    _creatingNewUser = true;

    try {
      // Chamar a Cloud Function para criar o usuário
      // Isso evita a troca de sessão que ocorre com createUserWithEmailAndPassword
      final functions = FirebaseFunctions.instance;

      final result = await functions.httpsCallable('createUser').call({
        'email': acesso.email,
        'password': '123456', // Senha padrão
        'displayName': acesso.nome,
        'cpf': acesso.cpf,
        'telefone': acesso.telefone,
        'endereco': acesso.endereco,
        'funcao': acesso.funcao,
        'status': acesso.status,
        'ultimoAcesso': acesso.ultimoAcesso.millisecondsSinceEpoch,
        'pendencia': acesso.pendencia,
      });

      final responseData = result.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('Falha ao criar usuário: ${responseData['error']}');
      }

      print('Novo usuário criado via Cloud Function (${responseData['uid']}), mantendo usuário original (${_originalUserUid})');
    } on FirebaseFunctionsException catch (e) {
      // Resetar as flags em caso de erro
      _creatingNewUser = false;
      _originalUserUid = null;
      throw Exception('Erro na Cloud Function: ${e.message}');
    } catch (e) {
      // Resetar as flags em caso de erro
      _creatingNewUser = false;
      _originalUserUid = null;
      throw Exception('Erro ao criar usuário: $e');
    } finally {
      // Ajuste: manter a flag ativa por mais tempo para garantir que qualquer
      // operação assíncrona relacionada à criação seja concluída
      await Future.delayed(const Duration(milliseconds: 200));
      _creatingNewUser = false;
      _originalUserUid = null;
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
        .orderBy('nome') // Adicionado para ordenar resultados de busca
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestoreDocument(doc)).toList();
    });
  }
}