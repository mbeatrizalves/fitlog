import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/dias_semana.dart';

class AtribuirTreinoPage extends StatefulWidget {
  final String alunoId;
  final String diaSemana;

  const AtribuirTreinoPage({
    super.key,
    required this.alunoId,
    required this.diaSemana,
  });

  @override
  State<AtribuirTreinoPage> createState() => _AtribuirTreinoPageState();
}

class _AtribuirTreinoPageState extends State<AtribuirTreinoPage> {
  String? _treinoSelecionado;

  @override
  void initState() {
    super.initState();
    final aluno = AppState.instance.usuarios.buscarPorId(widget.alunoId);
    if (aluno != null) {
      for (final dia in aluno.agenda) {
        if (dia.diaSemana == widget.diaSemana) {
          _treinoSelecionado = dia.treinoId;
          break;
        }
      }
    }
  }

  void _salvar() {
    AppState.instance.usuarios.atribuirTreinoAoDia(
      widget.alunoId,
      widget.diaSemana,
      _treinoSelecionado,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _treinoSelecionado == null
              ? 'Dia marcado como descanso.'
              : 'Treino atribuído com sucesso.',
        ),
      ),
    );
    context.go('/alunos/${widget.alunoId}');
  }

  @override
  Widget build(BuildContext context) {
    final treinos = AppState.instance.treinos.treinos;
    final rotulo = rotulosDiasSemana[widget.diaSemana] ?? widget.diaSemana;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Atribuir — $rotulo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/alunos/${widget.alunoId}'),
        ),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AssignmentHeader(dayLabel: rotulo, colors: colors),
                  const SizedBox(height: 24),
                  Text(
                    'Escolha uma opção',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _AssignmentOption(
                    icon: Icons.weekend_outlined,
                    title: 'Descanso',
                    subtitle: 'Nenhum treino atribuído neste dia',
                    selected: _treinoSelecionado == null,
                    colors: colors,
                    onTap: () => setState(() => _treinoSelecionado = null),
                  ),
                  const SizedBox(height: 12),
                  ...treinos.map(
                    (treino) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AssignmentOption(
                        icon: Icons.fitness_center,
                        title: treino.titulo,
                        subtitle: treino.focado,
                        selected: _treinoSelecionado == treino.id,
                        colors: colors,
                        onTap: () => setState(
                          () => _treinoSelecionado = treino.id,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar atribuição'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignmentHeader extends StatelessWidget {
  final String dayLabel;
  final ColorScheme colors;

  const _AssignmentHeader({
    required this.dayLabel,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: colors.surface.withValues(alpha: 0.94),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colors.primary,
              child: Icon(Icons.calendar_month, color: colors.onPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agenda do aluno',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure o treino de $dayLabel.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _AssignmentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: selected
          ? colors.primaryContainer
          : colors.surface.withValues(alpha: 0.94),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    selected ? colors.primary : colors.secondaryContainer,
                child: Icon(
                  icon,
                  color: selected
                      ? colors.onPrimary
                      : colors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
