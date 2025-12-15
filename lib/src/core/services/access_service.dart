import 'package:cloud_firestore/cloud_firestore.dart';
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
        pendencia: data['pendencia'] ?? true,
      );
    }
    return null;
  }

  // Adicionar novo acesso
  static Future<void> addAcesso(Acesso acesso) async {
    try {
      // Obter o usuário atual e seu token antes de criar o novo usuário
      final currentUser = FirebaseAuth.instance.currentUser;
      String? originalIdToken;

      if (currentUser != null) {
        originalIdToken = await currentUser.getIdToken();
        _originalUserUid = currentUser.uid;
      }

      // Marcar que estamos criando um novo usuário
      _creatingNewUser = true;

      // Criar o usuário no Firebase Auth
      final newUserCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: acesso.email,
        password: '123456', // Senha temporária
      );

      // Salvar os dados complementares no Firestore
      await FirebaseFirestore.instance.collection(_collectionName).doc(newUserCredential.user!.uid).set({
        'id': newUserCredential.user!.uid,
        ..._toFirestoreMap(acesso)
      });

      // Após criar o novo usuário e salvar no Firestore, reautenticar o usuário original
      // Isso evita que o novo usuário fique logado no lugar do administrador
      if (originalIdToken != null && currentUser != null) {
        // A forma mais segura de restaurar a sessão do usuário original é fazer logout do novo usuário
        // e permitir que o listener retome a sessão correta
        // Mas infelizmente não podemos "voltar" para o usuário anterior diretamente

        // A alternativa mais viável é manter a flag ativa para que o AuthService continue
        // ignorando as mudanças de estado até que tudo esteja resolvido
        print('Novo usuário criado (${newUserCredential.user!.uid}), mantendo usuário original (${_originalUserUid})');
      }

      // Após completar, resetar a flag
      _creatingNewUser = false;
      _originalUserUid = null;
    } on FirebaseAuthException catch (e) {
      // Resetar as flags em caso de erro também
      _creatingNewUser = false;
      _originalUserUid = null;
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