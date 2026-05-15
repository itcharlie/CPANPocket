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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
