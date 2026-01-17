
import 'dart:io';

import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:ide/editor_provider.dart';
import 'package:provider/provider.dart';

class CodeEditorScreen extends StatefulWidget {
  final File file;
  final LspConfig? lspConfig;

  const CodeEditorScreen({super.key, required this.file, this.lspConfig});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  List<LspErrors> _diagnostics = [];

  @override
  void initState() {
    super.initState();
    widget.lspConfig?.responses.listen((response) {
      if (response['method'] == 'textDocument/publishDiagnostics') {
        final params = response['params'];
        if (params['uri'] == Uri.file(widget.file.path).toString()) {
          final diagnostics = (params['diagnostics'] as List)
              .map((d) => LspErrors.fromJson(d))
              .toList();
          setState(() {
            _diagnostics = diagnostics;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorProvider = Provider.of<EditorProvider>(context);
    final controller = editorProvider.controllers[widget.file.path];

    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final editor = CodeForge(
      controller: controller,
      initialValue: controller.text,
      language: 'dart',
      theme: monokaiSublimeTheme,
      lspConfig: widget.lspConfig,
      diagnostics: _diagnostics,
      onChanged: (value) {
        editorProvider.updateFileContent(widget.file.path, value);
      },
    );

    return Scaffold(
      body: editor,
    );
  }
}
