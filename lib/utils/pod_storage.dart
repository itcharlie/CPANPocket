import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PodStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<Directory> get _podsDirectory async {
    final path = await _localPath;
    final podsDir = Directory(p.join(path, 'pods'));
    if (!await podsDir.exists()) {
      await podsDir.create(recursive: true);
    }
    return podsDir;
  }

  static Future<File> savePod(String moduleName, String content) async {
    final dir = await _podsDirectory;
    final fileName = '${moduleName.replaceAll('::', '-')}.md';
    final file = File(p.join(dir.path, fileName));
    return await file.writeAsString(content);
  }

  static Future<List<File>> getDownloadedPods() async {
    final dir = await _podsDirectory;
    final List<FileSystemEntity> entities = await dir.list().toList();
    return entities
        .whereType<File>()
        .where((file) => file.path.endsWith('.md'))
        .toList();
  }

  static Future<bool> isPodDownloaded(String moduleName) async {
    final dir = await _podsDirectory;
    final fileName = '${moduleName.replaceAll('::', '-')}.md';
    return await File(p.join(dir.path, fileName)).exists();
  }

  static Future<String> getPodFilePath(String moduleName) async {
    final dir = await _podsDirectory;
    final fileName = '${moduleName.replaceAll('::', '-')}.md';
    return p.join(dir.path, fileName);
  }

  static Future<void> deletePod(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deleteAllPods() async {
    final dir = await _podsDirectory;
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
