import 'package:flutter/material.dart';
import 'package:ide/screens/home_screen.dart';
import 'package:ide/screens/setup_screen.dart';
import 'package:ide/utils/file_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSdkSetup = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSdk();
  }

  Future<void> _checkSdk() async {
    final sdkExists = await checkFlutterSdkExists();
    setState(() {
      _isSdkSetup = sdkExists;
      _isLoading = false;
    });
  }

  void _onSetupComplete() {
    setState(() {
      _isSdkSetup = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter IDE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _isSdkSetup
              ? const HomeScreen()
              : SetupScreen(onSetupComplete: _onSetupComplete),
    );
  }
}
