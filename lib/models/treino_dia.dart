import 'exercicios.dart';

class TreinoDia {
  final String diaSemana;
  final String titulo;
  final String focado;
  final List<Exercicio> exercicios;

  TreinoDia({
    required this.diaSemana,
    required this.titulo,
    required this.focado,
    required this.exercicios,
  });
}