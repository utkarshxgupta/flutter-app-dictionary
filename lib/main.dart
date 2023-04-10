import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Store',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class Game {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String shortDescription;
  final String gameUrl;
  final String genre;
  final String platform;
  final String publisher;
  final String developer;
  final String releaseDate;
  final String profileUrl;

  Game({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.shortDescription,
    required this.gameUrl,
    required this.genre,
    required this.platform,
    required this.publisher,
    required this.developer,
    required this.releaseDate,
    required this.profileUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnail'],
      shortDescription: json['short_description'],
      gameUrl: json['game_url'],
      genre: json['genre'],
      platform: json['platform'],
      publisher: json['publisher'],
      developer: json['developer'],
      releaseDate: json['release_date'],
      profileUrl: json['profile_url'],
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Game>> _futureGames;
  final int _pageSize = 24;
  int displayedGamesCount = 0;
  List<Game> _games = [];
  String platformFilter = 'All';
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _futureGames = _fetchGames();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      print('reached the bottom');
      setState(() {
        displayedGamesCount += _pageSize;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Game>> _fetchGames() async {
    final response =
        await http.get(Uri.parse('http://www.mmobomb.com/api1/games'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> gamesJson = jsonDecode(response.body);
      final List<Game> games =
          gamesJson.map((json) => Game.fromJson(json)).toList();

      return games;
    } else {
      throw Exception('Failed to fetch games');
    }
  }

  Future<List<Game>> _fetchGamesFilter(String platform) async {
    platform = platform.toLowerCase();
    final response = await http
        .get(Uri.parse('http://www.mmobomb.com/api1/games?platform=$platform'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> gamesJson = jsonDecode(response.body);
      final List<Game> games =
          gamesJson.map((json) => Game.fromJson(json)).toList();

      return games;
    } else {
      throw Exception('Failed to fetch games');
    }
  }

  Widget _buildGameItem(Game game) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 16,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title:
                Text(game.title, style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(game.thumbnailUrl, fit: BoxFit.cover),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Text('Genre: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(game.genre),
                  ],
                ),
                Row(
                  children: [
                    Text('Platform: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(game.platform),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Publisher: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(game.publisher,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                Row(
                  children: [
                    Text('Developer: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(game.developer,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                Row(
                  children: [
                    Text('Release Date: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(game.releaseDate),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(game.shortDescription,
                    textAlign: TextAlign.justify,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(game.thumbnailUrl, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              game.title,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.0),
            Text(
              game.genre,
              style: TextStyle(fontSize: 12.0),
              maxLines: 1,
            ),
            SizedBox(height: 4.0),
            Text(
              'Platform: ${game.platform}',
              style: TextStyle(fontSize: 12.0),
            ),
            SizedBox(height: 4.0),
            Text(
              'Release date: ${game.releaseDate}',
              style: TextStyle(fontSize: 12.0),
            ),
          ],
          // open a dialog with game information when tapped
        ),
      ),
    );
  }

  Widget buildGameList(List<Game> games) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width ~/ 200,
      padding: EdgeInsets.all(8.0),
      physics: BouncingScrollPhysics(),
      controller: _scrollController,
      children: games.take(displayedGamesCount).map(_buildGameItem).toList(),
    );
  }

  Widget _filters() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Platform: '), //Platform filter
            DropdownButton<String>(
              value: platformFilter,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
              underline: Container(
                height: 2,
                color: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 10),
              ),
              items: <String>[
                'All',
                'PC',
                'Browser',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('   ' + value + '    '),
                );
              }).toList(),
              onChanged: (String? newValue) {
                print(newValue);
                setState(() {
                  platformFilter = newValue!;
                  Navigator.pop(context);
                  filterModalSheet(context);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Store'),
        actions: <Widget>[
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.filter_alt_rounded),
                onPressed: () {
                  filterModalSheet(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // show search bar
                  showSearch(
                      context: context,
                      delegate: SearchBar(_games, buildGameList));
                },
              ),
            ],
          )
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Game>>(
          future: _futureGames,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _games = snapshot.data!;
              displayedGamesCount = _pageSize + displayedGamesCount;
              return buildGameList(_games);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<dynamic> filterModalSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text('Filters',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(
                height: 20,
              ),
              _filters(),
              SizedBox(
                height: 20,
              ),
              // Apply button to apply filters
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _futureGames = _fetchGamesFilter(platformFilter);
                  });
                  Navigator.pop(context);
                  //reset scroll position with animation
                  _scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                },
                // add padding to the button
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                ),
                child: Text('Apply', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SearchBar extends SearchDelegate {
  List<Game> games;
  Widget Function(List<Game>) buildGameList2;
  SearchBar(this.games, this.buildGameList2);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Game> matchQuery = [];

    for (var gm in games) {
      if (gm.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(gm);
      }
    }
    return buildGameList2(matchQuery);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Game> matchQuery = [];

    for (var gm in games) {
      if (gm.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(gm);
      }
    }
    return buildGameList2(matchQuery);
  }
}
