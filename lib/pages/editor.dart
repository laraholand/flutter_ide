import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:code_forge/code_forge.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:ide/file_tree_view.dart';
import 'package:ide/dynamic_tabbar.dart';
import 'package:path_provider/path_provider.dart';

class EditorPage extends StatefulWidget {
  final String path; // Project root path
  const EditorPage({Key? key, required this.path}) : super(key: key);

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  bool isRunning = false;
  Process? flutterProcess;
  Future<String> getFlutterExecutable() async {
    Directory dir = await getApplicationSupportDirectory();
    return "${dir.path}/flutter/bin/flutter";
  }
  void runApp() async {
    final flutterExe = await getFlutterExecutable();

    flutterProcess = await Process.start(
      flutterExe,
      ['run', '-d', 'web-server', '--web-port', '8080'],
      mode: ProcessStartMode.detachedWithStdio,
    );

    // stdout and stderr print
    flutterProcess!.stdout.transform(SystemEncoding().decoder).listen((data) {
      print(data);
    });
    flutterProcess!.stderr.transform(SystemEncoding().decoder).listen((data) {
      print("Error: $data");
    });

    setState(() {
      isRunning = true;
    });
  }

  void hotReload() {
    if (flutterProcess != null) {
      flutterProcess!.stdin.write('r\n'); // hot reload
    }
  }

  void hotRestart() {
    if (flutterProcess != null) {
      flutterProcess!.stdin.write('R\n'); // hot restart
    }
  }

  void stopApp() {
    if (flutterProcess != null) {
      flutterProcess!.kill();
      setState(() {
        isRunning = false;
      });
    }
  }
  // sync function
  void syncProject() async {
    final flutterExe = await getFlutterExecutable();
  
    Process syncProcess = await Process.start(
      flutterExe,
      ['pub', 'get'],
      mode: ProcessStartMode.detachedWithStdio,
      workingDirectory: widget.path, // project root
    );
  
    // stdout / stderr print
    syncProcess.stdout.transform(SystemEncoding().decoder).listen((data) {
      print(data);
    });
    syncProcess.stderr.transform(SystemEncoding().decoder).listen((data) {
      print("Error: $data");
    });
  
    // optional: completion message
    syncProcess.exitCode.then((code) {
      print("Sync finished with exit code $code");
    });
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
      content: Text("Welcome to new VS code in desktop. Be carefull the ide only for desktop"),
    ),
  ];

  final undoController = UndoRedoController();
  CodeForgeController? codeController;

  Future<LspConfig> getLsp() async {
    final absWorkspacePath = widget.path; // Project root
    final data = await LspStdioConfig.start(
      executable: "dart",
      args: ["language-server", "--protocol=lsp"],
      workspacePath: absWorkspacePath,
      languageId: "dart",
    );
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isRunning) ...[
            IconButton(
              icon: Icon(Icons.refresh_rounded),
              onPressed:hotReload,
              tooltip: "Hot reload",
            ),
            IconButton(
              icon: Icon(Icons.restart_alt_rounded),
              onPressed: hotRestart,
              tooltip: "Hot Restart",
            ),
            IconButton(
              icon: Icon(Icons.stop_circle_rounded),
              onPressed: stopApp,
              tooltip: "Stop App",
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.play_arrow_rounded),
              onPressed:runApp,
              tooltip: "Run",
            ),
            IconButton(
              icon: Icon(Icons.sync_rounded),
              onPressed: syncProject,
              tooltip: "Sync",
            ),
          ],
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (){},
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
                    content: EditFile(filePath: file.path),
                  ),
                );
              });
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
  const EditFile({Key? key, required this.filePath}) : super(key: key);

  @override
  State<EditFile> createState() => _EditFileState();
}

class _EditFileState extends State<EditFile> {
  UndoRedoController undoRedoController = UndoRedoController();
  CodeForgeController? codeController;

  Future<LspConfig> getLsp() async {
    Directory dir = await getApplicationSupportDirectory();
    final executable = "${dir.path}/flutter/bin/cache/dart-sdk/bin/dart";
    final absWorkspacePath = p.dirname(widget.filePath);
    final data = await LspStdioConfig.start(
      executable: executable,
      args: ["language-server", "--protocol=lsp"],
      workspacePath: absWorkspacePath,
      languageId: "dart",
    );
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LspConfig>(
      future: getLsp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
  
        // যদি error থাকে
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 10),
                Text(
                  "Failed to load LSP",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  snapshot.error.toString(), // error message
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // retry by rebuilding
                  },
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }
  
        if (!snapshot.hasData) {
          return const Center(child: Text("No data received from LSP"));
        }
  
        final lspConfig = snapshot.data!;
        if (codeController == null || codeController!.lspConfig != lspConfig) {
          codeController = CodeForgeController(lspConfig: lspConfig);
        }
  
        return CodeForge(
          undoController: undoRedoController,
          language: langDart,
          controller: codeController,
          filePath: widget.filePath,
          textStyle: GoogleFonts.jetBrainsMono(),
        );
      },
    );
  }
}