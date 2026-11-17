import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import '../utils/validators.dart';
import 'database_service.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Autenticação local, apenas para o exercício acadêmico.
/// Não substitui autenticação em um servidor com sessões validadas pelo backend.
class AuthService {
  AuthService(this._database);

  final DatabaseService _database;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _sessionKey = 'organizaja_session_user_id';
  final _kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 120000, bits: 256);

  Future<String> _hash(String password, List<int> salt) async {
    final key = await _kdf.deriveKeyFromPassword(password: password, nonce: salt);
    return base64UrlEncode(await key.extractBytes());
  }

  bool _sameHash(String a, String b) {
    // Comparação de tempo estável para dados com o mesmo tamanho.
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final safeName = name.trim();
    final safeEmail = email.trim().toLowerCase();
    if (Validators.name(safeName) != null ||
        Validators.email(safeEmail) != null ||
        Validators.password(password) != null) {
      throw const AuthException('Revise os dados do cadastro.');
    }
    final db = await _database.database;
    final existing = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [safeEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw const AuthException('Este e-mail já foi cadastrado.');
    }

    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = await _hash(password, salt);
    late final int id;
    try {
      id = await db.insert('users', {
        'name': safeName,
        'email': safeEmail,
        'password_hash': hash,
        'password_salt': base64UrlEncode(salt),
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } on DatabaseException {
      throw const AuthException('Não foi possível cadastrar. Confira o e-mail.');
    }
    await _storage.write(key: _sessionKey, value: id.toString());
    return AppUser(id: id, name: safeName, email: safeEmail);
  }

  Future<AppUser> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthException('Informe e-mail e senha.');
    }
    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    final row = rows.first;
    final salt = base64Url.decode(row['password_salt'] as String);
    final candidate = await _hash(password, salt);
    if (!_sameHash(candidate, row['password_hash'] as String)) {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    final user = AppUser.fromMap(row);
    await _storage.write(key: _sessionKey, value: user.id.toString());
    return user;
  }

  Future<AppUser?> restoreSession() async {
    final savedId = await _storage.read(key: _sessionKey);
    final id = int.tryParse(savedId ?? '');
    if (id == null) return null;
    final db = await _database.database;
    final rows = await db.query(
      'users',
      columns: ['id', 'name', 'email'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      await logout();
      return null;
    }
    return AppUser.fromMap(rows.first);
  }

  Future<void> logout() async {
    await _storage.delete(key: _sessionKey);
  }
}
