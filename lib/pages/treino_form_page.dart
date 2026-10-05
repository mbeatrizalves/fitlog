import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/exercicios.dart';
import '../models/treino.dart';

class TreinoFormPage extends StatefulWidget {
  final String? treinoId;

  const TreinoFormPage({super.key, this.treinoId});

  @override
  State<TreinoFormPage> createState() => _TreinoFormPageState();
}

class _TreinoFormPageState extends State<TreinoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _titulo;
  late String _focado;
  late List<Exercicio> _exerciciosExistentes;

  bool get isEdicao => widget.treinoId != null;

  @override
  void initState() {
    super.initState();
    final existente = widget.treinoId != null
        ? AppState.instance.treinos.buscarPorId(widget.treinoId!)
        : null;
    _titulo = existente?.titulo ?? '';
    _focado = existente?.focado ?? '';
    _exerciciosExistentes = existente != null
        ? List<Exercicio>.from(existente.exercicios)
        : <Exercicio>[];
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final id = widget.treinoId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final treino = Treino(
      id: id,
      titulo: _titulo.trim(),
      focado: _focado.trim(),
      exercicios: _exerciciosExistentes,
    );

    AppState.instance.treinos.salvarTreino(treino);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdicao ? 'Treino atualizado.' : 'Treino criado.'),
      ),
    );
    context.go('/treinos/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Treino' : 'Novo Treino'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isEdicao) {
              context.go('/treinos/${widget.treinoId}');
            } else {
              context.go('/treinos');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _titulo,
                decoration: const InputDecoration(
                  labelText: 'Título do treino',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título do treino.';
                  }
                  return null;
                },
                onSaved: (value) => _titulo = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _focado,
                decoration: const InputDecoration(
                  labelText: 'Foco (ex: Peito e Tríceps)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o foco do treino.';
                  }
                  return null;
                },
                onSaved: (value) => _focado = value!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _salvar,
                child: Text(
                  isEdicao ? 'Salvar alterações' : 'Criar treino',
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
