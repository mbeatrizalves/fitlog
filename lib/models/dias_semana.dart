enum DiasSemana {
  segunda,
  terca,
  quarta,
  quinta,
  sexta,
  sabado,
  domingo,
}

extension DiasSemanaExtension on DiasSemana {
  String get rotulo {
    switch (this) {
      case DiasSemana.segunda:
        return 'Segunda-feira';
      case DiasSemana.terca:
        return 'Terça-feira';
      case DiasSemana.quarta:
        return 'Quarta-feira';
      case DiasSemana.quinta:
        return 'Quinta-feira';
      case DiasSemana.sexta:
        return 'Sexta-feira';
      case DiasSemana.sabado:
        return 'Sábado';
      case DiasSemana.domingo:
        return 'Domingo';
    }
  }
}

const Map<DiasSemana, String> rotulosDiasSemana = {
  DiasSemana.segunda: 'Segunda-feira',
  DiasSemana.terca: 'Terça-feira',
  DiasSemana.quarta: 'Quarta-feira',
  DiasSemana.quinta: 'Quinta-feira',
  DiasSemana.sexta: 'Sexta-feira',
  DiasSemana.sabado: 'Sábado',
  DiasSemana.domingo: 'Domingo',
};