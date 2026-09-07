import 'package:flutter/material.dart';
import '../repositories/treino_repository.dart';
import 'treino_detalhe_page.dart';

class HomePage extends StatelessWidget {
  final TreinoRepository repositorio = TreinoRepository();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repositorio,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('FitLog - Diário de Treinos'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          body: ListView.separated(
            itemCount: repositorio.tabela.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final treino = repositorio.tabela[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: treino.exercicios.isNotEmpty ? Colors.deepOrange.shade100 : Colors.grey.shade200,
                  child: Icon(
                    treino.exercicios.isNotEmpty ? Icons.fitness_center : Icons.weekend,
                    color: treino.exercicios.isNotEmpty ? Colors.deepOrange : Colors.grey,
                  ),
                ),
                title: Text(
                  '${treino.diaSemana} - ${treino.titulo}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(treino.focado),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TreinoDetalhePage(
                        treinoDia: treino,
                        repositorio: repositorio,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}