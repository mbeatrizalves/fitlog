import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/papel.dart';
import '../pages/aluno_detalhe_page.dart';
import '../pages/aluno_form_page.dart';
import '../pages/alunos_list_page.dart';
import '../pages/atribuir_treino_page.dart';
import '../pages/exercicio_form_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/meu_treino_detalhe_page.dart';
import '../pages/meu_treino_page.dart';
import '../pages/treino_detalhe_page.dart';
import '../pages/treino_form_page.dart';
import '../pages/treinos_list_page.dart';

GoRouter criarAppRouter() {
  final sessao = AppState.instance.sessao;

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: sessao,
    redirect: (context, state) {
      final logado = sessao.estaLogado;
      final indoParaLogin = state.matchedLocation == '/login';
      final usuario = sessao.usuarioAtual;
      final path = state.matchedLocation;

      if (!logado && !indoParaLogin) {
        return '/login';
      }

      if (logado && indoParaLogin) {
        return '/';
      }

      if (!logado) return null;

      final isPersonal = usuario!.papel == Papel.personal;
      final isAluno = usuario.papel == Papel.aluno;

      final rotasPersonal = path.startsWith('/treinos') || path.startsWith('/alunos');
      final rotasAluno = path.startsWith('/meu-treino');

      if (isAluno && rotasPersonal) {
        return '/';
      }
      if (isPersonal && rotasAluno) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/treinos',
        builder: (context, state) => const TreinosListPage(),
      ),
      GoRoute(
        path: '/treinos/novo',
        builder: (context, state) => const TreinoFormPage(),
      ),
      GoRoute(
        path: '/treinos/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TreinoDetalhePage(treinoId: id);
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
      GoRoute(
        path: '/treinos/:id/exercicios/:exercicioId',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final exercicioId = state.pathParameters['exercicioId']!;
          return ExercicioFormPage(treinoId: id, exercicioId: exercicioId);
        },
      ),
      GoRoute(
        path: '/alunos',
        builder: (context, state) => const AlunosListPage(),
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
        path: '/alunos/:id/dias/:dia',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final dia = state.pathParameters['dia']!;
          return AtribuirTreinoPage(alunoId: id, diaSemana: dia);
        },
      ),
      GoRoute(
        path: '/meu-treino',
        builder: (context, state) => const MeuTreinoPage(),
      ),
      GoRoute(
        path: '/meu-treino/:dia',
        builder: (context, state) {
          final dia = state.pathParameters['dia']!;
          return MeuTreinoDetalhePage(diaSemana: dia);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error?.toString() ?? 'Rota inválida'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );
}
