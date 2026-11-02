import 'repositories/sessao_repository.dart';
import 'repositories/treino_repository.dart';
import 'repositories/usuario_repository.dart';
import 'database/app_database.dart';

/// Estado compartilhado da aplicação (repositórios em memória).
class AppState {
  AppState._()
      : usuarios = UsuarioRepository(),
        treinos = TreinoRepository() {
    sessao = SessaoRepository(usuarios);
  }

  static final AppState instance = AppState._();

  Future<void>? _initialization;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    await AppDatabase.instance.database;
    final usuarios = await AppDatabase.instance.carregarUsuarios();
    if (usuarios.isEmpty) {
      await treinos.persistirDadosIniciais();
      await this.usuarios.persistirDadosIniciais();
    } else {
      await this.usuarios.carregar();
      await treinos.carregar();
    }
  }

  final UsuarioRepository usuarios;
  final TreinoRepository treinos;
  late final SessaoRepository sessao;
}
