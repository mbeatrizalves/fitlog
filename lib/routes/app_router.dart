import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../pages/aluno_detalhe_page.dart';
import '../pages/aluno_form_page.dart';
import '../pages/aluno_home_page.dart';
import '../pages/atribuir_treino_page.dart';
import '../pages/exercicio_form_page.dart';
import '../pages/login_page.dart';
import '../pages/personal_home_page.dart';
import '../pages/treino_detalhe_page.dart';
import '../pages/treino_form_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: AppState.instance.sessao, // Essencial para atualizar as rotas ao mudar o estado de sessão
  redirect: (BuildContext context, GoRouterState state) {
    final sessao = AppState.instance.sessao;
    final estaLogado = sessao.estaLogado;
    final ehPersonal = sessao.ehPersonal;
    final indoParaLogin = state.matchedLocation == '/login';

    // Se não estiver logado e tentar acessar outra rota, redireciona para login
    if (!estaLogado && !indoParaLogin) return '/login';

    // Se estiver logado e for para a tela de login, redireciona de acordo com o perfil
    if (estaLogado && indoParaLogin) {
      return ehPersonal ? '/personal/home' : '/aluno/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/aluno/home',
      builder: (context, state) => const AlunoHomePage(),
    ),
    GoRoute(
      path: '/personal/home',
      builder: (context, state) => const PersonalHomePage(),
    ),
    GoRoute(
      path: '/alunos/novo',
      builder: (context, state) => const AlunoFormPage(),
    ),
    GoRoute(
      path: '/alunos/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AlunoDetalhePage(alunoId: id);
      },
    ),
    GoRoute(
      path: '/alunos/:id/editar',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AlunoFormPage(alunoId: id);
      },
    ),
    GoRoute(
      path: '/alunos/:id/atribuir-treino',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AtribuirTreinoPage(alunoId: id);
      },
    ),
    GoRoute(
      path: '/treinos/novo',
      builder: (context, state) => const TreinoFormPage(),
    ),
    GoRoute(
      path: '/treinos/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final somenteLeitura = state.uri.queryParameters['somenteLeitura'] == 'true';
        return TreinoDetalhePage(
          treinoId: id,
          somenteLeitura: somenteLeitura,
        );
      },
    ),
    GoRoute(
      path: '/treinos/:id/editar',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TreinoFormPage(treinoId: id);
      },
    ),
    GoRoute(
      path: '/treinos/:id/exercicios/novo',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ExercicioFormPage(treinoId: id);
      },
    ),
  ],
);