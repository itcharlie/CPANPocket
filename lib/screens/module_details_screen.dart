import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:http/http.dart' as http;
import 'package:cpanpocket/utils/pod_storage.dart';

class ModuleDetailsScreen extends StatefulWidget {
  final String moduleName;
  final String? localFilePath;

  const ModuleDetailsScreen({
    super.key,
    required this.moduleName,
    this.localFilePath,
  });

  @override
  State<ModuleDetailsScreen> createState() => _ModuleDetailsScreenState();
}

class _ModuleDetailsScreenState extends State<ModuleDetailsScreen> {
  String _markdownData = '';
  bool _isLoading = true;
  String? _error;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _isDownloaded = widget.localFilePath != null;
    _fetchMarkdown();
  }

  Future<void> _fetchMarkdown() async {
    try {
      String? localPath = widget.localFilePath;
      if (localPath == null) {
        final isCached = await PodStorage.isPodDownloaded(widget.moduleName);
        if (isCached) {
          localPath = await PodStorage.getPodFilePath(widget.moduleName);
        }
      }

      if (localPath != null) {
        final content = await File(localPath).readAsString();
        setState(() {
          _markdownData = content;
          _isDownloaded = true;
          _isLoading = false;
        });
      } else {
        final response = await http.get(
          Uri.parse(
              'https://fastapi.metacpan.org/v1/pod/${widget.moduleName}?content-type=text/x-markdown'),
          headers: {
            'User-Agent': 'CPANPocket', // Custom User-Agent string
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            _markdownData = response.body;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Failed to load POD: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isDownloaded)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                if (_markdownData.isNotEmpty) {
                  await PodStorage.savePod(widget.moduleName, _markdownData);
                  setState(() {
                    _isDownloaded = true;
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloaded ${widget.moduleName}')),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Markdown(
                  data: _markdownData,
                  selectable: true,
                ),
    );
  }
}
