import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/papel.dart';
import '../models/usuario.dart';

class SessaoRepository extends ChangeNotifier {
  Usuario? _usuarioAtual;

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get estaLogado => _usuarioAtual != null;
  bool get ehPersonal => _usuarioAtual?.isPersonal ?? false;

  Future<void> carregar() async {
    notifyListeners();
  }

  Future<bool> login(String email, String senha) async {
    try {
      final db = await AppDatabase.instance.database;

      // Consulta os utilizadores na base de dados SQLite local
      final res = await db.query(
        'usuarios',
        where: 'LOWER(email) = ? AND senha = ?',
        whereArgs: [email.trim().toLowerCase(), senha.trim()],
      );

      if (res.isNotEmpty) {
        final uMap = res.first;
        final papelStr = uMap['papel'] as String;

        _usuarioAtual = Usuario(
          id: uMap['id'] as String,
          nome: uMap['nome'] as String,
          email: uMap['email'] as String,
          senha: uMap['senha'] as String,
          papel: papelStr == 'personal' ? Papel.personal : Papel.aluno,
        );

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Erro detalhado no login: $e');
      return false;
    }
  }

  void logout() {
    _usuarioAtual = null;
    notifyListeners();
  }
}