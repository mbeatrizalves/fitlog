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
    if (AppState.instance.usuarios.emailEmUso(email, ignorarId: widget.alunoId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este e-mail já está em uso.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final id = widget.alunoId ?? DateTime.now().millisecondsSinceEpoch.toString();
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
      SnackBar(content: Text(isEdicao ? 'Aluno atualizado.' : 'Aluno cadastrado.')),
    );
    context.go('/alunos/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Aluno' : 'Novo Aluno'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _nome,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _salvar,
                child: Text(
                  isEdicao ? 'Salvar alterações' : 'Cadastrar aluno',
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
