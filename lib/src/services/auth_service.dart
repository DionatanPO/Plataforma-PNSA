import 'package:get/get.dart';

abstract class AuthService {
  Future<bool> login(String email, String password);
  Future<void> logout();
  bool get isAuthenticated;
}

class AuthServiceImpl extends AuthService {
  @override
  bool get isAuthenticated => _isLoggedIn;
  
  bool _isLoggedIn = false;

  @override
  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Simple validation - in real app, this would be an API call
    if (email == 'test@example.com' && password == 'password123') {
      _isLoggedIn = true;
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    _isLoggedIn = false;
  }
}