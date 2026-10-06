import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/papel.dart';
import '../models/usuario.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = AppState.instance.sessao;

    return AnimatedBuilder(
      animation: sessao,
      builder: (context, _) {
        final usuario = sessao.usuarioAtual;
        if (usuario == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (usuario.papel == Papel.personal) {
          return _PersonalHome(nome: usuario.nome);
        }
        return _AlunoHome(nome: usuario.nome);
      },
    );
  }
}

class _PersonalHome extends StatelessWidget {
  final String nome;

  const _PersonalHome({required this.nome});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final alunos = AppState.instance.usuarios.alunos;
    final alunosComTreinos = alunos
        .where((aluno) => aluno.agenda.any((dia) => dia.treinoId != null))
        .length;
    final alunosSemTreinos = alunos.length - alunosComTreinos;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitLog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppState.instance.sessao.logout();
              context.go('/login');
            },
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 0,
              color: colors.surface.withValues(alpha: 0.94),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colors.primary,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, $nome!',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gerencie seus alunos e treinos.',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_outline,
                    value: '${alunos.length}',
                    label: 'Total de alunos',
                    colors: colors,
                    onTap: () => _mostrarAlunos(
                      context,
                      titulo: 'Todos os alunos',
                      alunos: alunos,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.assignment_turned_in_outlined,
                    value: '$alunosComTreinos',
                    label: 'Total com treinos',
                    colors: colors,
                    onTap: () => _mostrarAlunos(
                      context,
                      titulo: 'Alunos com treinos',
                      alunos: alunos
                          .where(
                            (aluno) => aluno.agenda.any(
                              (dia) => dia.treinoId != null,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.assignment_late_outlined,
                    value: '$alunosSemTreinos',
                    label: 'Total sem treinos',
                    colors: colors,
                    onTap: () => _mostrarAlunos(
                      context,
                      titulo: 'Alunos sem treinos',
                      alunos: alunos
                          .where(
                            (aluno) => !aluno.agenda.any(
                              (dia) => dia.treinoId != null,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Acesso rápido',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.fitness_center,
              title: 'Treinos',
              subtitle: 'Cadastrar, editar e remover treinos',
              onTap: () => context.go('/treinos'),
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.people,
              title: 'Alunos',
              subtitle: 'Cadastro e atribuição de treinos por dia',
              onTap: () => context.go('/alunos'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlunoHome extends StatelessWidget {
  final String nome;

  const _AlunoHome({required this.nome});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitLog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppState.instance.sessao.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Olá, $nome',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Veja sua semana de treinos. Dias sem treino são de descanso.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          _MenuCard(
            icon: Icons.calendar_view_week,
            title: 'Meu treino semanal',
            subtitle: 'Visualizar exercícios prescritos pelo personal',
            onTap: () => context.go('/meu-treino'),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        child: Icon(icon, color: colors.onPrimaryContainer),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: colors.primary),
      onTap: onTap,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, color: colors.primary, size: 24),
              const SizedBox(height: 12),
              Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _mostrarAlunos(
  BuildContext context, {
  required String titulo,
  required List<Usuario> alunos,
}) {
  showDialog<void>(
    context: context,
    builder: (context) {
      final colors = Theme.of(context).colorScheme;

      return AlertDialog(
        title: Text(titulo),
        content: SizedBox(
          width: 420,
          child: alunos.isEmpty
              ? _EmptyStudentsState(colors: colors)
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: alunos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final aluno = alunos[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: colors.primaryContainer,
                        child: Text(
                          aluno.nome.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: colors.onPrimaryContainer),
                        ),
                      ),
                      title: Text(aluno.nome),
                      subtitle: Text(aluno.email),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      );
    },
  );
}

class _EmptyStudentsState extends StatelessWidget {
  final ColorScheme colors;

  const _EmptyStudentsState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum aluno encontrado.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
