import 'package:flutter/material.dart';
import '../models/exercicios.dart';
import '../models/treino.dart';

class TreinoRepository extends ChangeNotifier {
  final List<Treino> _treinos = [
    Treino(
      id: 'treino-a',
      titulo: 'Treino A',
      focado: 'Peito e Tríceps',
      exercicios: [
        Exercicio(id: '1', nome: 'Supino Reto', grupoMuscular: 'Peitoral', series: 4, repeticoes: 10, carga: 60.0),
        Exercicio(id: '2', nome: 'Supino Inclinado com Halteres', grupoMuscular: 'Peitoral', series: 3, repeticoes: 12, carga: 22.0),
        Exercicio(id: '3', nome: 'Tríceps Pulley', grupoMuscular: 'Tríceps', series: 4, repeticoes: 15, carga: 25.0),
      ],
    ),
    Treino(
      id: 'treino-b',
      titulo: 'Treino B',
      focado: 'Costas e Bíceps',
      exercicios: [
        Exercicio(id: '4', nome: 'Puxada Alta', grupoMuscular: 'Costas', series: 4, repeticoes: 10, carga: 50.0),
        Exercicio(id: '5', nome: 'Remada Curvada', grupoMuscular: 'Costas', series: 3, repeticoes: 10, carga: 40.0),
        Exercicio(id: '6', nome: 'Rosca Direta', grupoMuscular: 'Bíceps', series: 3, repeticoes: 12, carga: 14.0),
      ],
    ),
    Treino(
      id: 'treino-c',
      titulo: 'Treino C',
      focado: 'Pernas e Core (Calistenia)',
      exercicios: [
        Exercicio(id: '7', nome: 'Agachamento Livre', grupoMuscular: 'Pernas', series: 4, repeticoes: 8, carga: 80.0),
        Exercicio(id: '8', nome: 'Leg Press 45', grupoMuscular: 'Pernas', series: 3, repeticoes: 12, carga: 160.0),
        Exercicio(id: '9', nome: 'Prancha Abdominal', grupoMuscular: 'Core', series: 3, repeticoes: 60, carga: 0.0),
      ],
    ),
  ];

  List<Treino> get treinos => List.unmodifiable(_treinos);

  Treino? buscarPorId(String id) {
    try {
      return _treinos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void salvarTreino(Treino treino) {
    final index = _treinos.indexWhere((t) => t.id == treino.id);
    if (index >= 0) {
      _treinos[index] = treino;
    } else {
      _treinos.add(treino);
    }
    notifyListeners();
  }

  void removerTreino(String id) {
    _treinos.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void salvarExercicio(String treinoId, Exercicio exercicio) {
    final treino = buscarPorId(treinoId);
    if (treino == null) return;

    final index = treino.exercicios.indexWhere((e) => e.id == exercicio.id);
    if (index >= 0) {
      treino.exercicios[index] = exercicio;
    } else {
      treino.exercicios.add(exercicio);
    }
    notifyListeners();
  }

  void removerExercicio(String treinoId, String idExercicio) {
    final treino = buscarPorId(treinoId);
    if (treino == null) return;

    treino.exercicios.removeWhere((e) => e.id == idExercicio);
    notifyListeners();
  }
}
