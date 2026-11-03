import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';

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
    final treinosRepo = AppState.instance.treinos;

    return AnimatedBuilder(
      animation: treinosRepo,
      builder: (context, _) {
        final treino = treinosRepo.buscarPorId(treinoId);

        if (treino == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Treino')),
            body: const EmptyStateWidget(
              mensagem: 'Treino não encontrado.',
              icon: AppIcons.error,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(treino.titulo),
            actions: [
              if (!somenteLeitura)
                IconButton(
                  icon: const Icon(AppIcons.add),
                  tooltip: 'Adicionar Exercício',
                  onPressed: () => context.go('/treinos/$treinoId/exercicios/novo'),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foco: ${treino.focado}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (treino.descricao.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(treino.descricao),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Exercícios',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (treino.exercicios.isEmpty)
                const EmptyStateWidget(
                  mensagem: 'Nenhum exercício cadastrado para este treino.',
                  icon: AppIcons.exercise,
                )
              else
                ...treino.exercicios.map((ex) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(AppIcons.exercise),
                      ),
                      title: Text(
                        ex.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${ex.series} séries x ${ex.repeticoes} reps${ex.carga != null ? ' (${ex.carga} kg)' : ''}',
                      ),
                      trailing: !somenteLeitura
                          ? IconButton(
                              icon: const Icon(AppIcons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmou = await AppFunctions.confirmarAcao(
                                  context,
                                  titulo: 'Remover Exercício',
                                  mensagem: 'Deseja remover "${ex.nome}"?',
                                );
                                if (confirmou && context.mounted) {
                                  await treinosRepo.removerExercicio(
                                    treino.id,
                                    ex.id,
                                  );
                                  AppFunctions.mostrarSnackBar(
                                    context,
                                    'Exercício removido.',
                                  );
                                }
                              },
                            )
                          : null,
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}