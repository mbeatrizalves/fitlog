import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/dias_semana.dart';

class MeuTreinoPage extends StatelessWidget {
  const MeuTreinoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = AppState.instance.sessao;
    final usuariosRepo = AppState.instance.usuarios;
    final treinosRepo = AppState.instance.treinos;

    return AnimatedBuilder(
      animation: Listenable.merge([sessao, usuariosRepo, treinosRepo]),
      builder: (context, _) {
        final usuario = sessao.usuarioAtual;
        if (usuario == null || !usuario.isAluno) {
          return const Scaffold(
            body: Center(child: Text('Acesso permitido apenas para alunos.')),
          );
        }

        // Recarrega o aluno do repositório para refletir atualizações.
        final aluno = usuariosRepo.buscarPorId(usuario.id) ?? usuario;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meu treino semanal'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
          ),
          body: ListView.separated(
            itemCount: aluno.agenda.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final dia = aluno.agenda[index];
              final treino = dia.treinoId != null
                  ? treinosRepo.buscarPorId(dia.treinoId!)
                  : null;
              final rotulo = rotulosDiasSemana[dia.diaSemana] ?? dia.diaSemana;
              final temTreino = treino != null;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      temTreino ? Colors.deepOrange.shade100 : Colors.grey.shade200,
                  child: Icon(
                    temTreino ? Icons.fitness_center : Icons.weekend,
                    color: temTreino ? Colors.deepOrange : Colors.grey,
                  ),
                ),
                title: Text(
                  temTreino ? '$rotulo — ${treino.titulo}' : '$rotulo — Descanso',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(temTreino ? treino.focado : 'Nenhum treino atribuído'),
                trailing: temTreino ? const Icon(Icons.chevron_right) : null,
                onTap: temTreino
                    ? () => context.go('/meu-treino/${dia.diaSemana}')
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}
