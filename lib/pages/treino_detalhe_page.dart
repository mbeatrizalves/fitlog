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

        if (treino == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Treino'),
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: Text('Treino não encontrado.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(treino.titulo),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  treino.focado,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: treino.exercicios.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum exercício cadastrado neste treino.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: treino.exercicios.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final exercicio = treino.exercicios[index];
                          return ListTile(
                            title: Text(
                              exercicio.nome,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Grupo: ${exercicio.grupoMuscular} | Séries: ${exercicio.series} | '
                              'Reps: ${exercicio.repeticoes} | Carga: ${exercicio.carga}kg',
                            ),
                            trailing: somenteLeitura
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          context.go(
                                            '/treinos/$treinoId/exercicios/${exercicio.id}',
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          repositorio.removerExercicio(treinoId, exercicio.id);
                                        },
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: somenteLeitura
              ? null
              : FloatingActionButton(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                  onPressed: () => context.go('/treinos/$treinoId/exercicios/novo'),
                ),
        );
      },
    );
  }
}
