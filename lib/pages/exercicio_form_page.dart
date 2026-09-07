import 'package:flutter/material.dart';
import '../models/exercicios.dart';
import '../repositories/treino_repository.dart';

class ExercicioFormPage extends StatefulWidget {
  final String diaSemana;
  final TreinoRepository repositorio;
  final Exercicio? exercicioExistente;

  const ExercicioFormPage({
    super.key,
    required this.diaSemana,
    required this.repositorio,
    this.exercicioExistente,
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

  @override
  void initState() {
    super.initState();
    _nome = widget.exercicioExistente?.nome ?? '';
    _grupoMuscular = widget.exercicioExistente?.grupoMuscular ?? '';
    _series = widget.exercicioExistente?.series ?? 3;
    _repeticoes = widget.exercicioExistente?.repeticoes ?? 10;
    _carga = widget.exercicioExistente?.carga ?? 0.0;
  }

  void _salvarFormulario() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final novoExercicio = Exercicio(
        id: widget.exercicioExistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nome,
        grupoMuscular: _grupoMuscular,
        series: _series,
        repeticoes: _repeticoes,
        carga: _carga,
      );

      widget.repositorio.salvarExercicio(widget.diaSemana, novoExercicio);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.exercicioExistente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Exercício' : 'Adicionar Exercício'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _nome,
                decoration: const InputDecoration(labelText: 'Nome do Exercício'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o nome do exercício.';
                  }
                  return null;
                },
                onSaved: (value) => _nome = value!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _grupoMuscular,
                decoration: const InputDecoration(labelText: 'Grupo Muscular (ex: Peitoral, Costas)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o grupo muscular.';
                  }
                  return null;
                },
                onSaved: (value) => _grupoMuscular = value!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _series.toString(),
                decoration: const InputDecoration(labelText: 'Séries'),
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
                decoration: const InputDecoration(labelText: 'Repetições / Tempo (Segundos)'),
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
                decoration: const InputDecoration(labelText: 'Carga (kg)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Informe uma carga válida.';
                  }
                  return null;
                },
                onSaved: (value) => _carga = double.parse(value!),
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