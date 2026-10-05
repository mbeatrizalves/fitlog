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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Alunos'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
          ),
          body: alunos.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum aluno cadastrado.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: alunos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final aluno = alunos[index];
                    final diasComTreino =
                        aluno.agenda.where((d) => d.treinoId != null).length;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepOrange.shade100,
                        child: const Icon(Icons.person, color: Colors.deepOrange),
                      ),
                      title: Text(
                        aluno.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${aluno.email} - $diasComTreino dia(s) com treino'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          usuariosRepo.removerAluno(aluno.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Aluno "${aluno.nome}" removido.')),
                          );
                        },
                      ),
                      onTap: () => context.go('/alunos/${aluno.id}'),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            onPressed: () => context.go('/alunos/novo'),
            child: const Icon(Icons.person_add),
          ),
        );
      },
    );
  }
}
