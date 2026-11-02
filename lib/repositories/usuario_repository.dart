import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/dia_aluno.dart';
import '../models/dias_semana.dart';
import '../models/papel.dart';
import '../models/usuario.dart';

class UsuarioRepository extends ChangeNotifier {
  UsuarioRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  final List<Usuario> _usuarios = [
    Usuario(
      id: 'personal-1',
      nome: 'Personal FitLog',
      email: 'personal@fitlog.com',
      senha: '123456',
      papel: Papel.personal,
    ),
    Usuario(
      id: 'aluno-1',
      nome: 'Ana Aluna',
      email: 'aluno1@fitlog.com',
      senha: '123456',
      papel: Papel.aluno,
      agenda: [
        DiaAluno(diaSemana: 'Segunda-feira', treinoId: 'treino-a'),
        DiaAluno(diaSemana: 'Terca-feira', treinoId: 'treino-b'),
        DiaAluno(diaSemana: 'Quarta-feira'),
        DiaAluno(diaSemana: 'Quinta-feira', treinoId: 'treino-c'),
        DiaAluno(diaSemana: 'Sexta-feira', treinoId: 'treino-a'),
        DiaAluno(diaSemana: 'Sabado'),
        DiaAluno(diaSemana: 'Domingo'),
      ],
    ),
    Usuario(
      id: 'aluno-2',
      nome: 'Bruno Aluno',
      email: 'aluno2@fitlog.com',
      senha: '123456',
      papel: Papel.aluno,
      agenda: [
        DiaAluno(diaSemana: 'Segunda-feira', treinoId: 'treino-b'),
        DiaAluno(diaSemana: 'Terca-feira'),
        DiaAluno(diaSemana: 'Quarta-feira', treinoId: 'treino-c'),
        DiaAluno(diaSemana: 'Quinta-feira'),
        DiaAluno(diaSemana: 'Sexta-feira', treinoId: 'treino-b'),
        DiaAluno(diaSemana: 'Sabado', treinoId: 'treino-a'),
        DiaAluno(diaSemana: 'Domingo'),
      ],
    ),
  ];

  List<Usuario> get usuarios => List.unmodifiable(_usuarios);

  List<Usuario> get alunos =>
      _usuarios.where((u) => u.papel == Papel.aluno).toList();

  Future<void> carregar() async {
    final usuarios = await _database.carregarUsuarios();
    _usuarios
      ..clear()
      ..addAll(usuarios);
    notifyListeners();
  }

  Future<void> persistirDadosIniciais() async {
    for (final usuario in _usuarios) {
      await _database.salvarUsuario(usuario);
    }
  }

  Usuario? buscarPorId(String id) {
    try {
      return _usuarios.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Usuario? buscarPorEmail(String email) {
    try {
      return _usuarios.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase().trim(),
      );
    } catch (_) {
      return null;
    }
  }

  bool emailEmUso(String email, {String? ignorarId}) {
    return _usuarios.any(
      (u) =>
          u.email.toLowerCase() == email.toLowerCase().trim() &&
          u.id != ignorarId,
    );
  }

  Future<void> salvarAluno(Usuario aluno) async {
    if (aluno.papel != Papel.aluno) return;

    if (aluno.agenda.isEmpty) {
      aluno.agenda = agendaVazia();
    }

    await _database.salvarUsuario(aluno);
    final index = _usuarios.indexWhere((u) => u.id == aluno.id);
    if (index >= 0) {
      _usuarios[index] = aluno;
    } else {
      _usuarios.add(aluno);
    }
    notifyListeners();
  }

  Future<void> removerAluno(String id) async {
    final usuario = buscarPorId(id);
    if (usuario == null || usuario.papel != Papel.aluno) return;
    await _database.removerUsuario(id);
    _usuarios.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  Future<void> atribuirTreinoAoDia(
      String alunoId, String diaSemana, String? treinoId) async {
    final aluno = buscarPorId(alunoId);
    if (aluno == null || aluno.papel != Papel.aluno) return;

    final agenda = aluno.agenda
        .map((item) => DiaAluno(
              diaSemana: item.diaSemana,
              treinoId: item.diaSemana == diaSemana ? treinoId : item.treinoId,
            ))
        .toList();
    if (!agenda.any((item) => item.diaSemana == diaSemana)) {
      agenda.add(DiaAluno(diaSemana: diaSemana, treinoId: treinoId));
    }
    await _database.salvarUsuario(Usuario(
      id: aluno.id,
      nome: aluno.nome,
      email: aluno.email,
      senha: aluno.senha,
      papel: aluno.papel,
      agenda: agenda,
    ));
    aluno.agenda
      ..clear()
      ..addAll(agenda);
    notifyListeners();
  }

  /// Remove referências a um treino excluído das agendas dos alunos.
  void limparReferenciasTreino(String treinoId) {
    for (final aluno in alunos) {
      for (final dia in aluno.agenda) {
        if (dia.treinoId == treinoId) dia.treinoId = null;
      }
    }
    notifyListeners();
  }
}
