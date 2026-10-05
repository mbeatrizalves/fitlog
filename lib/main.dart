import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_router.dart';

void main() {
  runApp(FitLogApp(router: criarAppRouter()));
}

class FitLogApp extends StatelessWidget {
  final GoRouter router;

  const FitLogApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FitLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
