import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';

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
        final colors = Theme.of(context).colorScheme;

        if (aluno == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Aluno'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/personal/home');
                  }
                },
              ),
            ),
            body: const EmptyStateWidget(
              mensagem: 'Aluno não encontrado.',
              icon: AppIcons.error,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(aluno.nome),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/personal/home');
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(AppIcons.edit),
                tooltip: 'Editar Aluno',
                onPressed: () => context.go('/alunos/$alunoId/editar'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: colors.secondaryContainer.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aluno.nome,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(aluno.email),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agenda Semanal',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(AppIcons.edit, size: 18),
                    label: const Text('Atribuir Treino'),
                    onPressed: () =>
                        context.go('/alunos/$alunoId/atribuir-treino'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                color: colors.surface.withOpacity(0.94),
                child: Column(
                  children: aluno.agenda.map((dia) {
                    final treino = dia.treinoId != null
                        ? treinosRepo.buscarPorId(dia.treinoId!)
                        : null;
                    return ListTile(
                      title: Text(dia.diaSemana),
                      subtitle: Text(
                        treino?.titulo ?? 'Descanso',
                        style: TextStyle(
                          color: treino != null ? colors.primary : Colors.grey,
                        ),
                      ),
                      trailing: treino != null
                          ? const Icon(Icons.chevron_right)
                          : null,
                      onTap: treino != null
                          ? () => context.go(
                                '/treinos/${treino.id}?somenteLeitura=true',
                              )
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}