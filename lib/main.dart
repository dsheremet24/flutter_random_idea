import 'package:english_words/english_words.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? kKey}) : super(key: kKey);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        // debugShowCheckedModeBanner: false,
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var allWordPair = <WordPair>[];
  var currentIndex = 0;

  MyAppState() {
    allWordPair.add(current);
  }

  void getNext() {
    ++currentIndex;
    current = allWordPair.isEmpty
        ? current
        : ((allWordPair.length - 1) >= currentIndex
            ? allWordPair[currentIndex]
            : WordPair.random());

    if (currentIndex > allWordPair.length - 1) {
      allWordPair.add(current);
    }
    print('getNext $currentIndex ${allWordPair[currentIndex]}');
    print('all $allWordPair');

    notifyListeners();
  }

  void getBack() {
    if(allWordPair.isNotEmpty && currentIndex - 1 > -1) {
      --currentIndex;
      current = allWordPair[currentIndex];

      print('getBack $currentIndex ${allWordPair[currentIndex]}');

      notifyListeners();
    }
  }

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }

    notifyListeners();
    print(favorites);
  }
  // void toggleFavorite() {
  //   if (favorites.contains(current)) {
  //     favorites.remove(current);
  //   } else {
  //     favorites.add(current);
  //   }
  //
  //   notifyListeners();
  //   print(favorites);
  // }

  void removeFavorite(pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class FavoritesPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var theme = Theme.of(context);

    if(appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    var sortedFavorites = appState.favorites?..sort((a, b) => (a.first + a.second).toLowerCase().compareTo((b.first + b.second).toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var fav in sortedFavorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(fav);
                    },
                    tooltip: 'Delete',
                  ),
                  title: Tooltip(
                    message: 'Delete', // Text to show in the tooltip
                    child: GestureDetector(
                      onTap: () {
                        // Handle click action for the title
                        appState.removeFavorite(fav);
                        print('Title clicked: ${fav.asPascalCase}');
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click, // Changes the cursor to indicate clickable text
                        child: RichText(
                          text: TextSpan(
                            text: fav.asLowerCase,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline, // Optional clickable look
                            ),
                            semanticsLabel: fav.asPascalCase,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Handle click action for the title
                                appState.removeFavorite(fav);
                                print('RichText clicked: ${fav.asPascalCase}');
                              },
                          ),
                        ),
                      ),
                    ),
                  ), // GestureDetector ends
                ),
            ],
          ),
        )
      ],
    );

  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
      return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError("No widget for $selectedIndex");
    }

    var colorScheme = Theme.of(context).colorScheme;
    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );


    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HistoryView(appState: appState),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(onPressed: () {
                appState.getBack();
              }, child: Text('Back')),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],//Column children []
      ),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontSize: 20,      // Optional: Set font size
      fontWeight: FontWeight.bold, // Optional: Set font weight
    );

    return Expanded(
      flex: 3,
      child: Container(
        alignment: Alignment.center, // Ensures the child is centered
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300, // Limits the width for better centering
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
              ),
              for (var pair in appState.allWordPair)
                ListTile(
                  leading: IconButton(
                    icon: appState.favorites.contains(pair)
                        ? Icon(Icons.favorite, size: 12)
                        : SizedBox(),
                    onPressed: () {
                      appState.toggleFavorite(pair);
                    },
                  ),
                  title: appState.current == pair? Text(pair.asLowerCase,  style: style) : Text(pair.asLowerCase),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  final WordPair pair;

  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
        child: Padding(
      padding: const EdgeInsets.all(8.0),
          child: Text(
            pair.asPascalCase,
            style: style,
            semanticsLabel: pair.asCamelCase,
          ),
    )
    );
  }
}