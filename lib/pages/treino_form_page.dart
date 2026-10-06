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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdicao ? 'Editar Treino' : 'Novo Treino',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
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
                        _FormHeader(
                          icon: Icons.fitness_center,
                          title: isEdicao ? 'Editar treino' : 'Novo treino',
                          subtitle: isEdicao
                              ? 'Atualize as informações deste treino.'
                              : 'Cadastre um treino para seus alunos.',
                          colors: colors,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          initialValue: _titulo,
                          decoration: const InputDecoration(
                            labelText: 'Título do treino',
                            hintText: 'Ex: Treino A',
                            prefixIcon: Icon(Icons.title),
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
                            labelText: 'Foco do treino',
                            hintText: 'Ex: Peito e Tríceps',
                            prefixIcon: Icon(Icons.track_changes),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o foco do treino.';
                            }
                            return null;
                          },
                          onSaved: (value) => _focado = value!,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _salvar,
                            icon: Icon(isEdicao ? Icons.save : Icons.add),
                            label: Text(
                              isEdicao ? 'Salvar alterações' : 'Criar treino',
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

class _FormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colors;

  const _FormHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: colors.primary,
          child: Icon(icon, color: colors.onPrimary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
