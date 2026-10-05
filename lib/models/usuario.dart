import 'dia_aluno.dart';
import 'papel.dart';

class Usuario {
  String id;
  String nome;
  String email;
  String senha;
  Papel papel;
  List<DiaAluno> agenda;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.papel,
    List<DiaAluno>? agenda,
  }) : agenda = agenda ?? [];

  bool get isPersonal => papel == Papel.personal;
  bool get isAluno => papel == Papel.aluno;
}
