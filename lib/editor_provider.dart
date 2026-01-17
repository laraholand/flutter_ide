import 'dart:io';

import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';

class EditorProvider with ChangeNotifier {
  final List<File> _openFiles = [];
  final Map<String, String> _fileContents = {};
  final Map<String, CodeForgeController> _controllers = {};
  int _currentIndex = -1;

  LspConfig? _lspConfig;

  LspConfig? get lspConfig => _lspConfig;

  List<File> get openFiles => _openFiles;
  Map<String, String> get fileContents => _fileContents;
  Map<String, CodeForgeController> get controllers => _controllers;
  int get currentIndex => _currentIndex;
  File? get currentFile =>
      _currentIndex != -1 ? _openFiles[_currentIndex] : null;
  CodeForgeController? get currentController =>
      currentFile != null ? _controllers[currentFile!.path] : null;

  void setLspConfig(LspConfig lspConfig) {
    _lspConfig = lspConfig;
    notifyListeners();
  }

  Future<void> openFile(File file) async {
    if (!_openFiles.contains(file)) {
      _openFiles.add(file);
      _currentIndex = _openFiles.length - 1;
      final content = await file.readAsString();
      _fileContents[file.path] = content;
      _controllers[file.path] = CodeForgeController(lspConfig: _lspConfig);
      _controllers[file.path]?.text = content;
      notifyListeners();
    } else {
      _currentIndex = _openFiles.indexOf(file);
      notifyListeners();
    }
  }

  void closeFile(int index) {
    final file = _openFiles[index];
    _fileContents.remove(file.path);
    _controllers[file.path]?.dispose();
    _controllers.remove(file.path);
    _openFiles.removeAt(index);
    if (_currentIndex >= index) {
      _currentIndex = _currentIndex > 0 ? _currentIndex - 1 : -1;
    }
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateFileContent(String filePath, String content) {
    _fileContents[filePath] = content;
  }

  Future<void> saveCurrentFile() async {
    if (currentFile != null) {
      final content = _controllers[currentFile!.path]?.text;
      if (content != null) {
        await currentFile!.writeAsString(content);
      }
    }
  }

  @override
  void dispose() {
    _lspConfig?.dispose();
    super.dispose();
  }
}