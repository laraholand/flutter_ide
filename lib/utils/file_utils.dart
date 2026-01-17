import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<bool> checkFlutterSdkExists() async {
  final appDir = await getApplicationDocumentsDirectory();
  final flutterDir = Directory('${appDir.path}/flutter');
  return await flutterDir.exists();
}
