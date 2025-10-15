import 'package:flutter/material.dart';
import 'src/features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const  MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme:  AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          centerTitle: true,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}