import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/screens/game_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen(
      {required this.groups,
      required this.teamKey,
      required this.data,
      super.key});

  final List<GroupData> groups;
  final TeamKey teamKey;
  final Data data;
  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Widget skill(String name) {
    return getTacticsIcon(
        widget.data
                .get()
                .team(widget.teamKey)
                .players[name]!
                .skills[Skill.tactical] ??
            1,
        color: Theme.of(context).iconTheme.color);
  }

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
      itemCount: widget.groups.length,
      itemBuilder: (context, index) {
        final group = widget.groups[index];

        var weights = <Widget>[];
        group.skills.forEach((key, value) {
          weights.add(Text(
            "$key : ${value.toStringAsFixed(1)}",
            textScaler: const TextScaler.linear(0.7),
          ));
        });

        return Card(
          child: ListTile(
            title: Row(children: [Text(group.name)]),
            subtitle: Column(
                children: group.members.keys
                    .map((element) =>
                        Row(children: [skill(element), Text(element)]))
                    .toList()),
            trailing: Column(children: weights),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data.get().team(widget.teamKey).name),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: saveGroups)
        ],
      ),
      body: listView,
    );
  }

  void saveGroups() async {
    Map<String, dynamic> body = {
      'teamKey': widget.teamKey.key,
      'groups': widget.groups
    };
    await Backend.addGame(jsonEncode(body));

    final games = await Backend.getHistory(widget.teamKey.key);
    final teamData = widget.data.get().team(widget.teamKey);
    teamData.loadGames(games);
    final isAdmin = widget.data.isAdmin(widget.teamKey);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => GameScreen(
                    game: teamData.games.last,
                    teamData: teamData,
                    isAdmin: isAdmin,
                  )),
          // remove all routes except first
          (Route<dynamic> route) => route.settings.name == "/");
    }
  }
}
