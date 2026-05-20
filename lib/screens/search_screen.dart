import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cpanpocket/screens/module_details_screen.dart';
import 'package:cpanpocket/utils/pod_storage.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _refreshDownloadStatuses() async {
    if (_searchResults.isEmpty) return;
    try {
      final updatedResults = await Future.wait(_searchResults.map((mod) async {
        final name = mod['name'] as String;
        final isDownloaded = await PodStorage.isPodDownloaded(name);
        return {
          ...mod,
          'isDownloaded': isDownloaded,
        };
      }));
      if (mounted) {
        setState(() {
          _searchResults = updatedResults;
        });
      }
    } catch (e) {
      debugPrint('Error updating download statuses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SearchBar(
            leading: const Icon(Icons.search), // The magnifying glass icon
            hintText: 'Search...',
            onSubmitted: (value) async {
              setState(() {
                _isLoading = true;
              });
              try {
                final results = await performSearch([value]);
                final updatedResults = await Future.wait(results.map((mod) async {
                  final name = mod['name'] as String;
                  final isDownloaded = await PodStorage.isPodDownloaded(name);
                  return {
                    ...mod,
                    'isDownloaded': isDownloaded,
                  };
                }));
                setState(() {
                  _searchResults = updatedResults;
                  _isLoading = false;
                });
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_searchResults.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No results found.'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final module = _searchResults[index];
                final moduleName = module['name'] ?? 'Unknown Module';
                final isDownloaded = module['isDownloaded'] == true;

                return ListTile(
                  title: Text(moduleName),
                  subtitle: Text('Version: ${module['version']}'),
                  leading: const Icon(Icons.library_books),
                  trailing: isDownloaded
                      ? const IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: null,
                        )
                      : IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            try {
                              final response = await http.get(
                                Uri.parse(
                                  'https://fastapi.metacpan.org/v1/pod/$moduleName?content-type=text/x-markdown'),    
                                headers: {
                                   'User-Agent': 'CPANPocket', // Custom User-Agent string
                                  },
                              );
                              debugPrint('Download response status code: ${response.statusCode}');

                              if (response.statusCode == 200) {
                                await PodStorage.savePod(moduleName, response.body);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Downloaded $moduleName')),
                                  );
                                }
                                _refreshDownloadStatuses();
                              } else {
                                throw Exception('Failed to download: ${response.statusCode}');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                        ),
                  onTap: () async {
                    final localPath = isDownloaded
                        ? await PodStorage.getPodFilePath(moduleName)
                        : null;
                    if (context.mounted) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModuleDetailsScreen(
                            moduleName: moduleName,
                            localFilePath: localPath,
                          ),
                        ),
                      );
                      _refreshDownloadStatuses();
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

Future<List<dynamic>> performSearch(List<String> args) async {
  // Use "JSON" as a default search string if none provided
  final searchString = args.isNotEmpty ? args[0] : "JSON";
  
  String escapeColons(String text) => text.replaceAll(':', r'\:');
  String escapeSearchString = escapeColons(searchString);
 
  debugPrint("Searching MetaCPAN for modules matching: $escapeSearchString");

  // MetaCPAN FastAPI endpoint for module search
  final apiUrl = "https://fastapi.metacpan.org/v1/module/_search?q=maturity:released%20AND%20status:cpan%20AND%20module.name:$escapeSearchString*&size=20";

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'User-Agent': 'CPANPocket', // Custom User-Agent string
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final hits = data['hits']?['hits'] as List?;

    if (hits == null || hits.isEmpty) {
      return [];
    } else {
      List<Map<String, dynamic>> perlModules = [];

      for (var hit in hits) {
        final source = hit['_source'];
        if (source != null && source['module'] != null) {
          for (var mod in source['module']) {
            final name = mod['name'] as String?;
            if (name != null && name.toLowerCase().contains(searchString.toLowerCase())) {
              perlModules.add({ 
                'name':  mod['name'],
                'version': mod['version'],
              });
            }
          }
        }
      }
      return perlModules;
    }
  } else {
    throw Exception("** failed to load Data Error: ${response.statusCode} ${response.reasonPhrase}");
  }
}
