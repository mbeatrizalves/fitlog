import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../models/dias_semana.dart';
import '../models/papel.dart';
import '../models/usuario.dart';

class AlunoFormPage extends StatefulWidget {
  final String? alunoId;

  const AlunoFormPage({super.key, this.alunoId});

  @override
  State<AlunoFormPage> createState() => _AlunoFormPageState();
}

class _AlunoFormPageState extends State<AlunoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _nome;
  late String _email;
  late String _senha;
  Usuario? _existente;

  bool get isEdicao => widget.alunoId != null;

  @override
  void initState() {
    super.initState();
    if (widget.alunoId != null) {
      _existente = AppState.instance.usuarios.buscarPorId(widget.alunoId!);
    }
    _nome = _existente?.nome ?? '';
    _email = _existente?.email ?? '';
    _senha = _existente?.senha ?? '';
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final email = _email.trim();
    if (AppState.instance.usuarios
        .emailEmUso(email, ignorarId: widget.alunoId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este e-mail já está em uso.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final id =
        widget.alunoId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final aluno = Usuario(
      id: id,
      nome: _nome.trim(),
      email: email,
      senha: _senha,
      papel: Papel.aluno,
      agenda: _existente?.agenda ?? agendaVazia(),
    );

    AppState.instance.usuarios.salvarAluno(aluno);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(isEdicao ? 'Aluno atualizado.' : 'Aluno cadastrado.')),
    );
    context.go('/alunos/$id');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdicao ? 'Editar Aluno' : 'Novo Aluno',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isEdicao) {
              context.go('/alunos/${widget.alunoId}');
            } else {
              context.go('/alunos');
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
                        _StudentFormHeader(
                          isEdicao: isEdicao,
                          colors: colors,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          initialValue: _nome,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            hintText: 'Ex: Ana Silva',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome do aluno.';
                            }
                            return null;
                          },
                          onSaved: (value) => _nome = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _email,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'aluno@exemplo.com',
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
                          onSaved: (value) => _email = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _senha,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Defina uma senha',
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
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _salvar,
                            icon:
                                Icon(isEdicao ? Icons.save : Icons.person_add),
                            label: Text(
                              isEdicao
                                  ? 'Salvar alterações'
                                  : 'Cadastrar aluno',
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

class _StudentFormHeader extends StatelessWidget {
  final bool isEdicao;
  final ColorScheme colors;

  const _StudentFormHeader({
    required this.isEdicao,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: colors.primary,
          child: Icon(
            isEdicao ? Icons.edit : Icons.person_add,
            color: colors.onPrimary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdicao ? 'Editar aluno' : 'Novo aluno',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                isEdicao
                    ? 'Atualize os dados deste aluno.'
                    : 'Cadastre um aluno para acompanhar seus treinos.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
