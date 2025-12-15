import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Changed from firebase_database
import 'package:get/get.dart';

import '../../core/services/access_service.dart';
import '../../domain/models/user_model.dart';
import 'session_service.dart';


class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Changed from FirebaseDatabase
  final SessionService _sessionService = Get.find<SessionService>();

  // Observable para o usuário atual
  final Rxn<User> _firebaseUser = Rxn<User>();

  User? get currentUser => _firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    // Escuta as mudanças no estado de autenticação
    _auth.authStateChanges().listen((firebaseUser) {
      // Verificar se estamos atualmente criando um novo usuário via AccessService
      // Se estivermos, ignorar essa mudança de estado para evitar troca indesejada
      if (!AccessService.isCreatingNewUser) {
        _firebaseUser.value = firebaseUser;
      } else {
        // Se estivermos criando um novo usuário mas o firebaseUser é nulo (logout ou erro),
        // ainda devemos atualizar o usuário
        if (firebaseUser == null) {
          _firebaseUser.value = firebaseUser;
        }
      }
    });

    // Restaura a sessão se ela existir
    _restoreSession();
  }

  // Método para restaurar a sessão do usuário
  Future<void> _restoreSession() async {
    if (_sessionService.hasValidSession()) {
      // O Firebase Auth já mantém a sessão automaticamente,
      // mas podemos verificar se o usuário ainda é válido
      final user = _auth.currentUser;
      if (user != null) {
        // Atualiza o último acesso
        await _sessionService.updateLastAccess();
      }
    }
  }

  /// Efetua o login com email e senha.
  Future<bool> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = result.user;

      if (user != null) {
        // Salvar dados da sessão
        await _sessionService.saveSession(user.uid, user.email ?? '', user.email?.split('@')[0] ?? 'Usuário');
      }

      return true;
    } on FirebaseAuthException catch (e) {
      // Log do erro para depuração
      print('Firebase Auth Exception: ${e.message} (code: ${e.code})');
      return false;
    } catch (e) {
      // Log do erro geral
      print('Erro desconhecido no login: $e');
      return false;
    }
  }

  /// Cria ou atualiza as informações de um usuário no Firestore.
  /// A chave do usuário no banco de dados será o seu UID.
  Future<void> createUserInDatabase(User user, String nome) async {
    try {
      final userRef = _firestore.collection('usuarios').doc(user.uid); // Changed for Firestore

      // Para garantir que o modelo seja preenchido corretamente,
      // buscamos o usuário existente ou criamos um novo com valores padrão.
      final docSnapshot = await userRef.get(); // Changed for Firestore
      if (docSnapshot.exists) {
        // Se o usuário já existe, apenas atualizamos o último acesso.
        await userRef.update({
          'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
          'ultimoAcesso': DateTime.now().millisecondsSinceEpoch,
        });
        print('Usuário já existe. Último acesso atualizado no Firestore.');
        return;
      }

      // Se o usuário não existe, criamos um novo com todos os campos.
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        nome: nome,
        displayName: user.displayName ?? nome,
        photoURL: user.photoURL ?? '',
        createdAt: user.metadata.creationTime?.millisecondsSinceEpoch ?? now.millisecondsSinceEpoch,
        lastLoginAt: user.metadata.lastSignInTime?.millisecondsSinceEpoch ?? now.millisecondsSinceEpoch,
        cpf: '', // Padrão
        telefone: '', // Padrão
        endereco: '', // Padrão
        funcao: 'Membro', // Padrão
        status: 'Ativo', // Padrão
        ultimoAcesso: now, // Padrão
        pendencia: false, // Padrão
      );

      // Usando .set() para criar ou sobrescrever os dados do usuário
      await userRef.set(userModel.toJson());
      print('Novo usuário salvo no Firestore com sucesso!');

    } catch (e) {
      // Erros de permissão serão capturados aqui.
      print('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  /// Efetua o logout do usuário.
  Future<void> logout() async {
    await _auth.signOut();
    await _sessionService.clearSession();
  }

  /// Atualiza o status de pendência do usuário no Firestore.
  Future<void> updateUserPendencyStatus(bool pendencia) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('usuarios').doc(user.uid);
      await userRef.update({
        'pendencia': pendencia,
        'ultimoAcesso': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /// Obtém os dados do usuário do Firestore.
  Future<UserModel?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('usuarios').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}