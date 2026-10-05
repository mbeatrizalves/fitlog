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
        _existente = treino.exercicios.firstWhere((e) => e.id == widget.exercicioId);
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
        content: Text(_existente != null ? 'Exercício atualizado.' : 'Exercício adicionado.'),
      ),
    );
    context.go('/treinos/${widget.treinoId}');
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = _existente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Exercício' : 'Adicionar Exercício'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/treinos/${widget.treinoId}'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _nome,
                decoration: const InputDecoration(
                  labelText: 'Nome do Exercício',
                  border: OutlineInputBorder(),
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
                  labelText: 'Grupo Muscular (ex: Peitoral, Costas)',
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
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
                  labelText: 'Repetições / Tempo (Segundos)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
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
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value.replaceAll(',', '.')) == null ||
                      double.parse(value.replaceAll(',', '.')) < 0) {
                    return 'Informe uma carga válida.';
                  }
                  return null;
                },
                onSaved: (value) => _carga = double.parse(value!.replaceAll(',', '.')),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _salvarFormulario,
                child: Text(
                  isEdicao ? 'Salvar Alterações' : 'Adicionar Exercício',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
