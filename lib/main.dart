import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nba/model/player.dart';
import 'package:nba/model/team.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Team>>? _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = getTeams();
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

  void showPlayersDialog(int teamId) async {
    List<Player> players = await getPlayers(teamId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Players'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: players.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    '${players[index].firstName} ${players[index].lastName}',
                  ),
                  subtitle: Text(players[index].position),
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
                      showPlayersDialog(teams[index].id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Image.network(
                              teams![index].imageUrl,
                              width: 50,
                              height: 50,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons
                                    .error); // Error icon if image fails to load
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(teams[index].abbreviation),
                                Text(teams[index].name),
                              ],
                            )
                          ],
                        ),
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
