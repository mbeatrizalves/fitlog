import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitlog.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabela de Usuários (Personal Trainer e Alunos)
    await db.execute('''
      CREATE TABLE usuarios (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        papel TEXT NOT NULL
      )
    ''');

    // 2. Tabela de Treinos
    await db.execute('''
      CREATE TABLE treinos (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        focado TEXT NOT NULL
      )
    ''');

    // 3. Tabela de Exercícios dos Treinos
    await db.execute('''
      CREATE TABLE exercicios (
        id TEXT PRIMARY KEY,
        treino_id TEXT NOT NULL,
        nome TEXT NOT NULL,
        grupo_muscular TEXT NOT NULL,
        series INTEGER NOT NULL,
        repeticoes INTEGER NOT NULL,
        carga REAL NOT NULL,
        FOREIGN KEY (treino_id) REFERENCES treinos (id) ON DELETE CASCADE
      )
    ''');

    // 4. Tabela de Agenda Semanal dos Alunos
    await db.execute('''
      CREATE TABLE agenda (
        id TEXT PRIMARY KEY,
        aluno_id TEXT NOT NULL,
        dia_semana TEXT NOT NULL,
        treino_id TEXT,
        FOREIGN KEY (aluno_id) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (treino_id) REFERENCES treinos (id) ON DELETE SET NULL
      )
    ''');

    // --- SEEDING INICIAL DOS DADOS NO BANCO (Comandos separados para compatibilidade total com SQLite Web/Ffi) ---

    // Inserção das contas padrão (1 Personal + 2 Alunos)
    await db.insert('usuarios', {'id': 'p1', 'nome': 'Personal Trainer', 'email': 'personal@fitlog.com', 'senha': '123456', 'papel': 'personal'});
    await db.insert('usuarios', {'id': 'a1', 'nome': 'Aluno 1', 'email': 'aluno1@fitlog.com', 'senha': '123456', 'papel': 'aluno'});
    await db.insert('usuarios', {'id': 'a2', 'nome': 'Aluno 2', 'email': 'aluno2@fitlog.com', 'senha': '123456', 'papel': 'aluno'});

    // Inserção dos treinos padrão (Treino A e Treino B)
    await db.insert('treinos', {'id': 't1', 'titulo': 'Treino A', 'focado': 'Peito e Tríceps'});
    await db.insert('treinos', {'id': 't2', 'titulo': 'Treino B', 'focado': 'Costas e Bíceps'});

    // Inserção dos exercícios correspondentes
    await db.insert('exercicios', {'id': 'e1', 'treino_id': 't1', 'nome': 'Supino Reto', 'grupo_muscular': 'Peito', 'series': 4, 'repeticoes': 12, 'carga': 30.0});
    await db.insert('exercicios', {'id': 'e2', 'treino_id': 't1', 'nome': 'Tríceps Pulley', 'grupo_muscular': 'Tríceps', 'series': 3, 'repeticoes': 15, 'carga': 20.0});
    await db.insert('exercicios', {'id': 'e3', 'treino_id': 't2', 'nome': 'Puxada Frontal', 'grupo_muscular': 'Costas', 'series': 4, 'repeticoes': 10, 'carga': 40.0});
    await db.insert('exercicios', {'id': 'e4', 'treino_id': 't2', 'nome': 'Rosca Direta', 'grupo_muscular': 'Bíceps', 'series': 3, 'repeticoes': 12, 'carga': 12.0});

    // Inserção da agenda inicial atribuída para os dois alunos
    await db.insert('agenda', {'id': 'ag1', 'aluno_id': 'a1', 'dia_semana': 'segunda', 'treino_id': 't1'});
    await db.insert('agenda', {'id': 'ag2', 'aluno_id': 'a1', 'dia_semana': 'terca', 'treino_id': 't2'});
    await db.insert('agenda', {'id': 'ag3', 'aluno_id': 'a1', 'dia_semana': 'quinta', 'treino_id': 't1'});
    await db.insert('agenda', {'id': 'ag4', 'aluno_id': 'a2', 'dia_semana': 'terca', 'treino_id': 't1'});
    await db.insert('agenda', {'id': 'ag5', 'aluno_id': 'a2', 'dia_semana': 'quinta', 'treino_id': 't2'});
  }
}