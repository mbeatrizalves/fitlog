import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/exercicios.dart';
import '../models/treino.dart';

class TreinoRepository extends ChangeNotifier {
  List<Treino> _treinos = [];

  List<Treino> get treinos => List.unmodifiable(_treinos);

  Treino? buscarPorId(String id) {
    try {
      return _treinos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> carregar() async {
    final db = await AppDatabase.instance.database;
    final resTreinos = await db.query('treinos');

    List<Treino> listaTreinos = [];

    for (var tMap in resTreinos) {
      final tId = tMap['id'] as String;

      final resExercicios = await db.query(
        'exercicios',
        where: 'treino_id = ?',
        whereArgs: [tId],
      );

      List<Exercicio> listaExercicios = resExercicios.map((e) {
        return Exercicio(
          id: e['id'] as String,
          nome: e['nome'] as String,
          grupoMuscular: e['grupo_muscular'] as String,
          series: e['series'] as int,
          repeticoes: e['repeticoes'] as int,
          carga: (e['carga'] as num).toDouble(),
        );
      }).toList();

      listaTreinos.add(
        Treino(
          id: tId,
          titulo: tMap['titulo'] as String,
          focado: tMap['focado'] as String,
          exercicios: listaExercicios,
        ),
      );
    }

    _treinos = listaTreinos;
    notifyListeners();
  }

  Future<void> cadastrarTreino({
    required String titulo,
    required String focado,
  }) async {
    final db = await AppDatabase.instance.database;
    final novoId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('treinos', {
      'id': novoId,
      'titulo': titulo,
      'focado': focado,
    });

    await carregar();
  }

  Future<void> atualizarTreino({
    required String id,
    required String titulo,
    required String focado,
  }) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'treinos',
      {
        'titulo': titulo,
        'focado': focado,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    await carregar();
  }

  Future<void> removerTreino(String id) async {
    final db = await AppDatabase.instance.database;

    await db.delete('treinos', where: 'id = ?', whereArgs: [id]);
    await db.delete('exercicios', where: 'treino_id = ?', whereArgs: [id]);

    await carregar();
  }

  Future<void> adicionarExercicio({
    required String treinoId,
    required String nome,
    required String grupoMuscular,
    required int series,
    required int repeticoes,
    required double carga,
  }) async {
    final db = await AppDatabase.instance.database;
    final exId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('exercicios', {
      'id': exId,
      'treino_id': treinoId,
      'nome': nome,
      'grupo_muscular': grupoMuscular,
      'series': series,
      'repeticoes': repeticoes,
      'carga': carga,
    });

    await carregar();
  }

  Future<void> removerExercicio(String treinoId, String exercicioId) async {
    final db = await AppDatabase.instance.database;

    await db.delete('exercicios', where: 'id = ?', whereArgs: [exercicioId]);

    await carregar();
  }
}