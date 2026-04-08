import 'dart:convert';

import 'package:calc/calc.dart';
import 'package:flutter/material.dart';
import 'package:radar_chart_plus/radar_chart_plus.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/shuffle.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/screens/game_screen.dart';
import 'package:teambalancer/widgets/player_card.dart';
import 'package:teambalancer/widgets/tag_text.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen(
      {required this.groups,
      required this.teamKey,
      required this.data,
      required this.parameter,
      super.key});

  final List<GroupData> groups;
  final TeamKey teamKey;
  final Data data;
  final ShuffleParameter parameter;
  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Widget playerInfo(String name) {
    var player = widget.data.get().team(widget.teamKey).players[name]!;
    List<Widget> list = [
      getTacticsIcon(player.skills[Skill.tactical] ?? 1,
          color: Theme.of(context).iconTheme.color),
      Text(name)
    ];
    for (var e in player.tags) {
      list.add(TagText.tag(e, theme: Theme.of(context)));
    }
    return Row(children: list);
  }

  @override
  Widget build(BuildContext context) {
    var gridView = GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.groups.length,
      itemBuilder: (context, index) {
        final group = widget.groups[index];
        final sorted = group.members.keys.sorted();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: TextStyle(
                    color: PlayerCard.cardColor(index, Theme.of(context)),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children:
                        sorted.map((element) => playerInfo(element)).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    var radarChart = RadarChartPlus(
      labels: [
        context.l10n.tactical,
        context.l10n.physical,
        context.l10n.technical,
        context.l10n.form
      ],
      dotTapEnabled: false,
      dataSets: widget.groups.map((group) {
        final index = widget.groups.indexOf(group);
        final color = PlayerCard.cardColor(index, Theme.of(context));
        return RadarDataSet(
          data: [
            group.skill(Skill.tactical, []),
            group.skill(Skill.physical, []),
            group.skill(Skill.technical, []),
            group.skill(Skill.form, []),
          ],
          fillColor: color.withValues(alpha: 0.3),
          borderColor: color,
        );
      }).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data.get().team(widget.teamKey).name),
        actions: [
          IconButton(icon: const Icon(Icons.shuffle), onPressed: shuffleGroups),
          IconButton(icon: const Icon(Icons.save), onPressed: saveGroups)
        ],
      ),
      body: Column(
          children: [Expanded(child: gridView), Expanded(child: radarChart)]),
    );
  }

  void shuffleGroups() {
    final groups = ShuffleWeighted(parameter: widget.parameter).shuffle();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GroupScreen(
          teamKey: widget.teamKey,
          data: widget.data,
          groups: groups,
          parameter: widget.parameter,
        ),
      ),
    );
  }

  void saveGroups() async {
    Map<String, dynamic> body = {
      'teamKey': widget.teamKey.key,
      'groupData': widget.groups
    };
    final response = await Backend.addGame(jsonEncode(body));

    final teamData = widget.data.get().team(widget.teamKey);
    final isAdmin = widget.data.isAdmin(widget.teamKey);

    // Create new game from response instead of re-fetching all games
    final newGame = Game(
      date: DateTime.parse(response['date']),
      groups: widget.groups,
      historyId: response['historyId'],
    );
    teamData.games.add(newGame);
    teamData.refreshGames();

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
