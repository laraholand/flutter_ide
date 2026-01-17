
import 'dart:io';

import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_highlight/themes/monokai-sublime.dart'; // Commented out due to pub get block
// import 'package:re_highlight/languages/dart.dart'; // Commented out due to pub get block
import 'package:ide/editor_provider.dart';
import 'package:provider/provider.dart';

class CodeEditorScreen extends StatelessWidget {
  final File file;
  final LspConfig? lspConfig;
  final UndoRedoController undoRedoController;

  const CodeEditorScreen({
    super.key,
    required this.file,
    this.lspConfig,
    required this.undoRedoController,
  });

  @override
  Widget build(BuildContext context) {
    final editorProvider = Provider.of<EditorProvider>(context);
    final controller = editorProvider.controllers[file.path];

    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final editor = CodeForge(
      controller: controller,
      language: "dart", // Default to dart language
      // editorTheme: monokaiSublimeTheme, // Commented out due to pub get block
      lspConfig: lspConfig,
      undoController: undoRedoController,
      onChanged: (value) {
        editorProvider.updateFileContent(file.path, value);
      },
    );

    return Scaffold(
      body: editor,
    );
  }
}
