import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cpan Pocket',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'CPAN Pocket'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
        leading: Builder(
          builder: (context){
          return IconButton(
            onPressed: (){Scaffold.of(context).openDrawer();}, 
            icon: const Icon(Icons.menu),
          );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // TODO: add a menu list of :
      //  1- Search ( this is the main screen )
      //  2- local pod browser ( or Pod Reader )
      //  3- delete cache   ( This will delete all the stored Pods )

      drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Search')
              ),
              ListTile(
                title: const Text('Pod Reader')
              ),
                  ListTile(
                title: const Text('Delete Cache')
              ),
            ],
          ),
        ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[ 
          Padding( 
            padding:const EdgeInsets.all(24.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,              
              child: 
                SearchBar(
                  leading: const Icon(Icons.search), // The magnifying glass icon
                  hintText: 'Search...',
                  onSubmitted: (value) {
                  // TODO: cpan search logic here
                     final perlModules = performSearch([value]);

                     // TODO: Build a list of results
                     // buildlistView();
                  },
                )
            ),
        ),
        ] 
      ),
    );
  }
}

Future<List<dynamic>> performSearch(List<String> args) async {

  // Use "JSON" as a default search string if none provided
  final searchString = args.isNotEmpty ? args[0] : "JSON";
  //print("Searching MetaCPAN for modules matching: $searchString");
  
  String escapeColons( String text) { return text.replaceAll(':', r'\:'); }
  String escapeSearchString = escapeColons(searchString);
 
  print("Searching MetaCPAN for modules matching: $escapeSearchString");

  // MetaCPAN FastAPI endpoint for module search
  // Using module.name with a wildcard for prefix matching
  final apiUrl = "https://fastapi.metacpan.org/v1/module/_search?q=module.name:$escapeSearchString*&size=20";


  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode ==  200 ) {
      final data = jsonDecode(response.body);
      //print( data );
      
      final hits = data['hits']?['hits'] as List?;

      if (hits == null || hits.isEmpty) {
        print("No modules found for '$searchString'.");
      } else {
        print("\nFound ${hits.length} modules:");
        
        List<Map<String, dynamic>> perlModules =[];

        // Extract unique module names that match the search criteria
        final moduleNames = <String>{};
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

        final sortedNames = moduleNames.toList()..sort();
        for (final name in sortedNames) {
          print(" - $name");
        }

        print( "Perl Modules : ");
        print(perlModules);
        return perlModules;


      }
    } else {
      throw Exception("** failed to load Data Error: ${response.statusCode} ${response.reasonPhrase}");
    }
    return [];
}

