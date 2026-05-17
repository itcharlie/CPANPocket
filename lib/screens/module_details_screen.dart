import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    _fetchMarkdown();
  }

  Future<void> _fetchMarkdown() async {
    try {
      if (widget.localFilePath != null) {
        final content = await File(widget.localFilePath!).readAsString();
        setState(() {
          _markdownData = content;
          _isLoading = false;
        });
      } else {
        final response = await http.get(Uri.parse(
            'https://fastapi.metacpan.org/v1/pod/${widget.moduleName}?content-type=text/x-markdown'));
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
