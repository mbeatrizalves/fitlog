import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';

class TreinoDetalhePage extends StatelessWidget {
  final String treinoId;
  final bool somenteLeitura;

  const TreinoDetalhePage({
    super.key,
    required this.treinoId,
    this.somenteLeitura = false,
  });

  @override
  Widget build(BuildContext context) {
    final repositorio = AppState.instance.treinos;

    return AnimatedBuilder(
      animation: repositorio,
      builder: (context, _) {
        final treino = repositorio.buscarPorId(treinoId);
        final colors = Theme.of(context).colorScheme;

        if (treino == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Treino',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
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
              child: Center(
                child: Text(
                  'Treino não encontrado.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              treino.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (somenteLeitura) {
                  context.go('/meu-treino');
                } else {
                  context.go('/treinos');
                }
              },
            ),
            actions: [
              if (!somenteLeitura)
                IconButton(
                  tooltip: 'Editar treino',
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/treinos/$treinoId/editar'),
                ),
            ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Card(
                    elevation: 0,
                    color: colors.surface.withValues(alpha: 0.94),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: colors.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: colors.primary,
                            child: Icon(
                              Icons.fitness_center,
                              color: colors.onPrimary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  treino.titulo,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  treino.focado,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    'Exercícios do treino',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: treino.exercicios.isEmpty
                      ? _EmptyExercisesState(colors: colors)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: treino.exercicios.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final exercicio = treino.exercicios[index];
                            return _ExerciseCard(
                              name: exercicio.nome,
                              muscleGroup: exercicio.grupoMuscular,
                              series: exercicio.series,
                              repetitions: exercicio.repeticoes,
                              load: exercicio.carga,
                              colors: colors,
                              readOnly: somenteLeitura,
                              onEdit: () {
                                context.go(
                                  '/treinos/$treinoId/exercicios/${exercicio.id}',
                                );
                              },
                              onDelete: () {
                                repositorio.removerExercicio(
                                  treinoId,
                                  exercicio.id,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: somenteLeitura
              ? null
              : FloatingActionButton(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  tooltip: 'Adicionar exercício',
                  child: const Icon(Icons.add),
                  onPressed: () =>
                      context.go('/treinos/$treinoId/exercicios/novo'),
                ),
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String name;
  final String muscleGroup;
  final int series;
  final int repetitions;
  final double load;
  final ColorScheme colors;
  final bool readOnly;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseCard({
    required this.name,
    required this.muscleGroup,
    required this.series,
    required this.repetitions,
    required this.load,
    required this.colors,
    required this.readOnly,
    required this.onEdit,
    required this.onDelete,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.directions_run,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
                      Text(
                        muscleGroup,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (!readOnly) ...[
                  IconButton(
                    tooltip: 'Editar exercício',
                    icon: Icon(Icons.edit_outlined, color: colors.primary),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Excluir exercício',
                    icon: Icon(Icons.delete_outline, color: colors.error),
                    onPressed: onDelete,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ExerciseInfoChip(
                  icon: Icons.repeat,
                  label: '$series séries',
                  colors: colors,
                ),
                _ExerciseInfoChip(
                  icon: Icons.format_list_numbered,
                  label: '$repetitions repetições',
                  colors: colors,
                ),
                _ExerciseInfoChip(
                  icon: Icons.fitness_center,
                  label: '${load.toStringAsFixed(1)} kg',
                  colors: colors,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colors;

  const _ExerciseInfoChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: colors.onSecondaryContainer),
      label: Text(label),
      backgroundColor: colors.secondaryContainer,
      side: BorderSide.none,
      labelStyle: TextStyle(color: colors.onSecondaryContainer),
    );
  }
}

class _EmptyExercisesState extends StatelessWidget {
  final ColorScheme colors;

  const _EmptyExercisesState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.playlist_add,
              size: 64,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum exercício cadastrado.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione exercícios usando o botão +.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
