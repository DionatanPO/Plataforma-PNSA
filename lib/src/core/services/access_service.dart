import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:plataforma_pnsa/src/domain/models/acesso_model.dart';
import 'package:plataforma_pnsa/firebase_options.dart';

class AccessService {
  static const String _collectionName = 'usuarios';
  static const String _secondaryAppName = 'SecondaryApp';

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
          return snapshot.docs
              .map((doc) => _fromFirestoreDocument(doc))
              .toList();
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
        id: doc.id, // Usar o ID do documento Firestore
        nome: data['nome'] ?? '',
        email: data['email'] ?? '',
        cpf: data['cpf'] ?? '',
        telefone: data['telefone'] ?? '',
        endereco: data['endereco'] ?? '',
        funcao: data['funcao'] ?? '',
        status: data['status'] ?? '',
        ultimoAcesso: DateTime.fromMillisecondsSinceEpoch(
          (data['ultimoAcesso'] as int?) ??
              DateTime.now().millisecondsSinceEpoch,
        ),
        pendencia: data['pendencia'] ?? true,
      );
    }
    return null;
  }

  /// Adiciona um novo acesso criando um usuário no Firebase Auth E salvando os dados no Firestore.
  ///
  /// IMPORTANTE: Usa uma segunda instância isolada do Firebase para criar o usuário,
  /// evitando que o administrador logado seja desconectado.
  static Future<void> addAcesso(Acesso acesso) async {
    FirebaseApp? secondaryApp;

    try {
      // 1. Criar uma instância secundária do Firebase para criar o novo usuário
      // Isso evita que a sessão do admin atual seja afetada
      try {
        secondaryApp = Firebase.app(_secondaryAppName);
      } catch (e) {
        // Se a app secundária não existe, criá-la
        secondaryApp = await Firebase.initializeApp(
          name: _secondaryAppName,
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // 2. Obter a instância de Auth da app secundária
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      // 3. Criar o usuário usando a instância secundária (não afeta a sessão principal)
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: acesso.email,
        password: '123456', // Senha padrão para primeiro acesso
      );

      final newUser = credential.user!;
      final newUserUid = newUser.uid;

      // 4. Atualizar o display name do novo usuário
      await newUser.updateDisplayName(acesso.nome);

      // 5. Fazer sign out do novo usuário na instância secundária
      await secondaryAuth.signOut();

      // 6. Criar o documento do usuário no Firestore usando a instância principal
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(newUserUid)
          .set({
            'nome': acesso.nome,
            'email': acesso.email,
            'cpf': acesso.cpf,
            'telefone': acesso.telefone,
            'endereco': acesso.endereco,
            'funcao': acesso.funcao,
            'status': acesso.status,
            'ultimoAcesso': acesso.ultimoAcesso.millisecondsSinceEpoch,
            'pendencia': acesso.pendencia,
          });

      print(
        '✅ Novo usuário criado com sucesso (UID: $newUserUid) sem afetar a sessão do admin.',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este e-mail já está cadastrado no sistema.';
          break;
        case 'invalid-email':
          errorMessage = 'O e-mail informado é inválido.';
          break;
        case 'weak-password':
          errorMessage = 'A senha é muito fraca.';
          break;
        default:
          errorMessage = 'Erro ao criar usuário: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    } finally {
      // 7. Deletar a app secundária para liberar recursos
      if (secondaryApp != null) {
        try {
          await secondaryApp.delete();
        } catch (e) {
          // Ignorar erro ao deletar app secundária
          print('Aviso: Não foi possível deletar a app secundária: $e');
        }
      }
    }
  }

  // Atualizar acesso existente
  static Future<void> updateAcesso(Acesso acesso) async {
    await FirebaseFirestore.instance
        .collection(_collectionName)
        .doc(acesso.id) // O ID agora é o UID do Firebase Auth
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
        .where('nome', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('nome', isLessThanOrEqualTo: '${query.toLowerCase()}zz')
        .orderBy('nome') // Adicionado para ordenar resultados de busca
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _fromFirestoreDocument(doc))
              .toList();
        });
  }
}
