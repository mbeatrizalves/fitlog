import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';
import '../models/dias_semana.dart';

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
            body: EmptyStateWidget(
              mensagem: 'Acesso permitido apenas para alunos.',
              icon: AppIcons.error,
            ),
          );
        }

        final aluno = usuariosRepo.buscarPorId(usuario.id) ?? usuario;
        final diasComTreino = aluno.agenda
            .where(
              (dia) =>
                  dia.treinoId != null &&
                  treinosRepo.buscarPorId(dia.treinoId!) != null,
            )
            .length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meu Treino Semanal'),
            actions: [
              IconButton(
                icon: const Icon(AppIcons.logout),
                tooltip: 'Sair',
                onPressed: () async {
                  final confirmou = await AppFunctions.confirmarAcao(
                    context,
                    titulo: 'Sair',
                    mensagem: 'Deseja encerrar sua sessão?',
                  );
                  if (confirmou) {
                    sessao.logout();
                    if (context.mounted) context.go('/login');
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Sua semana de treinos',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Confira seus treinos e dias de descanso.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Card de Resumo Semanal
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(AppIcons.workout, color: Colors.blue),
                            const SizedBox(height: 4),
                            Text(
                              '$diasComTreino',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Dias de treino', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(height: 40, width: 1, color: Colors.grey.shade300),
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(AppIcons.rest, color: Colors.grey),
                            const SizedBox(height: 4),
                            Text(
                              '${aluno.agenda.length - diasComTreino}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Dias de descanso', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                final rotulo = rotulosDiasSemana[dia.diaSemana] ?? dia.diaSemana;
                final temTreino = treino != null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: temTreino ? Colors.blue.shade50 : Colors.grey.shade100,
                      child: Icon(
                        temTreino ? AppIcons.workout : AppIcons.rest,
                        color: temTreino ? Colors.blue : Colors.grey,
                      ),
                    ),
                    title: Text(
                      rotulo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      temTreino ? (treino.titulo) : 'Dia de Descanso',
                      style: TextStyle(
                        color: temTreino ? Colors.black87 : Colors.grey,
                        fontWeight: temTreino ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: temTreino ? const Icon(Icons.chevron_right) : null,
                    onTap: temTreino
                        ? () => context.go('/treinos/${treino.id}?somenteLeitura=true')
                        : () => AppFunctions.mostrarSnackBar(
                              context,
                              '$rotulo é dia de descanso.',
                            ),
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