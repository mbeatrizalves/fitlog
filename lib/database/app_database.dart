import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/dia_aluno.dart';
import '../models/exercicios.dart';
import '../models/papel.dart';
import '../models/treino.dart';
import '../models/usuario.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'fitlog.db');
    _database = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE usuarios (
          id TEXT PRIMARY KEY,
          nome TEXT NOT NULL,
          email TEXT NOT NULL COLLATE NOCASE UNIQUE,
          senha TEXT NOT NULL,
          papel TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE treinos (
          id TEXT PRIMARY KEY,
          titulo TEXT NOT NULL,
          focado TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE exercicios (
          id TEXT NOT NULL,
          treino_id TEXT NOT NULL,
          nome TEXT NOT NULL,
          grupo_muscular TEXT NOT NULL,
          series INTEGER NOT NULL,
          repeticoes INTEGER NOT NULL,
          carga REAL NOT NULL,
          PRIMARY KEY (treino_id, id),
          FOREIGN KEY (treino_id) REFERENCES treinos(id) ON DELETE CASCADE
        )''');
        await db.execute('''CREATE TABLE agenda (
          aluno_id TEXT NOT NULL,
          dia_semana TEXT NOT NULL,
          treino_id TEXT,
          PRIMARY KEY (aluno_id, dia_semana),
          FOREIGN KEY (aluno_id) REFERENCES usuarios(id) ON DELETE CASCADE,
          FOREIGN KEY (treino_id) REFERENCES treinos(id) ON DELETE SET NULL
        )''');
      },
    );
    return _database!;
  }

  Future<List<Usuario>> carregarUsuarios() async {
    final db = await database;
    final usuarios = await db.query('usuarios');
    final agenda = await db.query('agenda');
    return usuarios.map((row) {
      final id = row['id'] as String;
      return Usuario(
        id: id,
        nome: row['nome'] as String,
        email: row['email'] as String,
        senha: row['senha'] as String,
        papel: Papel.values.byName(row['papel'] as String),
        agenda: agenda
            .where((dia) => dia['aluno_id'] == id)
            .map((dia) => DiaAluno(
                  diaSemana: dia['dia_semana'] as String,
                  treinoId: dia['treino_id'] as String?,
                ))
            .toList(),
      );
    }).toList();
  }

  Future<List<Treino>> carregarTreinos() async {
    final db = await database;
    final treinos = await db.query('treinos');
    final exercicios = await db.query('exercicios');
    return treinos.map((row) {
      final id = row['id'] as String;
      return Treino(
        id: id,
        titulo: row['titulo'] as String,
        focado: row['focado'] as String,
        exercicios: exercicios
            .where((exercicio) => exercicio['treino_id'] == id)
            .map((exercicio) => Exercicio(
                  id: exercicio['id'] as String,
                  nome: exercicio['nome'] as String,
                  grupoMuscular: exercicio['grupo_muscular'] as String,
                  series: exercicio['series'] as int,
                  repeticoes: exercicio['repeticoes'] as int,
                  carga: (exercicio['carga'] as num).toDouble(),
                ))
            .toList(),
      );
    }).toList();
  }

  Future<void> salvarUsuario(Usuario usuario) async {
    final db = await database;
    await db.transaction((txn) async {
      final values = {
        'id': usuario.id,
        'nome': usuario.nome,
        'email': usuario.email,
        'senha': usuario.senha,
        'papel': usuario.papel.name,
      };
      final atualizados = await txn
          .update('usuarios', values, where: 'id = ?', whereArgs: [usuario.id]);
      if (atualizados == 0) await txn.insert('usuarios', values);
      await txn
          .delete('agenda', where: 'aluno_id = ?', whereArgs: [usuario.id]);
      for (final dia in usuario.agenda) {
        await txn.insert('agenda', {
          'aluno_id': usuario.id,
          'dia_semana': dia.diaSemana,
          'treino_id': dia.treinoId,
        });
      }
    });
  }

  Future<void> removerUsuario(String id) async {
    final db = await database;
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> salvarTreino(Treino treino) async {
    final db = await database;
    await db.transaction((txn) async {
      final values = {
        'id': treino.id,
        'titulo': treino.titulo,
        'focado': treino.focado,
      };
      final atualizados = await txn
          .update('treinos', values, where: 'id = ?', whereArgs: [treino.id]);
      if (atualizados == 0) await txn.insert('treinos', values);
      await txn
          .delete('exercicios', where: 'treino_id = ?', whereArgs: [treino.id]);
      for (final exercicio in treino.exercicios) {
        await txn.insert('exercicios', {
          'id': exercicio.id,
          'treino_id': treino.id,
          'nome': exercicio.nome,
          'grupo_muscular': exercicio.grupoMuscular,
          'series': exercicio.series,
          'repeticoes': exercicio.repeticoes,
          'carga': exercicio.carga,
        });
      }
    });
  }

  Future<void> removerTreino(String id) async {
    final db = await database;
    await db.delete('treinos', where: 'id = ?', whereArgs: [id]);
  }
}
