import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

class SetupScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const SetupScreen({super.key, required this.onSetupComplete});

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String _progressText = '';
  bool _isExtracting = false;

  Future<void> _pickAndExtractFlutterZip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final flutterDir = Directory('${appDir.path}/flutter');

      if (!await flutterDir.exists()) {
        await flutterDir.create(recursive: true);
      }

      setState(() {
        _isExtracting = true;
        _progressText = 'Extracting Flutter SDK...';
      });

      try {
        final inputStream = InputFileStream(file.path);
        final archive = ZipDecoder().decodeBuffer(inputStream);
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            final outFile = File('${flutterDir.path}/$filename');
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(data);
          } else {
            final dir = Directory('${flutterDir.path}/$filename');
            await dir.create(recursive: true);
          }
          setState(() {
            _progressText = 'Extracted: $filename';
          });
        }
        setState(() {
          _progressText = 'Extraction Complete!';
          _isExtracting = false;
        });
        widget.onSetupComplete();
      } catch (e) {
        setState(() {
          _progressText = 'Error extracting: $e';
          _isExtracting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter IDE Setup'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isExtracting)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_progressText),
                ],
              )
            else
              ElevatedButton(
                onPressed: _pickAndExtractFlutterZip,
                child: const Text('Select flutter.zip'),
              ),
          ],
        ),
      ),
    );
  }
}
