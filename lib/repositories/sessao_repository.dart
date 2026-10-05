import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'usuario_repository.dart';

class SessaoRepository extends ChangeNotifier {
  final UsuarioRepository usuarioRepository;
  Usuario? _usuarioAtual;

  SessaoRepository(this.usuarioRepository);

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get estaLogado => _usuarioAtual != null;

  /// Retorna null em caso de sucesso, ou mensagem de erro.
  String? login(String email, String senha) {
    final usuario = usuarioRepository.buscarPorEmail(email);
    if (usuario == null || usuario.senha != senha) {
      return 'E-mail ou senha inválidos.';
    }
    _usuarioAtual = usuario;
    notifyListeners();
    return null;
  }

  void logout() {
    _usuarioAtual = null;
    notifyListeners();
  }
}
