import 'package:flutter/material.dart';
import 'package:ide/editor_provider.dart';
import 'package:ide/setup/setup_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditorProvider(),
      child: MaterialApp(
        title: 'Flutter IDE',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SetupScreen(),
      ),
    );
  }
}
