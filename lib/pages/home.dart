import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ide/pages/editor.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

void _showDialog(BuildContext context) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController pathController = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Create Flutter Project"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Project Name (lowercase)",
                hintText: "my_app",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: pathController,
              decoration: InputDecoration(
                labelText: "Project Path",
                hintText: "/storage/emulated/0/MyProjects",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String projectName = nameController.text.trim();
              String projectPath = pathController.text.trim();

              // Validation
              if (projectName.isEmpty || projectName != projectName.toLowerCase()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Project name must be lowercase!")),
                );
                return;
              }
              if (projectPath.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Project path required!")),
                );
                return;
              }

              Navigator.pop(context); // close dialog

              // Create project using Flutter CLI
              String fullPath = "$projectPath/$projectName";

              try {
                ProcessResult result = await Process.run(
                  "${await path()}flutter",
                  ["create", projectName],
                  workingDirectory: projectPath,
                  runInShell: true,
                );

                if (result.exitCode == 0) {
                  if(!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditorPage(path: fullPath),
                    ),
                  );
                } else {
                  if(!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error creating project")),
                  );
                }
              } catch (e) {
                if(!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to run Flutter CLI")),
                );
              }
            },
            child: Text("Create"),
          ),
        ],
      );
    },
  );
}
  Future<String?> path() async{
    Directory dir = await getApplicationSupportDirectory();
    return "${dir.path}/flutter/bin/";
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: ()=>_showDialog(context),
          child: Text("Create new project"),
        ),
        TextButton(
          onPressed: () async{
            String? selectedDir = await FilePicker.platform.getDirectoryPath();
            if(selectedDir==null) return;
            if(!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EditorPage(path:selectedDir)),
            );
          },
          child: Text("Open existing project"),
        ),
      ],
    );
  }
}

