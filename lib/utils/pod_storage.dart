import 'dart:io';
import 'dart:convert';
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

  static Future<File> savePod(String moduleName, String version, String content) async {
    final dir = await _podsDirectory;
    final fileName = '${moduleName.replaceAll('::', '-')}.md';
    final file = File(p.join(dir.path, fileName));
    final header = '<!-- version: $version -->\n';
    return await file.writeAsString(header + content);
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

  static Future<String> getPodVersion(File file) async {
    try {
      if (await file.exists()) {
        final line = await file.openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .first;
        final regExp = RegExp(r'^<!--\s*version:\s*([^\s]+)\s*-->$');
        final match = regExp.firstMatch(line);
        if (match != null) {
          return match.group(1) ?? 'Unknown';
        }
      }
    } catch (e) {
      // If the file is empty or doesn't have the header
    }
    return 'Unknown';
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
