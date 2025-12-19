import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

class SessionService extends GetxService {
  final RxBool isInitialCheckComplete = false.obs;
  static const String _storageKey = 'user_session';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _box = GetStorage();

  // Verifica se o usuário está atualmente autenticado
  bool get isAuthenticated {
    return _auth.currentUser != null;
  }

  String get userName =>
      Get.find<AuthService>().currentUserData?.nome ??
      getSession()?['nome'] ??
      'Usuário';

  // Getters de função (Perfil)
  String get userRole => Get.find<AuthService>().currentUserData?.funcao ?? '';

  bool get isAdmin => userRole == 'Administrador';
  bool get isSecretaria => userRole == 'Secretaria' || isAdmin;
  bool get isFinanceiro => userRole == 'Financeiro' || isAdmin;
  bool get isAgente => userRole == 'Agente de Dízimo' || isAdmin;
  bool get isMembro => userRole == 'Membro';

  // Obtém o UID do usuário atual
  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // Salva os dados da sessão no armazenamento local
  Future<void> saveSession(String userId, String email, String nome) async {
    await _box.write(_storageKey, {
      'userId': userId,
      'email': email,
      'nome': nome,
      'lastLogin': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Recupera os dados da sessão armazenados
  Map<String, dynamic>? getSession() {
    return _box.read<Map<String, dynamic>?>(_storageKey);
  }

  // Remove a sessão armazenada (logout)
  Future<void> clearSession() async {
    await _box.remove(_storageKey);
  }

  // Verifica se há uma sessão válida armazenada
  bool hasValidSession() {
    final sessionData = getSession();
    if (sessionData == null) return false;

    // Pode adicionar lógica adicional de validação aqui, como tempo de expiração
    return sessionData['userId'] != null;
  }

  // Atualiza o status de último acesso no Firestore
  Future<void> updateLastAccess() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('usuarios').doc(user.uid);
      await userRef.update({
        'ultimoAcesso': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Fecha a sessão corrente
  Future<void> signOut() async {
    await _auth.signOut();
    await clearSession();
  }

  // Verifica se o usuário tem dados completos
  Future<bool> hasCompleteUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final authService = Get.find<AuthService>();
      final userData = await authService.getUserDataWithRetry(user.uid);
      return userData != null;
    }
    return false;
  }
}
