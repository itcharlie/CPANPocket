
import 'dart:io';
import 'dart:convert';

/// Main entry point for the web client.
/// Usage: dart webclient.dart [search_string]
Future<void> main(List<String> args) async {

  // Use "JSON" as a default search string if none provided
  final searchString = args.isNotEmpty ? args[0] : "JSON";
  print("Searching MetaCPAN for modules matching: $searchString");
  
  String escapeColons( String text) { return text.replaceAll(':', r'\:'); }
  String escapeSearchString = escapeColons(searchString);
 
  print("Searching MetaCPAN for modules matching: $escapeSearchString");

  // MetaCPAN FastAPI endpoint for module search
  // Using module.name with a wildcard for prefix matching
  final apiUrl = "https://fastapi.metacpan.org/v1/module/_search?q=module.name:$escapeSearchString*&size=20";
  
  final client = HttpClient();

  try {
    final request = await client.getUrl(Uri.parse(apiUrl));
    final response = await request.close();

    if (response.statusCode == HttpStatus.ok) {
      final jsonString = await response.transform(utf8.decoder).join();
      final data = json.decode(jsonString);
      
      final hits = data['hits']?['hits'] as List?;

      if (hits == null || hits.isEmpty) {
        print("No modules found for '$searchString'.");
      } else {
        print("\nFound ${hits.length} modules:");
        
        // Extract unique module names that match the search criteria
        final moduleNames = <String>{};
        for (var hit in hits) {
          final source = hit['_source'];
          if (source != null && source['module'] != null) {
            for (var mod in source['module']) {
              final name = mod['name'] as String?;
              if (name != null && name.toLowerCase().contains(searchString.toLowerCase())) {
                moduleNames.add(name);
              }
            }
          }
        }

        final sortedNames = moduleNames.toList()..sort();
        for (final name in sortedNames) {
          print(" - $name");
        }
      }
    } else {
      print("Error: ${response.statusCode} ${response.reasonPhrase}");
    }
  } catch (e) {
    print("An error occurred while fetching data: $e");
  } finally {
    // Always close the client to free up resources
    client.close();
  }
}
