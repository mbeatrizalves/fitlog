import 'repositories/sessao_repository.dart';
import 'repositories/treino_repository.dart';
import 'repositories/usuario_repository.dart';

/// Estado compartilhado da aplicação (repositórios em memória).
class AppState {
  AppState._()
      : usuarios = UsuarioRepository(),
        treinos = TreinoRepository() {
    sessao = SessaoRepository(usuarios);
  }

  static final AppState instance = AppState._();

  final UsuarioRepository usuarios;
  final TreinoRepository treinos;
  late final SessaoRepository sessao;
}
