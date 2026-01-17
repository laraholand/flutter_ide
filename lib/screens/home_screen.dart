import 'dart:io';

import 'package:ide/services/documentation_service.dart';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _output = '';
  final _projectNameController = TextEditingController();

  Future<void> _createProject(String projectName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final projectsDir = Directory('${appDir.path}/projects');
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    final projectDir = Directory('${projectsDir.path}/$projectName');
    if (await projectDir.exists()) {
      setState(() {
        _output = 'Project already exists';
      });
      return;
    }

    final flutterExecutable = '${appDir.path}/flutter/bin/flutter';
    final processResult = await run(
      '$flutterExecutable create $projectName',
      workingDirectory: projectsDir.path,
      onProcess: (process) {
        process.stdout.transform(const SystemEncoding().decoder).listen((data) {
          setState(() {
            _output += data;
          });
        });
        process.stderr.transform(const SystemEncoding().decoder).listen((data) {
          setState(() {
            _output += data;
          });
        });
      },
    );

    if (processResult.exitCode == 0) {
      setState(() {
        _output += '\nProject created successfully!';
      });
      await DocumentationService().downloadDocumentation(projectDir.path);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectScreen(
            projectPath: '${projectsDir.path}/$projectName',
          ),
        ),
      );
    } else {
      setState(() {
        _output += '\nError creating project.';
      });
    }
  }

  Future<void> _showCreateProjectDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Project'),
          content: TextField(
            controller: _projectNameController,
            decoration: const InputDecoration(hintText: "Project Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                _createProject(_projectNameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter IDE'),
      ),
      drawer: const Drawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showCreateProjectDialog,
              child: const Text('Create New Project'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_output),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
