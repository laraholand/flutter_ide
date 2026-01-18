import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ide/pages/home.dart';

class SetupSdk extends StatefulWidget {
  const SetupSdk({Key? key}) : super(key: key);

  @override
  State<SetupSdk> createState() => _SetupSdkState();
}

class _SetupSdkState extends State<SetupSdk> {
  double progress = 0.0;
  String status = "Idle";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SDK Setup")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: progress > 0 && progress < 1
                    ? null
                    : () async {
                        final success = await pickAndExtractZip(
                          onProgress: (p, s) {
                            if (!mounted) return;
                            setState(() {
                              progress = p;
                              status = s;
                            });
                          },
                        );

                        if (!mounted) return;

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomePage(),
                            ),
                          );
                        }
                      },
                child: const Text("Setup SDK"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= ZIP PICK & EXTRACT =================
Future<bool> pickAndExtractZip({
  required Function(double progress, String status) onProgress,
}) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['zip'],
  );

  if (result == null) return false;

  final String? zipPath = result.files.single.path;
  if (zipPath == null) return false;

  final Directory appDir = await getApplicationSupportDirectory();

  onProgress(0, "Opening ZIP...");

  final inputStream = InputFileStream(zipPath);
  final archive = ZipDecoder().decodeStream(inputStream);

  final int totalFiles = archive.length;
  int extractedFiles = 0;

  for (final file in archive) {
    final String outPath = "${appDir.path}/${file.name}";

    if (file.isFile) {
      final outFile = File(outPath);
      await outFile.create(recursive: true);

      final outputStream = OutputFileStream(outFile.path);
      file.writeContent(outputStream);
      await outputStream.close();
    } else {
      await Directory(outPath).create(recursive: true);
    }

    extractedFiles++;
    onProgress(
      extractedFiles / totalFiles,
      "Extracting ${file.name}",
    );
  }

  onProgress(1.0, "SDK setup completed successfully ✅");
  return true;
}