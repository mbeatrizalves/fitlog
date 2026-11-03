import 'package:flutter/material.dart';
import 'repositories/sessao_repository.dart';
import 'repositories/treino_repository.dart';
import 'repositories/usuario_repository.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  AppState._internal();

  final SessaoRepository sessao = SessaoRepository();
  final UsuarioRepository usuarios = UsuarioRepository();
  final TreinoRepository treinos = TreinoRepository();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    await usuarios.carregar();
    await treinos.carregar();
    await sessao.carregar();

    _initialized = true;
    notifyListeners();
  }
}