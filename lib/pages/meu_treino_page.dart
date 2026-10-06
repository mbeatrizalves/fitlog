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
        final colors = Theme.of(context).colorScheme;
        final diasComTreino = aluno.agenda
            .where(
              (dia) =>
                  dia.treinoId != null &&
                  treinosRepo.buscarPorId(dia.treinoId!) != null,
            )
            .length;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Meu treino semanal',
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Sua semana de treinos',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Confira seus treinos e dias de descanso.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                _WeekSummary(
                  trainingDays: diasComTreino,
                  restDays: aluno.agenda.length - diasComTreino,
                  colors: colors,
                ),
                const SizedBox(height: 24),
                Text(
                  'Agenda semanal',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...aluno.agenda.map((dia) {
                  final treino = dia.treinoId != null
                      ? treinosRepo.buscarPorId(dia.treinoId!)
                      : null;
                  final rotulo =
                      rotulosDiasSemana[dia.diaSemana] ?? dia.diaSemana;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DayWorkoutCard(
                      dayLabel: rotulo,
                      workoutTitle: treino?.titulo,
                      workoutFocus: treino?.focado,
                      colors: colors,
                      onTap: treino == null
                          ? null
                          : () => context.go('/meu-treino/${dia.diaSemana}'),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeekSummary extends StatelessWidget {
  final int trainingDays;
  final int restDays;
  final ColorScheme colors;

  const _WeekSummary({
    required this.trainingDays,
    required this.restDays,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: colors.surface.withValues(alpha: 0.94),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                icon: Icons.fitness_center,
                value: '$trainingDays',
                label: 'Dias de treino',
                color: colors.primary,
              ),
            ),
            Container(
              height: 48,
              width: 1,
              color: colors.outlineVariant,
            ),
            Expanded(
              child: _SummaryItem(
                icon: Icons.weekend_outlined,
                value: '$restDays',
                label: 'Dias de descanso',
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }
}

class _DayWorkoutCard extends StatelessWidget {
  final String dayLabel;
  final String? workoutTitle;
  final String? workoutFocus;
  final ColorScheme colors;
  final VoidCallback? onTap;

  const _DayWorkoutCard({
    required this.dayLabel,
    required this.workoutTitle,
    required this.workoutFocus,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasWorkout = workoutTitle != null;

    return Card(
      elevation: 0,
      color: colors.surface.withValues(alpha: 0.94),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: hasWorkout
                    ? colors.primaryContainer
                    : colors.surfaceContainerHighest,
                child: Icon(
                  hasWorkout ? Icons.fitness_center : Icons.weekend_outlined,
                  color: hasWorkout
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workoutTitle ?? 'Descanso',
                      style: TextStyle(
                        color: hasWorkout
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                        fontWeight:
                            hasWorkout ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (workoutFocus != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        workoutFocus!,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasWorkout) Icon(Icons.chevron_right, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
