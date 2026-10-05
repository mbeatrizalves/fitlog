import 'dia_aluno.dart';

/// Dias da semana usados na agenda do aluno.
const List<String> diasDaSemana = [
  'Segunda-feira',
  'Terca-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sabado',
  'Domingo',
];

/// Labels com acentuação para exibição na UI.
const Map<String, String> rotulosDiasSemana = {
  'Segunda-feira': 'Segunda-feira',
  'Terca-feira': 'Terça-feira',
  'Quarta-feira': 'Quarta-feira',
  'Quinta-feira': 'Quinta-feira',
  'Sexta-feira': 'Sexta-feira',
  'Sabado': 'Sábado',
  'Domingo': 'Domingo',
};

List<DiaAluno> agendaVazia() {
  return diasDaSemana.map((dia) => DiaAluno(diaSemana: dia)).toList();
}
