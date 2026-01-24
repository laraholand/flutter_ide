import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fide/librarys/file_tree_view.dart';
import 'package:path_provider/path_provider.dart';

class IdePage extends StatefulWidget {
  const IdePage({super.key});

  @override
  State<IdePage> createState() => _IdePageState();
}

class _IdePageState extends State<IdePage> {
  String? _rootPath;

  @override
  void initState() {
    super.initState();
    _getRootPath();
  }

  Future<void> _getRootPath() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      _rootPath = directory.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FIDE'),
      ),
      body: _rootPath == null
          ? const Center(child: CircularProgressIndicator())
          : DirectoryTreeViewer(
              rootPath: _rootPath!,
              enableCreateFileOption: true,
              enableCreateFolderOption: true,
              enableDeleteFileOption: true,
              enableDeleteFolderOption: true,
              onFileTap: (file, details) {
                // Handle file tap
              },
            ),
    );
  }
}
