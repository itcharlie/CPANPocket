import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:cpanpocket/screens/module_details_screen.dart';
import 'package:cpanpocket/utils/pod_storage.dart';

class PodReaderScreen extends StatefulWidget {
  const PodReaderScreen({super.key});

  @override
  State<PodReaderScreen> createState() => PodReaderScreenState();
}

class PodReaderScreenState extends State<PodReaderScreen> {
  List<Map<String, dynamic>> _filesWithVersions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMarkdownFiles();
  }

  Future<void> loadMarkdownFiles() async {
    try {
      final mdFiles = await PodStorage.getDownloadedPods();
      final filesWithVersions = await Future.wait(mdFiles.map((file) async {
        final version = await PodStorage.getPodVersion(file);
        return {
          'file': file,
          'version': version,
        };
      }));

      setState(() {
        _filesWithVersions = filesWithVersions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading markdown files: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _filesWithVersions.isEmpty
            ? const Center(child: Text('No local Pod documentation found.'))
            : ListView.builder(
                itemCount: _filesWithVersions.length,
                itemBuilder: (context, index) {
                  final item = _filesWithVersions[index];
                  final file = item['file'] as File;
                  final version = item['version'] as String;
                  final fileName = p.basename(file.path);
                  final displayTitle = fileName.replaceAll('.md', '').replaceAll('-', '::');

                  return ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(displayTitle),
                    subtitle: Text('Version: $version | Local: $fileName'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await PodStorage.deletePod(file);
                        loadMarkdownFiles();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModuleDetailsScreen(
                            moduleName: displayTitle,
                            version: version,
                            localFilePath: file.path,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
  }
}
