import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';

class PersonalHomePage extends StatefulWidget {
  const PersonalHomePage({super.key});

  @override
  State<PersonalHomePage> createState() => _PersonalHomePageState();
}

class _PersonalHomePageState extends State<PersonalHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Atualiza o estado da tela para alterar o ícone do FloatingActionButton ao trocar de aba
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _realizarLogout() async {
    final confirmou = await AppFunctions.confirmarAcao(
      context,
      titulo: 'Sair da Conta',
      mensagem: 'Deseja encerrar a sessão do Personal Trainer?',
    );
    if (confirmou && mounted) {
      AppState.instance.sessao.logout();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuariosRepo = AppState.instance.usuarios;
    final treinosRepo = AppState.instance.treinos;

    return AnimatedBuilder(
      animation: Listenable.merge([usuariosRepo, treinosRepo]),
      builder: (context, _) {
        final alunos = usuariosRepo.alunos;
        final treinos = treinosRepo.treinos;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Painel do Personal'),
            actions: [
              IconButton(
                icon: const Icon(AppIcons.logout),
                onPressed: _realizarLogout,
                tooltip: 'Sair',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: const Icon(AppIcons.user),
                  text: 'Alunos (${alunos.length})',
                ),
                Tab(
                  icon: const Icon(AppIcons.workout),
                  text: 'Treinos (${treinos.length})',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Aba 1: Lista de Alunos
              alunos.isEmpty
                  ? const EmptyStateWidget(
                      mensagem: 'Nenhum aluno cadastrado.',
                      icon: AppIcons.user,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: alunos.length,
                      itemBuilder: (context, index) {
                        final aluno = alunos[index];
                        final diasComTreino = aluno.agenda
                            .where((d) => d.treinoId != null)
                            .length;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => context.go('/alunos/${aluno.id}'),
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade50,
                              child: Text(
                                aluno.nome.isNotEmpty
                                    ? aluno.nome[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            title: Text(
                              aluno.nome,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${aluno.email}\n$diasComTreino dia(s) com treino',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(AppIcons.calendar,
                                      color: Colors.deepOrange),
                                  tooltip: 'Atribuir Treino',
                                  onPressed: () => context.go(
                                      '/alunos/${aluno.id}/atribuir-treino'),
                                ),
                                IconButton(
                                  icon: const Icon(AppIcons.edit,
                                      color: Colors.blue),
                                  tooltip: 'Editar Aluno',
                                  onPressed: () =>
                                      context.go('/alunos/${aluno.id}/editar'),
                                ),
                                IconButton(
                                  icon: const Icon(AppIcons.delete,
                                      color: Colors.red),
                                  tooltip: 'Excluir Aluno',
                                  onPressed: () async {
                                    final confirmou =
                                        await AppFunctions.confirmarAcao(
                                      context,
                                      titulo: 'Remover Aluno',
                                      mensagem:
                                          'Deseja remover "${aluno.nome}"?',
                                    );
                                    if (confirmou && context.mounted) {
                                      await usuariosRepo.removerAluno(aluno.id);
                                      AppFunctions.mostrarSnackBar(
                                        context,
                                        'Aluno removido.',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              // Aba 2: Lista de Treinos
              treinos.isEmpty
                  ? const EmptyStateWidget(
                      mensagem: 'Nenhum treino cadastrado.',
                      icon: AppIcons.workout,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: treinos.length,
                      itemBuilder: (context, index) {
                        final treino = treinos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => context.go('/treinos/${treino.id}'),
                            leading: const CircleAvatar(
                              child: Icon(AppIcons.workout),
                            ),
                            title: Text(
                              treino.titulo,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${treino.focado} • ${treino.exercicios.length} exercício(s)',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(AppIcons.edit,
                                      color: Colors.blue),
                                  tooltip: 'Editar Treino',
                                  onPressed: () =>
                                      context.go('/treinos/${treino.id}/editar'),
                                ),
                                IconButton(
                                  icon: const Icon(AppIcons.delete,
                                      color: Colors.red),
                                  tooltip: 'Excluir Treino',
                                  onPressed: () async {
                                    final confirmou =
                                        await AppFunctions.confirmarAcao(
                                      context,
                                      titulo: 'Remover Treino',
                                      mensagem:
                                          'Deseja remover "${treino.titulo}"?',
                                    );
                                    if (confirmou && context.mounted) {
                                      await treinosRepo.removerTreino(treino.id);
                                      usuariosRepo
                                          .limparReferenciasTreino(treino.id);
                                      AppFunctions.mostrarSnackBar(
                                        context,
                                        'Treino removido.',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (_tabController.index == 0) {
                context.go('/alunos/novo');
              } else {
                context.go('/treinos/novo');
              }
            },
            icon: Icon(
              _tabController.index == 0
                  ? Icons.person_add
                  : Icons.fitness_center,
            ),
            label: Text(
              _tabController.index == 0 ? 'Novo Aluno' : 'Novo Treino',
            ),
          ),
        );
      },
    );
  }
}