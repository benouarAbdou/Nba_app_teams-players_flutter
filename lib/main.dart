import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiMode, SystemUiOverlayStyle, rootBundle;
import 'package:country_flags/country_flags.dart'; // Assuming you are using this package for flags
import 'package:nba/model/player.dart';
import 'package:nba/model/team.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.blueAccent, // Set the status bar color to white
    statusBarBrightness: Brightness.light, // Set the status bar icons to dark
    statusBarIconBrightness:
        Brightness.dark, // Set the status bar icons to dark
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Folks',
        useMaterial3: false,
        scaffoldBackgroundColor:
            const Color(0xFFEDECF1), // Set the background color here
      ),
      title: 'Nba',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Team>>? _teamsFuture;
  List<Team> _filteredTeams = [];
  String _selectedCategory = 'All';
  Map<String, String> _countryCodes = {};

  @override
  void initState() {
    super.initState();
    _teamsFuture = getTeams().then((teams) {
      setState(() {
        _filteredTeams = teams;
      });
      return teams;
    });
    _loadCountryCodes(); // Load country codes on initialization
  }

  Future<void> _loadCountryCodes() async {
    final String response = await rootBundle.loadString('assets/alpha2.json');
    final Map<String, dynamic> data = json.decode(response);
    _countryCodes = data.map((key, value) => MapEntry(value, key));
  }

  String _getCountryCode(String countryName) {
    if (countryName == "USA") {
      return _countryCodes["United States"] ?? 'Country not found';
    }
    return _countryCodes[countryName] ?? 'Country not found';
  }

  Future<List<Team>> getTeams() async {
    var teamsRequest = await http.get(
      Uri.https('api.balldontlie.io', '/v1/teams'),
      headers: {
        'Authorization': "102320a4-b139-48f1-83e3-5bc591ce8831",
      },
    );

    var jsonData = jsonDecode(teamsRequest.body)['data'];
    List<Team> teams = [];
    int i = 0;
    for (var team in jsonData) {
      if (i == 30) break;
      teams.add(Team.fromJson(team));
      i++;
    }

    return teams;
  }

  Future<List<Player>> getPlayers(int teamId) async {
    var playersRequest = await http.get(
      Uri.https('api.balldontlie.io', '/v1/players',
          {'team_ids[]': teamId.toString()}),
      headers: {
        'Authorization': "102320a4-b139-48f1-83e3-5bc591ce8831",
      },
    );

    var jsonData = jsonDecode(playersRequest.body)['data'];
    List<Player> players = [];

    for (var player in jsonData) {
      players.add(Player.fromJson(player));
    }

    return players;
  }

  void showPlayersDialog(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Player>>(
          future: getPlayers(team.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: Text('Players'),
                content: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text(
                    'Failed to load players. Please try again later.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else {
              List<Player> players = snapshot.data!;
              return AlertDialog(
                backgroundColor:
                    Colors.white, // 1. Set background color to white
                contentPadding: const EdgeInsets.fromLTRB(
                    16, 8, 16, 0), // 2. Reduce padding
                title: Text(
                  team.name, // 4. Use team name as title
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: players.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: team.conference == 'West'
                                ? const Color(
                                    0xFF395DFF) // West conference color
                                : const Color(
                                    0xFFFB3C83), // East conference color
                          ),
                          child: Center(
                            child: Text(
                              players[index].jerseyNumber.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                        title: Text(
                          '${players[index].firstName} ${players[index].lastName}',
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              players[index].position,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  CountryFlag.fromCountryCode(
                                    _getCountryCode(players[index].country),
                                    height: 15,
                                    width: 25,
                                    shape: const RoundedRectangle(4),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    players[index].country,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  void _filterTeams(String category, List<Team> teams) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredTeams = teams;
      } else {
        _filteredTeams =
            teams.where((team) => team.conference == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 90,
                  child: CustomPaint(
                    painter: WavePainter(),
                    child: Container(
                      height: 90,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 25),
                  alignment: Alignment.centerLeft,
                  height: 80,
                  child: Row(
                    children: [
                      SizedBox(
                          height: 40, child: Image.asset("assets/nba.png")),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'NBA Teams',
                        style: TextStyle(
                          fontFamily: 'Folks',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Team>>(
                future: _teamsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Team>? teams = snapshot.data;

                    // Avoid unnecessary calls to _filterTeams by only calling it when teams is not null and _filteredTeams is empty
                    if (teams != null && _filteredTeams.isEmpty) {
                      _filterTeams(_selectedCategory, teams);
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: ['All', 'West', 'East'].map((category) {
                              return GestureDetector(
                                onTap: () => _filterTeams(category, teams!),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontFamily: 'Folks',
                                      fontSize: _selectedCategory == category
                                          ? 24
                                          : 20,
                                      fontWeight: _selectedCategory == category
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _filteredTeams.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    showPlayersDialog(
                                      context,
                                      _filteredTeams[index],
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          _filteredTeams[index].imageUrl,
                                          width: 50,
                                          height: 50,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: _filteredTeams[index]
                                                            .conference ==
                                                        'West'
                                                    ? const Color(0xFF395DFF)
                                                    : const Color(0xFFFB3C83),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              child: Text(
                                                "${_filteredTeams[index].conference} conference",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              _filteredTeams[index].name,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 3 / 4, size.height * 0.5, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
