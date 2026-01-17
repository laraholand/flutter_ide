import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ide/file_tree_view.dart';
import 'package:ide/dynamic_tabbar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:process_run/process_run.dart';
import 'package:path_provider/path_provider.dart';

class ProjectScreen extends StatefulWidget {
  final String projectPath;

  const ProjectScreen({super.key, required this.projectPath});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final DynamicTabBarController _tabBarController = DynamicTabBarController();
  InAppWebViewController? _webViewController;
  Process? _process;
  bool _isRunning = false;

  Future<void> _runProject() async {
    final appDir = await getApplicationDocumentsDirectory();
    final flutterExecutable = '${appDir.path}/flutter/bin/flutter';
    final shell = Shell(workingDirectory: widget.projectPath);

    setState(() {
      _isRunning = true;
    });

    final process = await shell.run(
      '$flutterExecutable run -d web-server --web-port 8080',
    );

    _process = process.process;

    _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri('http://localhost:8080')));
  }

  Future<void> _stopProject() async {
    _process?.kill();
    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _pubGet() async {
    final appDir = await getApplicationDocumentsDirectory();
    final flutterExecutable = '${appDir.path}/flutter/bin/flutter';
    final shell = Shell(workingDirectory: widget.projectPath);
    await shell.run('$flutterExecutable pub get');
  }

  Future<void> _hotReload() async {
    _process?.stdin.writeln('r');
  }

  Future<void> _hotRestart() async {
    _process?.stdin.writeln('R');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectPath.split('/').last),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _pubGet,
          ),
          if (!_isRunning)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _runProject,
            ),
          if (_isRunning)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopProject,
            ),
          if (_isRunning)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _hotReload,
            ),
          if (_isRunning)
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: _hotRestart,
            ),
        ],
      ),
      drawer: Drawer(
        child: FileTreeView(
          directoryPath: widget.projectPath,
          onFileSelected: (filePath) {
            _tabBarController.addTab(filePath);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: DynamicTabBar(
              controller: _tabBarController,
            ),
          ),
          if (_isRunning)
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri('about:blank')),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
              ),
            ),
        ],
      ),
    );
  }
}
