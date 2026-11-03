import 'package:flutter/material.dart';
import '../app_state.dart';
import '../core/constants/app_icons.dart';
import '../core/helpers/app_functions.dart';
import '../core/widgets/app_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  // Apenas preenche os campos com os dados do atalho selecionado
  void _preencherAtalho(String email, String senha) {
    setState(() {
      _emailController.text = email;
      _senhaController.text = senha;
    });
  }

Future<void> _submeterLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      try {
        final email = _emailController.text.trim();
        final senha = _senhaController.text.trim();

        // Tenta efetuar o login
        final sucesso = await AppState.instance.sessao.login(email, senha);

        if (!sucesso) {
          if (mounted) {
            AppFunctions.mostrarSnackBar(
              context,
              'E-mail ou senha inválidos.',
              ehErro: true,
            );
          }
        }
        // Se for sucesso, o GoRouter redireciona automaticamente
      } catch (e) {
        if (mounted) {
          AppFunctions.mostrarSnackBar(
            context,
            'Erro ao autenticar: ${e.toString()}',
            ehErro: true,
          );
        }
      } finally {
        // Garante SEMPRE que o carregamento é desativado, quer dê erro, sucesso ou falhe
        if (mounted) {
          setState(() => _carregando = false);
        }
      }
    } else {
      AppFunctions.mostrarSnackBar(
        context,
        'Preencha os dados corretamente.',
        ehErro: true,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitLog - Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              CustomTextField(
                controller: _emailController,
                label: 'E-mail',
                prefixIcon: AppIcons.user,
                validator: AppFunctions.validarEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _senhaController,
                label: 'Senha',
                prefixIcon: AppIcons.login,
                obscureText: true,
                validator: AppFunctions.validarSenha,
              ),
              const SizedBox(height: 24),
              _carregando
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      label: 'Entrar',
                      icon: AppIcons.login,
                      onPressed: _submeterLogin,
                    ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Atalhos de Acesso Rápido',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              // Botões de atalho que apenas preenchem os campos de texto
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _carregando
                        ? null
                        : () => _preencherAtalho('personal@fitlog.com', '123456'),
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('Personal'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _carregando
                        ? null
                        : () => _preencherAtalho('aluno1@fitlog.com', '123456'),
                    icon: const Icon(Icons.person),
                    label: const Text('Aluno 1'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _carregando
                        ? null
                        : () => _preencherAtalho('aluno2@fitlog.com', '123456'),
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Aluno 2'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}