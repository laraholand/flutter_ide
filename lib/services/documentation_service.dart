import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';

class DocumentationService {
  Future<void> downloadDocumentation(String projectPath) async {
    final pubspecFile = File('$projectPath/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      return;
    }

    final pubspecContent = await pubspecFile.readAsString();
    final pubspecYaml = loadYaml(pubspecContent);
    final dependencies = pubspecYaml['dependencies'] as YamlMap?;

    if (dependencies == null) {
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory('${appDir.path}/documentation');
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }

    for (final packageName in dependencies.keys) {
      final packageDocFile = File('${docsDir.path}/$packageName.md');
      await packageDocFile.writeAsString('# $packageName\n\nThis is the offline documentation for the $packageName package.');
    }
  }
}
