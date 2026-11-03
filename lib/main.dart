import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Importações condicionais ou específicas para web
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app_state.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Erro no Flutter Framework: ${details.exception}');
  };

  try {
    // Inicializa os repositórios e banco de dados local
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