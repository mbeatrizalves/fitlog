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

    return Scaffold(
      appBar: AppBar(
        title: Text('Atribuir — $rotulo'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/alunos/${widget.alunoId}'),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(
              _treinoSelecionado == null
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: Colors.deepOrange,
            ),
            title: const Text('Descanso (sem treino)'),
            selected: _treinoSelecionado == null,
            onTap: () => setState(() => _treinoSelecionado = null),
          ),
          const Divider(height: 1),
          ...treinos.map(
            (treino) => ListTile(
              leading: Icon(
                _treinoSelecionado == treino.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: Colors.deepOrange,
              ),
              title: Text(treino.titulo),
              subtitle: Text(treino.focado),
              selected: _treinoSelecionado == treino.id,
              onTap: () => setState(() => _treinoSelecionado = treino.id),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _salvar,
              child: const Text('Salvar atribuição', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
