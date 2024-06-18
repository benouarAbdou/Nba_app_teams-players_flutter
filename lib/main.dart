import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:country_flags/country_flags.dart'; // Assuming you are using this package for flags
import 'package:nba/model/player.dart';
import 'package:nba/model/team.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,

        scaffoldBackgroundColor:
            const Color(0xFFEDECF1), // Set the background color here
      ),
      title: 'Flutter Demo',
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

  Map<String, String> _countryCodes = {};

  @override
  void initState() {
    super.initState();
    _teamsFuture = getTeams();
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

    for (var team in jsonData) {
      teams.add(Team.fromJson(team));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Team>>(
          future: _teamsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Team>? teams = snapshot.data;

              return ListView.builder(
                itemCount: 30,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      showPlayersDialog(
                        context,
                        teams[index],
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
                            teams![index].imageUrl,
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: teams[index].conference == 'West'
                                      ? const Color(0xFF395DFF)
                                      : const Color(0xFFFB3C83),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: Text(
                                  "${teams[index].conference} conference",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                teams[index].name,
                                style: const TextStyle(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
