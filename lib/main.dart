
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter IDE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FlutterSetupScreen(),
    );
  }
}

class FlutterSetupScreen extends StatefulWidget {
  const FlutterSetupScreen({super.key});

  @override
  State<FlutterSetupScreen> createState() => _FlutterSetupScreenState();
}

class _FlutterSetupScreenState extends State<FlutterSetupScreen> {
  String _status = "Checking Flutter SDK...";
  bool _isFlutterSdkReady = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkFlutterSdk();
  }

  Future<void> _checkFlutterSdk() async {
    final directory = await getApplicationSupportDirectory();
    final flutterDir = Directory('${directory.path}/flutter');

    if (await flutterDir.exists()) {
      setState(() {
        _status = "Flutter SDK found!";
        _isFlutterSdkReady = true;
      });
      // Navigate to your main app screen
      _navigateToMainApp();
    } else {
      setState(() {
        _status = "Flutter SDK not found. Please select a Flutter SDK zip file.";
      });
    }
  }

  Future<void> _pickAndExtractZip() async {
    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      setState(() {
        _status = "Storage permission denied.";
      });
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null && result.files.single.path != null) {
      final zipFilePath = result.files.single.path!;
      final directory = await getApplicationSupportDirectory();
      final targetDir = Directory('${directory.path}/flutter');

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      setState(() {
        _status = "Extracting Flutter SDK...";
        _progress = 0.0;
      });

      try {
                final bytes = await File(zipFilePath).readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes, verify: true);

        int extractedFiles = 0;
        int totalFiles = archive.files.length;

        for (final file in archive.files) {
          if (file.isFile) {
            final outputFilePath = '${targetDir.path}/${file.name}';
            await File(outputFilePath).create(recursive: true);
            file.writeContent(OutputFileStream(outputFilePath));
          }
          extractedFiles++;
          setState(() {
            _progress = extractedFiles / totalFiles;
            _status = "Extracting... (${(_progress * 100).toStringAsFixed(0)}%)";
          });
        }

        setState(() {
          _status = "Flutter SDK extracted successfully!";
          _isFlutterSdkReady = true;
          _progress = 1.0;
        });
        _navigateToMainApp();
      } catch (e) {
        setState(() {
          _status = "Error extracting Flutter SDK: $e";
          _progress = 0.0;
        });
      }
    } else {
      setState(() {
        _status = "No zip file selected.";
      });
    }
  }

  void _navigateToMainApp() {
    // Replace this with your actual main application widget
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PlaceholderWidget(
            message: "Welcome to your Flutter IDE!"), // Replace with your IDE's main screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter IDE Setup'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              if (!_isFlutterSdkReady && _progress == 0.0)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: _pickAndExtractZip,
                    child: const Text('Select Flutter SDK Zip'),
                  ),
                ),
              if (_progress > 0.0 && _progress < 1.0)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: LinearProgressIndicator(value: _progress),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder Widget for demonstration. Replace with your actual main app widget.
class PlaceholderWidget extends StatelessWidget {
  final String message;
  const PlaceholderWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter IDE")),
      body: Center(
        child: Text(message),
      ),
    );
  }
}
