<<<<<<< HEAD
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'pages/home.dart';
import 'pages/setup.dart';
import 'package:permission_handler/permission_handler.dart';
=======
import 'package:flutter/material.dart';
import 'pages/setup_page.dart';
>>>>>>> 777f43b (Auto commit from automation tool)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

<<<<<<< HEAD
  Future<bool> isSdkInstalled() async {
    final dir = await getApplicationSupportDirectory();
    final sdkDir = Directory('${dir.path}/flutter');
    return sdkDir.existsSync();
  }

  Future<bool> checkPermissions() async {
    bool granted = await requestStoragePermission();
    if (!granted) {
      // Optionally show dialog to user
      print("Storage permission not granted!");
    }
    return granted;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter IDE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
        future: checkPermissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data != true) {
            return const Scaffold(
              body: Center(child: Text("Storage permission required")),
            );
          }

          // Permission granted → check SDK
          return FutureBuilder<bool>(
            future: isSdkInstalled(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data == true) {
                return const HomePage();
              } else {
                return const SetupSdk();
              }
            },
          );
        },
      ),
    );
  }
}

Future<bool> requestStoragePermission() async {
  // Android 11+ special manage storage permission
  if (await Permission.manageExternalStorage.isGranted) {
    return true;
  }

  var status = await Permission.manageExternalStorage.request();
  return status.isGranted;
}
=======
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF414A4C), // #414a4c
          secondary: Color(0xFF3B444B), // #3b444b
          surface: Color(0xFF353839), // #353839
          background: Color(0xFF232B2B), // #232b2b
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        fontFamily: "NeoFolia",
        scaffoldBackgroundColor: const Color(0xFF232B2B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF232B2B),
          elevation: 4,
        ),
      ),
      home: const SetUpPage(),
    );
  }
}
>>>>>>> 777f43b (Auto commit from automation tool)
