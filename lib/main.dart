import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'pages/home.dart';
import 'pages/setup.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isSdkInstalled() async {
    final dir = await getApplicationSupportDirectory();
    final sdkDir = Directory('${dir.path}/flutter');
    return sdkDir.existsSync();
  }

  Future<bool> checkPermissions() async {
    bool granted = await requestStoragePermission();
    if (!granted) {
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