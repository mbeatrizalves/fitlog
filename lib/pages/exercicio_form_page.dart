import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';

class ExercicioFormPage extends StatefulWidget {
  final String treinoId;

  const ExercicioFormPage({super.key, required this.treinoId});

  @override
  State<ExercicioFormPage> createState() => _ExercicioFormPageState();
}

class _ExercicioFormPageState extends State<ExercicioFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _grupoMuscularController = TextEditingController();
  final _seriesController = TextEditingController();
  final _repeticoesController = TextEditingController();
  final _cargaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _grupoMuscularController.dispose();
    _seriesController.dispose();
    _repeticoesController.dispose();
    _cargaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final series = int.tryParse(_seriesController.text.trim()) ?? 0;
    final repeticoes = int.tryParse(_repeticoesController.text.trim()) ?? 0;
    final carga = double.tryParse(_cargaController.text.trim()) ?? 0.0;

    await AppState.instance.treinos.adicionarExercicio(
      treinoId: widget.treinoId,
      nome: _nomeController.text.trim(),
      grupoMuscular: _grupoMuscularController.text.trim(),
      series: series,
      repeticoes: repeticoes,
      carga: carga,
    );

    if (mounted) {
      AppFunctions.mostrarSnackBar(
        context,
        'Exercício cadastrado com sucesso.',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Exercício'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                color: colors.secondaryContainer.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nomeController,
                        label: 'Nome do exercício',
                        prefixIcon: AppIcons.exercise,
                        validator: (v) =>
                            AppFunctions.validarCampoObrigatorio(v, 'Nome'),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _grupoMuscularController,
                        label: 'Grupo muscular (ex: Peito, Perne)',
                        prefixIcon: Icons.fitness_center,
                        validator: (v) => AppFunctions.validarCampoObrigatorio(
                          v,
                          'Grupo muscular',
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _seriesController,
                        label: 'Séries (ex: 4)',
                        prefixIcon: Icons.numbers,
                        validator: (v) =>
                            AppFunctions.validarCampoObrigatorio(v, 'Séries'),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _repeticoesController,
                        label: 'Repetições (ex: 12)',
                        prefixIcon: Icons.repeat,
                        validator: (v) => AppFunctions.validarCampoObrigatorio(
                          v,
                          'Repetições',
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _cargaController,
                        label: 'Carga em kg (ex: 25.0)',
                        prefixIcon: AppIcons.workout,
                        validator: (v) =>
                            AppFunctions.validarCampoObrigatorio(v, 'Carga'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Adicionar Exercício',
                icon: AppIcons.add,
                onPressed: _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}