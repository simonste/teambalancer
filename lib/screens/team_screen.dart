import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/player_data.dart';
import 'package:teambalancer/dialog/string_dialog.dart';
import 'package:teambalancer/screens/player_screen.dart';
import 'package:teambalancer/widgets/tag_text.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({required this.teamName, required this.data, super.key});

  final String teamName;
  final Data data;
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  Widget build(BuildContext context) {
    final team = widget.data.get().teams[widget.teamName]!;
    final players = team.players;

    List<Widget> tags = [];
    for (var tag in team.tags) {
      tags.add(TagText.tag(tag));
    }

    List<Widget> skills = [];
    for (var skill in Skill.values) {
      if (skill != Skill.tactical) {
        skills.add(Row(
          children: [
            getSkillIcon(skill, 0, team.sport),
            Expanded(
                child: Slider(
              min: Constants.weightMin,
              max: Constants.weightMax,
              divisions: Constants.weightDivisions,
              value: (team.weights[skill]!).toDouble(),
              onChanged: (double value) {
                setState(() {
                  team.weights[skill] = value.toInt();
                  widget.data.save();
                });
              },
            )),
            Text((team.weights[skill]!).toStringAsFixed(0))
          ],
        ));
      }
    }

    var listView = ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final sorted = players.keys.toList()..sort();
        final name = sorted[index];
        final player = players[name]!;

        List<Widget> factors = [];
        for (var skillType in Skill.values) {
          final skill = player.skills[skillType]!;
          factors.add(getSkillIcon(skillType, skill, team.sport));
          if (skillType != Skill.tactical) {
            factors.add(Text("$skill"));
          }
        }
        for (var tag in players[name]!.tags) {
          factors.add(TagText.tag(tag));
        }

        return Card(
          child: ListTile(
            title: Text(name),
            subtitle: Row(children: factors),
            onTap: () {
              navigateTo(
                  context,
                  PlayerScreen(
                    playerName: name,
                    teamName: widget.teamName,
                    data: widget.data,
                  ), callback: () {
                setState(() {});
              });
            },
            onLongPress: () => dialog(name),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.teamName)),
      body: Column(
        children: [
          Wrap(children: [
            Row(children: tags),
            Column(children: skills),
          ]),
          Expanded(child: listView)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => dialog(null),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void dialog(String? defaultText) async {
    final team = widget.data.get().teams[widget.teamName]!;
    String? input;
    if (defaultText != null) {
      input = await stringDialog(
        context,
        title: context.l10n.playerName,
        defaultText: defaultText,
        deleteFunction: () {
          team.players.remove(defaultText);
          widget.data.save();
          setState(() {});
        },
      );
    } else {
      input = await stringDialog(context,
          title: context.l10n.createPlayer, hintText: context.l10n.playerName);
    }
    if (input == null) return; // empty name not allowed
    if (defaultText != null) {
      if (team.players.containsKey(input)) {
        return;
      }
      team.players[input] = team.players[defaultText]!;
      team.players.remove(defaultText);
    } else {
      team.players[input] = PlayerData.init();
    }
    widget.data.save();
    setState(() {});
  }
}
