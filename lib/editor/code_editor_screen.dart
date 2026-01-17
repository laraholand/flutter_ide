import 'dart:io';

import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';
import 'package:ide/editor_provider.dart';
import 'package:provider/provider.dart';

class CodeEditorScreen extends StatelessWidget {
  final File file;

  const CodeEditorScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final editorProvider = Provider.of<EditorProvider>(context);
    final controller = editorProvider.controllers[file.path];

    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final editor = CodeForge(
      controller: controller,
    );

    return Scaffold(
      body: editor,
    );
  }
}