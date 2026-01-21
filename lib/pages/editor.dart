import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:code_forge/code_forge.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:ide/file_tree_view.dart';
import 'package:ide/dynamic_tabbar.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class EditorPage extends StatefulWidget {
  final String path; // Project root path
  const EditorPage({Key? key, required this.path}) : super(key: key);

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _startLspServer();
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
      // Handle the error appropriately in the UI if needed
    }
  }

  void _startLspServer() {
    // Starts the Dart LSP server in the background
    _runTermuxCommand(
      'dart language-server --port=9000',
      workingDirectory: widget.path,
      background: true,
    );
  }

  void runApp() {
     _runTermuxCommand(
      'flutter run -d web-server --web-port 8080',
      workingDirectory: widget.path,
      background: false, // Run in foreground to see output
    );
    setState(() {
      isRunning = true;
    });
  }

  void stopApp() {
    // This is a bit tricky since we don't have the process ID.
    // A simple approach is to kill all flutter processes, but this could be dangerous.
    // For now, we'll just signal that the app should be stopped.
    // The user might need to manually stop it from Termux.
    _runTermuxCommand('killall flutter');
    setState(() {
      isRunning = false;
    });
  }

  void syncProject() {
     _runTermuxCommand(
      'flutter pub get',
      workingDirectory: widget.path,
      background: false,
    );
  }

  List<TabData> dynamicTabs = [
    TabData(
      index: 0,
      title: Tab(
        text: "untitled",
        icon: IconButton(
          icon: Icon(Icons.cancel_rounded),
          onPressed: () {},
        ),
      ),
      content: Text("Welcome to the IDE. Open a file from the drawer."),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(p.basename(widget.path)),
        actions: [
          if (isRunning) ...[
            IconButton(
              icon: Icon(Icons.stop_circle_rounded),
              onPressed: stopApp,
              tooltip: "Stop App",
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.play_arrow_rounded),
              onPressed: runApp,
              tooltip: "Run",
            ),
          ],
           IconButton(
              icon: Icon(Icons.sync_rounded),
              onPressed: syncProject,
              tooltip: "Sync Dependencies",
            ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (){
              // This needs to be implemented to save the content of the active tab
            },
          )
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: DirectoryTreeViewer(
            rootPath: widget.path,
            enableCreateFileOption: true,
            enableCreateFolderOption: true,
            enableDeleteFileOption: true,
            enableDeleteFolderOption: true,
            onFileTap: (file, tapDownDetails) {
              setState(() {
                // Check if the file is already open
                if (dynamicTabs.any((tab) => tab.title.text == p.basename(file.path))) {
                  // Tab is already open, maybe switch to it
                  return;
                }
                dynamicTabs.add(
                  TabData(
                    index: dynamicTabs.length,
                    title: Tab(
                      text: p.basename(file.path),
                      icon: IconButton(
                        icon: Icon(Icons.cancel_rounded),
                        onPressed: () {
                          setState(() {
                            dynamicTabs.removeWhere(
                                (tab) => tab.title.text == p.basename(file.path));
                          });
                        },
                      ),
                    ),
                    content: EditFile(
                      key: ValueKey(file.path), // Important for state management
                      filePath: file.path,
                      workspacePath: widget.path,
                    ),
                  ),
                );
              });
               Navigator.pop(context); // Close the drawer
            },
          ),
        ),
      ),
      body: DynamicTabBarWidget(
        isScrollable: true,
        showBackIcon: false,
        showNextIcon: false,
        dynamicTabs: dynamicTabs,
        onTabControllerUpdated: (tabController) {},
      ),
    );
  }
}

class EditFile extends StatefulWidget {
  final String filePath;
  final String workspacePath;
  const EditFile({Key? key, required this.filePath, required this.workspacePath}) : super(key: key);

  @override
  State<EditFile> createState() => _EditFileState();
}

class _EditFileState extends State<EditFile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep the state of the editor when switching tabs

  CodeForgeController? _codeController;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    
    // Give the LSP server a moment to start up.
    // A more robust solution might involve a health check.
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _showSnackBar('Attempting to connect to LSP server...');
        final lspConfig = LspSocketConfig(
          serverUrl: 'ws://localhost:9000',
          workspacePath: widget.workspacePath,
          languageId: "dart",
        );
        setState(() {
          _codeController = CodeForgeController(lspConfig: lspConfig);
          _showSnackBar('LSP client controller initialized.');
        });
      } else {
        _showSnackBar('LSP client initialization skipped: widget not mounted.');
      }
    });
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Needed for AutomaticKeepAliveClientMixin
    if (_codeController == null) {
      return const Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    }
    
    return CodeForge(
      language: langDart,
      controller: _codeController!,
      filePath: widget.filePath,
      textStyle: GoogleFonts.jetBrainsMono(),
    );
  }
}