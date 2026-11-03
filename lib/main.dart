import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_state.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Previne tela branca capturando erros não tratados durante a inicialização
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Erro no Flutter Framework: ${details.exception}');
  };

  try {
    // Inicializa os repositórios e banco de dados SQLite
    await AppState.instance.initialize();
  } catch (e, stackTrace) {
    debugPrint('Erro ao inicializar o AppState: $e');
    debugPrint(stackTrace.toString());
  }

  runApp(const FitLogApp());
}

class FitLogApp extends StatelessWidget {
  const FitLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FitLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}