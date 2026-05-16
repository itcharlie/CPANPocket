import 'package:flutter/material.dart';

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
      home: const MyHomePage(title: 'Cpan Pocket'),
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,              
          child: 
            SearchBar(
              leading: const Icon(Icons.search), // The magnifying glass icon
              hintText: 'Search...',
              onChanged: (value) {
                 // TODO: cpan search logic here
             },
            ),
        ),
      ),
    );
  }
}
