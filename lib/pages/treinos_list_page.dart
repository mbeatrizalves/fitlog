import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';

class TreinosListPage extends StatelessWidget {
  const TreinosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final treinosRepo = AppState.instance.treinos;
    final usuariosRepo = AppState.instance.usuarios;

    return AnimatedBuilder(
      animation: Listenable.merge([treinosRepo, usuariosRepo]),
      builder: (context, _) {
        final treinos = treinosRepo.treinos;
        final colors = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Treinos',
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
            child: treinos.isEmpty
                ? _EmptyWorkoutsState(colors: colors)
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Biblioteca de treinos',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Organize e acompanhe os treinos dos seus alunos.',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                      _WorkoutSummary(
                        count: treinos.length,
                        colors: colors,
                      ),
                      const SizedBox(height: 20),
                      ...treinos.map(
                        (treino) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _WorkoutCard(
                            title: treino.titulo,
                            focus: treino.focado,
                            exerciseCount: treino.exercicios.length,
                            colors: colors,
                            onTap: () => context.go('/treinos/${treino.id}'),
                            onDelete: () {
                              usuariosRepo.limparReferenciasTreino(treino.id);
                              treinosRepo.removerTreino(treino.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Treino "${treino.titulo}" removido.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            tooltip: 'Novo treino',
            onPressed: () => context.go('/treinos/novo'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _WorkoutSummary extends StatelessWidget {
  final int count;
  final ColorScheme colors;

  const _WorkoutSummary({
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
              child: Icon(
                Icons.fitness_center,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$count treino(s) cadastrado(s)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final String title;
  final String focus;
  final int exerciseCount;
  final ColorScheme colors;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WorkoutCard({
    required this.title,
    required this.focus,
    required this.exerciseCount,
    required this.colors,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Icon(Icons.fitness_center, color: colors.onPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      focus,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$exerciseCount exercício(s)',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
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
                    tooltip: 'Excluir treino',
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

class _EmptyWorkoutsState extends StatelessWidget {
  final ColorScheme colors;

  const _EmptyWorkoutsState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum treino cadastrado.',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie o primeiro treino usando o botão +.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
