import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._auth);
  final AuthService _auth;

  AppUser? _user;
  AppUser? get user => _user;
  bool get authenticated => _user != null;

  Future<void> restore() async {
    try {
      _user = await _auth.restoreSession();
    } catch (_) {
      // Se o armazenamento seguro estiver indisponível, exige novo login.
      _user = null;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _user = await _auth.login(email: email, password: password);
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _user = await _auth.register(name: name, email: email, password: password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    notifyListeners();
  }
}
