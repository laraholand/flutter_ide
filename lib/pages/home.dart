import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ide/pages/editor.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController pathController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create Flutter Project"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Project Name (lowercase)",
                  hintText: "my_app",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pathController,
                decoration: const InputDecoration(
                  labelText: "Project Path",
                  hintText: "/storage/emulated/0/MyProjects",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String projectName = nameController.text.trim();
                String projectPath = pathController.text.trim();

                // Validation
                if (projectName.isEmpty || projectName != projectName.toLowerCase()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Project name must be lowercase!")),
                  );
                  return;
                }
                if (projectPath.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Project path required!")),
                  );
                  return;
                }

                Navigator.pop(context); // Close dialog

                // Create project using Flutter CLI via Termux Intent
                String fullPath = "$projectPath/$projectName";
                String command = "flutter create $projectName";

                try {
                  await _runTermuxCommand(command, workingDirectory: projectPath, background: false); // Run in foreground to see output if possible
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditorPage(path: fullPath),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error creating project: $e")),
                  );
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runTermuxCommand(String command, {String? workingDirectory, bool background = false}) async {
    final AndroidIntent intent = AndroidIntent(
      action: 'com.termux.RUN_COMMAND',
      package: 'com.termux',
      arguments: <String, dynamic>{
        'com.termux.RUN_COMMAND_PATH': '/data/data/com.termux/files/usr/bin/bash',
        'com.termux.RUN_COMMAND_ARGUMENTS': ['-c', command],
        'com.termux.RUN_COMMAND_WORKDIR': workingDirectory ?? '/data/data/com.termux/files/home',
        'com.termux.RUN_COMMAND_BACKGROUND': background,
      },
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );

    try {
      await intent.launch();
      print('Termux command sent: $command');
    } catch (e) {
      print('Error sending Termux command: $e');
      rethrow; // Re-throw the error to be caught by the calling function
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _showDialog(context),
          child: const Text("Create new project"),
        ),
        TextButton(
          onPressed: () async {
            String? selectedDir = await FilePicker.platform.getDirectoryPath();
            if (selectedDir == null) return;
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EditorPage(path: selectedDir),
              ),
            );
          },
          child: const Text("Open existing project"),
        ),
      ],
    );
  }
}