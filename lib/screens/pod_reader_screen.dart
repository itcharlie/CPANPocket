import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:cpanpocket/screens/module_details_screen.dart';

class PodReaderScreen extends StatefulWidget {
  const PodReaderScreen({super.key});

  @override
  State<PodReaderScreen> createState() => _PodReaderScreenState();
}

class _PodReaderScreenState extends State<PodReaderScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
            // Note: In a real Flutter app, you'd likely use path_provider to find the documents directory.
            // For this task, we are looking for local markdown files in the project root as per user request.
    _loadMarkdownFiles();
  }

  Future<void> _loadMarkdownFiles() async {
    try {
      // We'll search for .md files in the current working directory (the project root)
      // This is a simplified implementation for the purpose of this task.
      final directory = Directory('.');
      final List<FileSystemEntity> entities = await directory.list(recursive: true, followLinks: false).toList();
      
      final mdFiles = entities.where((entity) => 
        entity is File && entity.path.endsWith('.md') && !entity.path.contains('.git')
      ).toList();

      setState(() {
        _files = mdFiles;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pod Reader'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? const Center(child: Text('No local Pod documentation found.'))
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    final fileName = p.basename(file.path);
                    return ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(fileName),
                      subtitle: Text(p.dirname(file.path)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModuleDetailsScreen(
                              moduleName: fileName,
                              localFilePath: file.path,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
