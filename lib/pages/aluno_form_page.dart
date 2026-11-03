import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';

class AlunoFormPage extends StatefulWidget {
  final String? alunoId;

  const AlunoFormPage({super.key, this.alunoId});

  @override
  State<AlunoFormPage> createState() => _AlunoFormPageState();
}

class _AlunoFormPageState extends State<AlunoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _senhaController;

  bool get _ehEdicao => widget.alunoId != null;

  @override
  void initState() {
    super.initState();
    final aluno = widget.alunoId != null
        ? AppState.instance.usuarios.buscarPorId(widget.alunoId!)
        : null;

    _nomeController = TextEditingController(text: aluno?.nome ?? '');
    _emailController = TextEditingController(text: aluno?.email ?? '');
    _senhaController = TextEditingController(text: aluno?.senha ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final usuariosRepo = AppState.instance.usuarios;
    final emailDigitado = _emailController.text.trim();
    final senhaDigitada = _senhaController.text.trim();
    final nomeDigitado = _nomeController.text.trim();

    if (_ehEdicao) {
      await usuariosRepo.atualizarAluno(
        id: widget.alunoId!,
        nome: nomeDigitado,
        email: emailDigitado,
        senha: senhaDigitada,
      );
    } else {
      await usuariosRepo.cadastrarAluno(
        nome: nomeDigitado,
        email: emailDigitado,
        senha: senhaDigitada,
      );
    }

    if (mounted) {
      AppFunctions.mostrarSnackBar(
        context,
        _ehEdicao
            ? 'Aluno atualizado com sucesso.'
            : 'Aluno cadastrado! Login liberado.',
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
        title: Text(_ehEdicao ? 'Editar Aluno' : 'Novo Aluno'),
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
            children: [
              Card(
                color: colors.secondaryContainer.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nomeController,
                        label: 'Nome completo',
                        prefixIcon: AppIcons.user,
                        validator: (v) =>
                            AppFunctions.validarCampoObrigatorio(v, 'Nome'),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        prefixIcon: Icons.email,
                        validator: AppFunctions.validarEmail,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _senhaController,
                        label: 'Senha de Acesso',
                        prefixIcon: AppIcons.login,
                        obscureText: true,
                        validator: AppFunctions.validarSenha,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _ehEdicao ? 'Salvar Alterações' : 'Cadastrar Aluno',
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