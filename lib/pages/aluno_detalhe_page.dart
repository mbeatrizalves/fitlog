import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/dias_semana.dart';

class AlunoDetalhePage extends StatelessWidget {
  final String alunoId;

  const AlunoDetalhePage({super.key, required this.alunoId});

  @override
  Widget build(BuildContext context) {
    final usuariosRepo = AppState.instance.usuarios;
    final treinosRepo = AppState.instance.treinos;

    return AnimatedBuilder(
      animation: Listenable.merge([usuariosRepo, treinosRepo]),
      builder: (context, _) {
        final aluno = usuariosRepo.buscarPorId(alunoId);

        if (aluno == null || !aluno.isAluno) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Aluno'),
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: Text('Aluno não encontrado.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(aluno.nome),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/alunos'),
            ),
            actions: [
              IconButton(
                tooltip: 'Editar aluno',
                icon: const Icon(Icons.edit),
                onPressed: () => context.go('/alunos/$alunoId/editar'),
              ),
            ],
          ),
          body: ListView(
            children: [
              ListTile(
                title: const Text('E-mail'),
                subtitle: Text(aluno.email),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Agenda semanal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Selecione um treino para cada dia. Deixe vazio para descanso.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              ...aluno.agenda.map((dia) {
                final treino = dia.treinoId != null
                    ? treinosRepo.buscarPorId(dia.treinoId!)
                    : null;
                final rotulo = rotulosDiasSemana[dia.diaSemana] ?? dia.diaSemana;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: treino != null
                        ? Colors.deepOrange.shade100
                        : Colors.grey.shade200,
                    child: Icon(
                      treino != null ? Icons.fitness_center : Icons.weekend,
                      color: treino != null ? Colors.deepOrange : Colors.grey,
                    ),
                  ),
                  title: Text(rotulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(treino?.titulo ?? 'Descanso'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/alunos/$alunoId/dias/${dia.diaSemana}'),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
