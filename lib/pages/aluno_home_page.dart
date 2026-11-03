import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';
import '../models/dia_aluno.dart';

class AlunoHomePage extends StatelessWidget {
  const AlunoHomePage({super.key});

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

        final aluno = usuariosRepo.buscarPorId(usuario.id) ?? usuario;

        return Scaffold(
          appBar: AppBar(
            title: Text('Agenda de ${aluno.nome}'),
            actions: [
              IconButton(
                icon: const Icon(AppIcons.logout),
                tooltip: 'Sair',
                onPressed: () async {
                  final confirmou = await AppFunctions.confirmarAcao(
                    context,
                    titulo: 'Sair da Conta',
                    mensagem: 'Deseja encerrar sua sessão?',
                  );
                  if (confirmou && context.mounted) {
                    sessao.logout();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: aluno.agenda.map((dia) {
              final treino = dia.treinoId != null
                  ? treinosRepo.buscarPorId(dia.treinoId!)
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    treino != null ? AppIcons.workout : AppIcons.rest,
                    color: treino != null ? Colors.deepOrange : Colors.grey,
                  ),
                  title: Text(
                    dia.diaSemana,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(treino?.titulo ?? 'Dia de Descanso'),
                  trailing: treino != null ? const Icon(Icons.chevron_right) : null,
                  onTap: treino != null
                      ? () => context.go('/treinos/${treino.id}?somenteLeitura=true')
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}