class Exercicio {
  String id;
  String nome;
  String grupoMuscular;
  int series;
  int repeticoes;
  double carga; // em kg

  Exercicio({
    required this.id,
    required this.nome,
    required this.grupoMuscular,
    required this.series,
    required this.repeticoes,
    required this.carga,
  });
}