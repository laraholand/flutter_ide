
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LspService {
  Future<String?> get _dartLspPath async {
    final appDir = await getApplicationSupportDirectory();
    final flutterSdkPath = '${appDir.path}/flutter';
    final dartSdkPath = '$flutterSdkPath/bin/cache/dart-sdk';
    final dartLspPath = '$dartSdkPath/bin/dart_language_server';

    if (await File(dartLspPath).exists()) {
      return dartLspPath;
    }
    return null;
  }

  Future<Process?> start() async {
    final path = await _dartLspPath;
    if (path != null) {
      return await Process.start(path, []);
    }
    return null;
  }
}
