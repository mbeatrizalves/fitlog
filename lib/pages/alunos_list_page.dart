import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';

class AlunosListPage extends StatelessWidget {
  const AlunosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuariosRepo = AppState.instance.usuarios;

    return AnimatedBuilder(
      animation: usuariosRepo,
      builder: (context, _) {
        final alunos = usuariosRepo.alunos;
        final colors = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Alunos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
          ),
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer,
                  colors.surface,
                  colors.secondaryContainer.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: alunos.isEmpty
                ? _EmptyStudentsState(colors: colors)
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Alunos acompanhados',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Consulte os alunos e organize seus treinos semanais.',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                      _StudentsSummary(
                        count: alunos.length,
                        colors: colors,
                      ),
                      const SizedBox(height: 20),
                      ...alunos.map(
                        (aluno) {
                          final diasComTreino = aluno.agenda
                              .where((dia) => dia.treinoId != null)
                              .length;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StudentCard(
                              name: aluno.nome,
                              email: aluno.email,
                              trainingDays: diasComTreino,
                              colors: colors,
                              onTap: () => context.go('/alunos/${aluno.id}'),
                              onDelete: () {
                                usuariosRepo.removerAluno(aluno.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Aluno "${aluno.nome}" removido.',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            tooltip: 'Novo aluno',
            onPressed: () => context.go('/alunos/novo'),
            child: const Icon(Icons.person_add),
          ),
        );
      },
    );
  }
}

class _StudentsSummary extends StatelessWidget {
  final int count;
  final ColorScheme colors;

  const _StudentsSummary({
    required this.count,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: colors.surface.withValues(alpha: 0.94),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Icon(Icons.people, color: colors.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Text(
              '$count aluno(s) cadastrado(s)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final int trainingDays;
  final ColorScheme colors;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StudentCard({
    required this.name,
    required this.email,
    required this.trainingDays,
    required this.colors,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return Card(
      elevation: 0,
      color: colors.surface.withValues(alpha: 0.94),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colors.primary,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          trainingDays > 0
                              ? Icons.event_available
                              : Icons.event_busy,
                          size: 16,
                          color: trainingDays > 0
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trainingDays > 0
                              ? '$trainingDays dia(s) com treino'
                              : 'Nenhum treino atribuído',
                          style: TextStyle(
                            fontSize: 12,
                            color: trainingDays > 0
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.chevron_right, color: colors.primary),
                  IconButton(
                    tooltip: 'Excluir aluno',
                    icon: Icon(Icons.delete_outline, color: colors.error),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStudentsState extends StatelessWidget {
  final ColorScheme colors;

  const _EmptyStudentsState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 64, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Nenhum aluno cadastrado.',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre o primeiro aluno usando o botão +.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
