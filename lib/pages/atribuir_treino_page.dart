import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';
import '../models/dia_aluno.dart';
import '../models/dias_semana.dart';

class AtribuirTreinoPage extends StatefulWidget {
  final String alunoId;

  const AtribuirTreinoPage({super.key, required this.alunoId});

  @override
  State<AtribuirTreinoPage> createState() => _AtribuirTreinoPageState();
}

class _AtribuirTreinoPageState extends State<AtribuirTreinoPage> {
  @override
  Widget build(BuildContext context) {
    final usuariosRepo = AppState.instance.usuarios;
    final treinosRepo = AppState.instance.treinos;

    return AnimatedBuilder(
      animation: Listenable.merge([usuariosRepo, treinosRepo]),
      builder: (context, _) {
        final aluno = usuariosRepo.buscarPorId(widget.alunoId);
        final treinos = treinosRepo.treinos;
        final colors = Theme.of(context).colorScheme;

        if (aluno == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Atribuir Treino'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/personal/home');
                  }
                },
              ),
            ),
            body: const EmptyStateWidget(
              mensagem: 'Aluno não encontrado.',
              icon: AppIcons.error,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Agenda — ${aluno.nome}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/personal/home');
                }
              },
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: DiasSemana.values.length,
            itemBuilder: (context, index) {
              final diaEnum = DiasSemana.values[index];

              DiaAluno? itemAgenda;
              for (final item in aluno.agenda) {
                if (item.diaSemana == diaEnum.name || item.diaSemana == diaEnum) {
                  itemAgenda = item;
                  break;
                }
              }

              final treinoIdAtual = itemAgenda?.treinoId;
              final treinoAtual = treinoIdAtual != null
                  ? treinosRepo.buscarPorId(treinoIdAtual)
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: colors.surface.withOpacity(0.94),
                child: ListTile(
                  title: Text(
                    diaEnum.rotulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    treinoAtual != null ? treinoAtual.titulo : 'Dia de Descanso',
                    style: TextStyle(
                      color: treinoAtual != null ? colors.primary : Colors.grey,
                      fontWeight:
                          treinoAtual != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: DropdownButton<String?>(
                    value: treinos.any((t) => t.id == treinoIdAtual)
                        ? treinoIdAtual
                        : null,
                    hint: const Text('Selecione'),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Descanso'),
                      ),
                      ...treinos.map(
                        (t) => DropdownMenuItem<String?>(
                          value: t.id,
                          child: Text(t.titulo),
                        ),
                      ),
                    ],
                    onChanged: (novoTreinoId) async {
                      await usuariosRepo.atribuirTreinoAgenda(
                        alunoId: aluno.id,
                        diaSemana: diaEnum,
                        treinoId: novoTreinoId,
                      );
                      if (context.mounted) {
                        AppFunctions.mostrarSnackBar(
                          context,
                          'Agenda atualizada para ${diaEnum.rotulo}.',
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}