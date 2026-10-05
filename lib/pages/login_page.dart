import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _senha = '';
  String? _erroLogin;

  void _entrar() {
    setState(() => _erroLogin = null);

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final erro = AppState.instance.sessao.login(_email, _senha);
    if (erro != null) {
      setState(() => _erroLogin = erro);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red.shade700),
      );
      return;
    }

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.fitness_center, size: 72, color: Colors.deepOrange.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'FitLog',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acesse o FitLog com E-mail e Senha',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    initialValue: _email,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o e-mail.';
                      }
                      if (!value.contains('@')) {
                        return 'Informe um e-mail válido.';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!.trim(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _senha,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a senha.';
                      }
                      if (value.length < 4) {
                        return 'A senha deve ter ao menos 4 caracteres.';
                      }
                      return null;
                    },
                    onSaved: (value) => _senha = value!,
                  ),
                  if (_erroLogin != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _erroLogin!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _entrar,
                    child: const Text('Entrar', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Contas de demonstração:\n'
                    'personal@fitlog.com / 123456\n'
                    'aluno1@fitlog.com / 123456\n'
                    'aluno2@fitlog.com / 123456',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
