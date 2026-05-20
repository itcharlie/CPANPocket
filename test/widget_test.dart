import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cpanpocket/main.dart';

void main() {
  testWidgets('CPAN Pocket smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Search screen is loaded initially.
    expect(find.text('No results found.'), findsOneWidget);
    expect(find.byType(SearchBar), findsOneWidget);

    // Verify search hint text is correct.
    final searchBarFinder = find.byType(SearchBar);
    final SearchBar searchBarWidget = tester.widget<SearchBar>(searchBarFinder);
    expect(searchBarWidget.hintText, 'Search...');

    // Verify that the drawer can be opened.
    // The menu icon is inside the outer Scaffold's AppBar.
    final menuButtonFinder = find.byIcon(Icons.menu);
    expect(menuButtonFinder, findsOneWidget);
    await tester.tap(menuButtonFinder);
    await tester.pumpAndSettle(); // Wait for drawer animation to finish

    // Verify that drawer menu items exist.
    expect(find.text('CPAN Pocket Menu'), findsOneWidget);
    expect(find.text('Search'), findsNWidgets(2)); // One in the app bar/screen, one in the drawer
    expect(find.text('Pod Reader'), findsOneWidget);
  });
}
