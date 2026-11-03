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

  void _submeterLogin() {
    if (_formKey.currentState!.validate()) {
      AppFunctions.mostrarSnackBar(context, 'Autenticando...');
    } else {
      AppFunctions.mostrarSnackBar(
        context,
        'Preencha os dados corretamente.',
        ehErro: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitLog - Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              PrimaryButton(
                label: 'Entrar',
                icon: AppIcons.login,
                onPressed: _submeterLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}