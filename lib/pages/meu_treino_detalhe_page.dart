import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/dias_semana.dart';
import 'treino_detalhe_page.dart';

class MeuTreinoDetalhePage extends StatelessWidget {
  final String diaSemana;

  const MeuTreinoDetalhePage({super.key, required this.diaSemana});

  @override
  Widget build(BuildContext context) {
    final sessao = AppState.instance.sessao;
    final usuariosRepo = AppState.instance.usuarios;
    final rotulo = rotulosDiasSemana[diaSemana] ?? diaSemana;

    return AnimatedBuilder(
      animation: Listenable.merge([sessao, usuariosRepo, AppState.instance.treinos]),
      builder: (context, _) {
        final usuario = sessao.usuarioAtual;
        if (usuario == null || !usuario.isAluno) {
          return const Scaffold(
            body: Center(child: Text('Acesso permitido apenas para alunos.')),
          );
        }

        final aluno = usuariosRepo.buscarPorId(usuario.id) ?? usuario;
        String? treinoId;
        for (final dia in aluno.agenda) {
          if (dia.diaSemana == diaSemana) {
            treinoId = dia.treinoId;
            break;
          }
        }

        if (treinoId == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(rotulo),
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/meu-treino'),
              ),
            ),
            body: const Center(
              child: Text(
                'Dia de descanso — nenhum treino atribuído.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return TreinoDetalhePage(
          treinoId: treinoId,
          somenteLeitura: true,
        );
      },
    );
  }
}
