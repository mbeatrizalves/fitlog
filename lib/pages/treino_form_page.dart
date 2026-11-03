import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';
import '../models/exercicios.dart';

class TreinoFormPage extends StatefulWidget {
  final String? treinoId;

  const TreinoFormPage({super.key, this.treinoId});

  @override
  State<TreinoFormPage> createState() => _TreinoFormPageState();
}

class _ExercicioInputControllers {
  final TextEditingController nomeController;
  final TextEditingController grupoMuscularController;
  final TextEditingController seriesController;
  final TextEditingController repeticoesController;
  final TextEditingController cargaController;

  _ExercicioInputControllers({
    String nome = '',
    String grupoMuscular = '',
    String series = '',
    String repeticoes = '',
    String carga = '',
  })  : nomeController = TextEditingController(text: nome),
        grupoMuscularController = TextEditingController(text: grupoMuscular),
        seriesController = TextEditingController(text: series),
        repeticoesController = TextEditingController(text: repeticoes),
        cargaController = TextEditingController(text: carga);

  void dispose() {
    nomeController.dispose();
    grupoMuscularController.dispose();
    seriesController.dispose();
    repeticoesController.dispose();
    cargaController.dispose();
  }
}

class _TreinoFormPageState extends State<TreinoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _focadoController;
  final List<_ExercicioInputControllers> _exerciciosControllers = [];

  bool get _ehEdicao => widget.treinoId != null;

  @override
  void initState() {
    super.initState();
    final treino = widget.treinoId != null
        ? AppState.instance.treinos.buscarPorId(widget.treinoId!)
        : null;

    _tituloController = TextEditingController(text: treino?.titulo ?? '');
    _focadoController = TextEditingController(text: treino?.focado ?? '');

    if (treino != null && treino.exercicios.isNotEmpty) {
      for (final ex in treino.exercicios) {
        _exerciciosControllers.add(
          _ExercicioInputControllers(
            nome: ex.nome,
            grupoMuscular: ex.grupoMuscular,
            series: ex.series.toString(),
            repeticoes: ex.repeticoes.toString(),
            carga: ex.carga.toString(),
          ),
        );
      }
    } else {
      // Adiciona 1 campo de exercício vazio por padrão
      _exerciciosControllers.add(_ExercicioInputControllers());
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _focadoController.dispose();
    for (final ctrl in _exerciciosControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _adicionarCamposExercicio() {
    setState(() {
      _exerciciosControllers.add(_ExercicioInputControllers());
    });
  }

  void _removerCamposExercicio(int index) {
    if (_exerciciosControllers.length > 1) {
      setState(() {
        final removido = _exerciciosControllers.removeAt(index);
        removido.dispose();
      });
    } else {
      AppFunctions.mostrarSnackBar(
        context,
        'O treino precisa ter pelo menos um exercício.',
        ehErro: true,
      );
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final treinosRepo = AppState.instance.treinos;
    final idTreino = widget.treinoId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Converte os controllers para a lista de Exercícios
    final List<Exercicio> listaExercicios = [];
    for (int i = 0; i < _exerciciosControllers.length; i++) {
      final ctrl = _exerciciosControllers[i];
      listaExercicios.add(
        Exercicio(
          id: '${idTreino}_ex_$i',
          nome: ctrl.nomeController.text.trim(),
          grupoMuscular: ctrl.grupoMuscularController.text.trim(),
          series: int.tryParse(ctrl.seriesController.text.trim()) ?? 0,
          repeticoes: int.tryParse(ctrl.repeticoesController.text.trim()) ?? 0,
          carga: double.tryParse(ctrl.cargaController.text.trim()) ?? 0.0,
        ),
      );
    }

    if (_ehEdicao) {
      await treinosRepo.atualizarTreino(
        id: widget.treinoId!,
        titulo: _tituloController.text.trim(),
        focado: _focadoController.text.trim(),
      );
      // Atualiza a lista de exercícios no objeto do treino
      final treinoEdicao = treinosRepo.buscarPorId(widget.treinoId!);
      if (treinoEdicao != null) {
        treinoEdicao.exercicios.clear();
        treinoEdicao.exercicios.addAll(listaExercicios);
      }
    } else {
      await treinosRepo.cadastrarTreino(
        titulo: _tituloController.text.trim(),
        focado: _focadoController.text.trim(),
      );
      final novoTreino = treinosRepo.buscarPorId(idTreino) ?? treinosRepo.treinos.last;
      novoTreino.exercicios.addAll(listaExercicios);
    }

    if (mounted) {
      AppFunctions.mostrarSnackBar(
        context,
        _ehEdicao ? 'Treino atualizado com sucesso.' : 'Treino e exercícios cadastrados!',
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/personal/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_ehEdicao ? 'Editar Treino' : 'Novo Treino'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dados Gerais do Treino
              Card(
                color: colors.secondaryContainer.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _tituloController,
                        label: 'Título do treino (ex: Treino A)',
                        prefixIcon: AppIcons.workout,
                        validator: (v) =>
                            AppFunctions.validarCampoObrigatorio(v, 'Título'),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _focadoController,
                        label: 'Foco (ex: Peito e Tríceps)',
                        prefixIcon: AppIcons.exercise,
                        validator: (v) =>
                            AppFunctions.validarCampoObrigatorio(v, 'Foco'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cabeçalho dos Exercícios
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercícios do Treino',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(AppIcons.add, size: 18),
                    label: const Text('Novo Exercício'),
                    onPressed: _adicionarCamposExercicio,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Formulários dos Exercícios
              ...List.generate(_exerciciosControllers.length, (index) {
                final ctrl = _exerciciosControllers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Exercício #${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (_exerciciosControllers.length > 1)
                              IconButton(
                                icon: const Icon(AppIcons.delete, color: Colors.red),
                                tooltip: 'Remover Exercício',
                                onPressed: () => _removerCamposExercicio(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: ctrl.nomeController,
                          label: 'Nome do exercício',
                          prefixIcon: AppIcons.exercise,
                          validator: (v) =>
                              AppFunctions.validarCampoObrigatorio(v, 'Nome do Exercício'),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: ctrl.grupoMuscularController,
                          label: 'Grupo Muscular (ex: Peito, Tríceps)',
                          prefixIcon: Icons.fitness_center,
                          validator: (v) =>
                              AppFunctions.validarCampoObrigatorio(v, 'Grupo Muscular'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: ctrl.seriesController,
                                label: 'Séries (ex: 4)',
                                prefixIcon: Icons.numbers,
                                validator: (v) =>
                                    AppFunctions.validarCampoObrigatorio(v, 'Séries'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomTextField(
                                controller: ctrl.repeticoesController,
                                label: 'Reps (ex: 12)',
                                prefixIcon: Icons.repeat,
                                validator: (v) =>
                                    AppFunctions.validarCampoObrigatorio(v, 'Repetições'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomTextField(
                                controller: ctrl.cargaController,
                                label: 'Carga kg (ex: 20)',
                                prefixIcon: AppIcons.workout,
                                validator: (v) =>
                                    AppFunctions.validarCampoObrigatorio(v, 'Carga'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              PrimaryButton(
                label: _ehEdicao ? 'Salvar Alterações do Treino' : 'Cadastrar Treino Completo',
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