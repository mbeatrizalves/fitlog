import 'exercicios.dart';

/// Template reutilizável de treino (não vinculado a um dia da semana).
class Treino {
  String id;
  String titulo;
  String focado;
  List<Exercicio> exercicios;

  Treino({
    required this.id,
    required this.titulo,
    required this.focado,
    required this.exercicios,
  });
}
