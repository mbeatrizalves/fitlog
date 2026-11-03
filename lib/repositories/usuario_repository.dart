import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/dia_aluno.dart';
import '../models/dias_semana.dart';
import '../models/papel.dart';
import '../models/usuario.dart';

class UsuarioRepository extends ChangeNotifier {
  List<Usuario> _usuarios = [];

  List<Usuario> get alunos => _usuarios.where((u) => u.isAluno).toList();

  Usuario? buscarPorId(String id) {
    try {
      return _usuarios.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> carregar() async {
    final db = await AppDatabase.instance.database;
    final resUsuarios = await db.query('usuarios');

    List<Usuario> listaCarregada = [];

    for (var uMap in resUsuarios) {
      final uId = uMap['id'] as String;
      final papelStr = uMap['papel'] as String;

      // Busca os itens da agenda do usuário no SQLite
      final resAgenda = await db.query(
        'agenda',
        where: 'aluno_id = ?',
        whereArgs: [uId],
      );

      List<DiaAluno> agendaAluno = [];
      for (final diaEnum in DiasSemana.values) {
        final regAgenda = resAgenda.firstWhere(
          (a) => a['dia_semana'] == diaEnum.name,
          orElse: () => {},
        );

        agendaAluno.add(
          DiaAluno(
            diaSemana: diaEnum.name,
            treinoId: regAgenda['treino_id'] as String?,
          ),
        );
      }

      listaCarregada.add(
        Usuario(
          id: uId,
          nome: uMap['nome'] as String,
          email: uMap['email'] as String,
          senha: uMap['senha'] as String,
          papel: papelStr == 'personal' ? Papel.personal : Papel.aluno,
          agenda: agendaAluno,
        ),
      );
    }

    _usuarios = listaCarregada;
    notifyListeners();
  }

  Future<void> cadastrarAluno({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final db = await AppDatabase.instance.database;
    final novoId = DateTime.now().millisecondsSinceEpoch.toString();

    // Insere usuário no SQLite
    await db.insert('usuarios', {
      'id': novoId,
      'nome': nome,
      'email': email,
      'senha': senha,
      'papel': 'aluno',
    });

    // Insere os dias padrão da agenda no SQLite
    for (final diaEnum in DiasSemana.values) {
      await db.insert('agenda', {
        'id': '${novoId}_${diaEnum.name}',
        'aluno_id': novoId,
        'dia_semana': diaEnum.name,
        'treino_id': null,
      });
    }

    await carregar(); // Atualiza em memória do SQLite
  }

  Future<void> atualizarAluno({
    required String id,
    required String nome,
    required String email,
    required String senha,
  }) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'usuarios',
      {
        'nome': nome,
        'email': email,
        'senha': senha,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    await carregar();
  }

  Future<void> removerAluno(String id) async {
    final db = await AppDatabase.instance.database;

    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
    await db.delete('agenda', where: 'aluno_id = ?', whereArgs: [id]);

    await carregar();
  }

  Future<void> atribuirTreinoAgenda({
    required String alunoId,
    required DiasSemana diaSemana,
    required String? treinoId,
  }) async {
    final db = await AppDatabase.instance.database;

    final reg = await db.query(
      'agenda',
      where: 'aluno_id = ? AND dia_semana = ?',
      whereArgs: [alunoId, diaSemana.name],
    );

    if (reg.isNotEmpty) {
      await db.update(
        'agenda',
        {'treino_id': treinoId},
        where: 'aluno_id = ? AND dia_semana = ?',
        whereArgs: [alunoId, diaSemana.name],
      );
    } else {
      await db.insert('agenda', {
        'id': '${alunoId}_${diaSemana.name}',
        'aluno_id': alunoId,
        'dia_semana': diaSemana.name,
        'treino_id': treinoId,
      });
    }

    await carregar();
  }

  Future<void> limparReferenciasTreino(String treinoId) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'agenda',
      {'treino_id': null},
      where: 'treino_id = ?',
      whereArgs: [treinoId],
    );

    await carregar();
  }
}