import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const FitLogApp());
}

class FitLogApp extends StatelessWidget {
  const FitLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}