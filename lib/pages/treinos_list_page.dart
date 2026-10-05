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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Treinos'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
          ),
          body: treinos.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum treino cadastrado.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: treinos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final treino = treinos[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepOrange.shade100,
                        child: const Icon(Icons.fitness_center, color: Colors.deepOrange),
                      ),
                      title: Text(
                        treino.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${treino.focado} - ${treino.exercicios.length} exercício(s)',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          usuariosRepo.limparReferenciasTreino(treino.id);
                          treinosRepo.removerTreino(treino.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Treino "${treino.titulo}" removido.')),
                          );
                        },
                      ),
                      onTap: () => context.go('/treinos/${treino.id}'),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            onPressed: () => context.go('/treinos/novo'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
