import 'package:flutter/material.dart';
import 'pages/setup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF414A4C),
                  secondary: Color(0xFF3B444B),
                  surface: Color(0xFF232B2B),
                  onPrimary: Colors.white,
                  onSecondary: Colors.white,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.white,
                ),
        fontFamily: "NeoFolia",
        scaffoldBackgroundColor: Color(0xFF232B2B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF232B2B),
          elevation: 4,
        ),
      ),
      home: const SetUpPage(),
    );
  }
}