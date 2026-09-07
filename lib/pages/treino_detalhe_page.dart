import 'package:flutter/material.dart';
import '../models/treino_dia.dart';
import '../repositories/treino_repository.dart';
import 'exercicio_form_page.dart';

class TreinoDetalhePage extends StatelessWidget {
  final TreinoDia treinoDia;
  final TreinoRepository repositorio;

  const TreinoDetalhePage({
    super.key,
    required this.treinoDia,
    required this.repositorio,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repositorio,
      builder: (context, child) {
        // Atualiza a referência do dia atual com base no repositório
        final treinoAtualizado = repositorio.tabela.firstWhere((t) => t.diaSemana == treinoDia.diaSemana);

        return Scaffold(
          appBar: AppBar(
            title: Text(treinoAtualizado.diaSemana),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          body: treinoAtualizado.exercicios.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum exercício cadastrado para este dia.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: treinoAtualizado.exercicios.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final exercicio = treinoAtualizado.exercicios[index];
                    return ListTile(
                      title: Text(
                        exercicio.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Grupo: ${exercicio.grupoMuscular} | Séries: ${exercicio.series} | Reps: ${exercicio.repeticoes} | Carga: ${exercicio.carga}kg',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExercicioFormPage(
                                    diaSemana: treinoAtualizado.diaSemana,
                                    repositorio: repositorio,
                                    exercicioExistente: exercicio,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              repositorio.removerExercicio(treinoAtualizado.diaSemana, exercicio.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExercicioFormPage(
                    diaSemana: treinoAtualizado.diaSemana,
                    repositorio: repositorio,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}