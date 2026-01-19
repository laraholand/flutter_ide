import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:ide/pages/editor.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  /// Flutter root path: /data/user/0/.../flutter/
  Future<String> _flutterRoot() async {
    final dir = await getApplicationSupportDirectory();
    return "${dir.path}/flutter";
  }

  /// Try to chmod all required flutter / dart binaries
  Future<void> _fixPermissions(BuildContext context) async {
    try {
      final root = await _flutterRoot();

      final targets = [
        p.join(root, "bin"),
        p.join(root, "bin", "flutter"),
        p.join(root, "bin", "cache"),
        p.join(root, "bin", "cache", "dart-sdk"),
        p.join(root, "bin", "cache", "dart-sdk", "bin"),
        p.join(root, "bin", "cache", "dart-sdk", "bin", "dart"),
      ];

      for (final t in targets) {
        if (FileSystemEntity.typeSync(t) != FileSystemEntityType.notFound) {
          await Process.run("chmod", ["-R", "+x", t]);
        }
      }
    } catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Permission Error"),
          content: SingleChildScrollView(
            child: Text(
              e.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _showDialog(BuildContext context) {
    final nameController = TextEditingController();
    final pathController = TextEditingController();

    showDialog<void>(
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
                final projectName = nameController.text.trim();
                final projectPath = pathController.text.trim();

                if (projectName.isEmpty ||
                    projectName != projectName.toLowerCase()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Project name must be lowercase"),
                    ),
                  );
                  return;
                }

                if (projectPath.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Project path required"),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                // 🔑 Permission fix before running flutter
                await _fixPermissions(context);

                final flutterBin =
                    "${await _flutterRoot()}/bin/flutter";
                final fullPath = "$projectPath/$projectName";

                try {
                  final result = await Process.run(
                    flutterBin,
                    ["create", projectName],
                    workingDirectory: projectPath,
                    runInShell: true,
                  );

                  if (result.exitCode == 0) {
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditorPage(path: fullPath),
                      ),
                    );
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Flutter error:\n${result.stderr}",
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Flutter CLI Failed"),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => _showDialog(context),
            child: const Text("Create new project"),
          ),
          TextButton(
            onPressed: () async {
              final selectedDir =
                  await FilePicker.platform.getDirectoryPath();
              if (selectedDir == null || !mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => EditorPage(path: selectedDir),
                ),
              );
            },
            child: const Text("Open existing project"),
          ),
        ],
      ),
    );
  }
}