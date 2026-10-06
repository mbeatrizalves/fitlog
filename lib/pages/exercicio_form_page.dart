import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/exercicios.dart';

class ExercicioFormPage extends StatefulWidget {
  final String treinoId;
  final String? exercicioId;

  const ExercicioFormPage({
    super.key,
    required this.treinoId,
    this.exercicioId,
  });

  @override
  State<ExercicioFormPage> createState() => _ExercicioFormPageState();
}

class _ExercicioFormPageState extends State<ExercicioFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _nome;
  late String _grupoMuscular;
  late int _series;
  late int _repeticoes;
  late double _carga;
  Exercicio? _existente;

  @override
  void initState() {
    super.initState();
    final treino = AppState.instance.treinos.buscarPorId(widget.treinoId);
    if (widget.exercicioId != null && treino != null) {
      try {
        _existente =
            treino.exercicios.firstWhere((e) => e.id == widget.exercicioId);
      } catch (_) {
        _existente = null;
      }
    }

    _nome = _existente?.nome ?? '';
    _grupoMuscular = _existente?.grupoMuscular ?? '';
    _series = _existente?.series ?? 3;
    _repeticoes = _existente?.repeticoes ?? 10;
    _carga = _existente?.carga ?? 0.0;
  }

  void _salvarFormulario() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final novoExercicio = Exercicio(
      id: _existente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nome.trim(),
      grupoMuscular: _grupoMuscular.trim(),
      series: _series,
      repeticoes: _repeticoes,
      carga: _carga,
    );

    AppState.instance.treinos.salvarExercicio(widget.treinoId, novoExercicio);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_existente != null
            ? 'Exercício atualizado.'
            : 'Exercício adicionado.'),
      ),
    );
    context.go('/treinos/${widget.treinoId}');
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = _existente != null;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdicao ? 'Editar Exercício' : 'Adicionar Exercício',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/treinos/${widget.treinoId}'),
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
              child: Card(
                elevation: 0,
                color: colors.surface.withValues(alpha: 0.94),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ExerciseFormHeader(
                          isEdicao: isEdicao,
                          colors: colors,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          initialValue: _nome,
                          decoration: const InputDecoration(
                            labelText: 'Nome do exercício',
                            hintText: 'Ex: Supino reto',
                            prefixIcon: Icon(Icons.directions_run),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, informe o nome do exercício.';
                            }
                            return null;
                          },
                          onSaved: (value) => _nome = value!,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _grupoMuscular,
                          decoration: const InputDecoration(
                            labelText: 'Grupo muscular',
                            hintText: 'Ex: Peitoral, Costas',
                            prefixIcon: Icon(Icons.accessibility_new),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, informe o grupo muscular.';
                            }
                            return null;
                          },
                          onSaved: (value) => _grupoMuscular = value!,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _series.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Séries',
                            prefixIcon: Icon(Icons.repeat),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                int.tryParse(value) == null ||
                                int.parse(value) <= 0) {
                              return 'Informe um número válido de séries.';
                            }
                            return null;
                          },
                          onSaved: (value) => _series = int.parse(value!),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _repeticoes.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Repetições / Tempo (segundos)',
                            prefixIcon: Icon(Icons.format_list_numbered),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                int.tryParse(value) == null ||
                                int.parse(value) <= 0) {
                              return 'Informe um número válido de repetições.';
                            }
                            return null;
                          },
                          onSaved: (value) => _repeticoes = int.parse(value!),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _carga.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Carga (kg)',
                            hintText: 'Ex: 20,5',
                            prefixIcon: Icon(Icons.fitness_center),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null ||
                                double.tryParse(value.replaceAll(',', '.')) ==
                                    null ||
                                double.parse(value.replaceAll(',', '.')) < 0) {
                              return 'Informe uma carga válida.';
                            }
                            return null;
                          },
                          onSaved: (value) => _carga =
                              double.parse(value!.replaceAll(',', '.')),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _salvarFormulario,
                            icon: Icon(isEdicao ? Icons.save : Icons.add),
                            label: Text(
                              isEdicao
                                  ? 'Salvar alterações'
                                  : 'Adicionar exercício',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseFormHeader extends StatelessWidget {
  final bool isEdicao;
  final ColorScheme colors;

  const _ExerciseFormHeader({
    required this.isEdicao,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: colors.primary,
          child: Icon(
            isEdicao ? Icons.edit : Icons.add,
            color: colors.onPrimary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdicao ? 'Editar exercício' : 'Novo exercício',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                isEdicao
                    ? 'Atualize os dados deste exercício.'
                    : 'Adicione um exercício ao treino.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
