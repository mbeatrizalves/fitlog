import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/papel.dart';

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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitLog'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
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
            'Gerencie treinos e a agenda dos alunos.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
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
            subtitle: 'Cadastro de alunos e atribuição de treinos por dia',
            onTap: () => context.go('/alunos'),
          ),
        ],
      ),
    );
  }
}

class _AlunoHome extends StatelessWidget {
  final String nome;

  const _AlunoHome({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitLog'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
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
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.deepOrange.shade100,
        child: Icon(icon, color: Colors.deepOrange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
