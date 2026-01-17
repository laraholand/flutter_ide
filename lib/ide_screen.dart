
import 'dart:io';

import 'package:file_tree_view/file_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ide/editor/code_editor_screen.dart';
import 'package:ide/editor_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';
import 'package:provider/provider.dart';

class IdeScreen extends StatefulWidget {
  const IdeScreen({super.key});

  @override
  State<IdeScreen> createState() => _IdeScreenState();
}

class _IdeScreenState extends State<IdeScreen> with TickerProviderStateMixin {
  final _projectNameController = TextEditingController();
  String? _projectPath;
  TabController? _tabController;
  Process? _runningProcess;
  bool _isRunning = false;
  InAppWebViewController? _webViewController;

  @override
  void dispose() {
    _tabController?.dispose();
    _runningProcess?.kill();
    super.dispose();
  }

  Future<void> _createProject() async {
    final appDir = await getApplicationSupportDirectory();
    final projectsDir = Directory('${appDir.path}/projects');
    if (!await projectsDir.exists()) {
      await projectsDir.create();
    }

    final projectName = _projectNameController.text;
    if (projectName.isEmpty) {
      return;
    }

    final projectPath = '${projectsDir.path}/$projectName';
    final flutterExecutable = '${appDir.path}/flutter/bin/flutter';

    final shell = Shell();
    try {
      await shell.run(
          '$flutterExecutable create --project-name $projectName $projectPath');
      setState(() {
        _projectPath = projectPath;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create project: $e'),
        ),
      );
    }
  }

  Future<void> _runApp() async {
    if (_projectPath == null) return;
    final flutterExecutable =
        '${(await getApplicationSupportDirectory()).path}/flutter/bin/flutter';
    final shell = Shell(workingDirectory: _projectPath);
    final process = await Process.start(flutterExecutable,
        ['run', '-d', 'web-server', '--web-port', '8080'],
        workingDirectory: _projectPath);
    setState(() {
      _runningProcess = process;
      _isRunning = true;
    });
    _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri('http://localhost:8080')));
  }

  Future<void> _stopApp() async {
    _runningProcess?.kill();
    setState(() {
      _runningProcess = null;
      _isRunning = false;
    });
  }

  Future<void> _hotReload() async {
    _runningProcess?.stdin.writeln('r');
  }

  Future<void> _hotRestart() async {
    _runningProcess?.stdin.writeln('R');
  }

  Future<void> _pubGet() async {
    if (_projectPath == null) return;
    final flutterExecutable =
        '${(await getApplicationSupportDirectory()).path}/flutter/bin/flutter';
    final shell = Shell(workingDirectory: _projectPath);
    try {
      await shell.run('$flutterExecutable pub get');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pub get completed successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pub get failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorProvider>(
      builder: (context, editorProvider, child) {
        if (editorProvider.openFiles.length != _tabController?.length) {
          _tabController = TabController(
              length: editorProvider.openFiles.length, vsync: this);
          _tabController!.addListener(() {
            if (_tabController!.indexIsChanging) {
              editorProvider.setCurrentIndex(_tabController!.index);
            }
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter IDE'),
            actions: [
              if (_projectPath != null) ...[
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () => editorProvider.currentController?.undo(),
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: () => editorProvider.currentController?.redo(),
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => editorProvider.saveCurrentFile(),
                ),
                IconButton(
                  icon: const Icon(Icons.flash_on),
                  onPressed: _hotReload,
                ),
                IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: _hotRestart,
                ),
                IconButton(
                  icon: const Icon(Icons.get_app),
                  onPressed: _pubGet,
                ),
                IconButton(
                  icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                  onPressed: _isRunning ? _stopApp : _runApp,
                ),
              ]
            ],
            bottom: editorProvider.openFiles.isEmpty
                ? null
                : TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: editorProvider.openFiles.map((file) {
                      return Tab(
                        child: Row(
                          children: [
                            Text(p.basename(file.path)),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                editorProvider.closeFile(
                                    editorProvider.openFiles.indexOf(file));
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onTap: (index) {
                      editorProvider.setCurrentIndex(index);
                    },
                  ),
          ),
          drawer: _projectPath != null
              ? Drawer(
                  child: FileTreeView(
                    directory: Directory(_projectPath!),
                    onFileTap: (file) {
                      editorProvider.openFile(file);
                      Navigator.pop(context); // Close the drawer
                    },
                    enableCreateFileOption: true,
                    enableCreateFolderOption: true,
                    enableDeleteFileOption: true,
                    enableDeleteFolderOption: true,
                    fileIconBuilder: (extension) {
                      switch (extension) {
                        case '.dart':
                          return const Icon(Icons.code);
                        case '.yaml':
                          return const Icon(Icons.settings);
                        default:
                          return const Icon(Icons.insert_drive_file);
                      }
                    },
                  ),
                )
              : null,
          body: _projectPath == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _projectNameController,
                          decoration: const InputDecoration(
                            labelText: 'Project Name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _createProject,
                          child: const Text('Create Project'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: editorProvider.openFiles.isEmpty
                          ? const Center(
                              child: Text('Open a file from the drawer.'),
                            )
                          : TabBarView(
                              controller: _tabController,
                              children: editorProvider.openFiles.map((file) {
                                return CodeEditorScreen(
                                  file: file,
                                );
                              }).toList(),
                            ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InAppWebView(
                        initialUrlRequest:
                            URLRequest(url: WebUri('about:blank')),
                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
