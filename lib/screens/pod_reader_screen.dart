import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:cpanpocket/screens/module_details_screen.dart';
import 'package:cpanpocket/utils/pod_storage.dart';

class PodReaderScreen extends StatefulWidget {
  const PodReaderScreen({super.key});

  @override
  State<PodReaderScreen> createState() => _PodReaderScreenState();
}

class _PodReaderScreenState extends State<PodReaderScreen> {
  List<File> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkdownFiles();
  }

  Future<void> _loadMarkdownFiles() async {
    try {
      final mdFiles = await PodStorage.getDownloadedPods();

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
                    final displayTitle = fileName.replaceAll('.md', '').replaceAll('-', '::');

                    return ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(displayTitle),
                      subtitle: Text('Local: $fileName'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await PodStorage.deletePod(file);
                          _loadMarkdownFiles();
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModuleDetailsScreen(
                              moduleName: displayTitle,
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
