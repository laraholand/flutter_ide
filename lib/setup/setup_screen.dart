import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ide/ide_screen.dart';
import 'package:path_provider/path_provider.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _sdkExists = false;
  String? _extractionProgress;

  @override
  void initState() {
    super.initState();
    _checkSdkExists();
  }

  Future<void> _checkSdkExists() async {
    final appDir = await getApplicationSupportDirectory();
    final sdkDir = Directory('${appDir.path}/flutter');
    setState(() {
      _sdkExists = sdkDir.existsSync();
    });
  }

  Future<void> _pickAndExtractFlutterSdk() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null) {
      final appDir = await getApplicationSupportDirectory();
      final zipFile = File(result.files.single.path!);

      final inputStream = InputFileStream(zipFile.path);
      final archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());

      for (var i = 0; i < archive.length; i++) {
        final file = archive[i];
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File('${appDir.path}/$filename');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(data);
        } else {
          await Directory('${appDir.path}/$filename').create(recursive: true);
        }
        setState(() {
          _extractionProgress =
              'Extracting: ${((i + 1) / archive.length * 100).toStringAsFixed(2)}%';
        });
      }

      setState(() {
        _extractionProgress = 'Extraction Complete!';
        _sdkExists = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter IDE Setup'),
      ),
      body: Center(
        child: _sdkExists
            ? ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IdeScreen(),
                    ),
                  );
                },
                child: const Text('Create New Project'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickAndExtractFlutterSdk,
                    child: const Text('Select flutter.zip'),
                  ),
                  if (_extractionProgress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(_extractionProgress!),
                    ),
                ],
              ),
      ),
    );
  }
}