import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/dialog/string_dialog.dart';
import 'package:teambalancer/screens/player_screen.dart';
import 'package:teambalancer/widgets/tag_text.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({required this.teamKey, required this.data, super.key});

  final TeamKey teamKey;
  final Data data;
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.data.isAdmin(widget.teamKey);
    final team = widget.data.get().team(widget.teamKey);
    final players = team.players;

    List<Widget> tags = [];
    for (var tag in team.tags) {
      tags.add(TagText.tag(tag));
    }

    List<Widget> skills = [Text(context.l10n.skillWeights)];
    for (var skill in Skill.values) {
      if (skill != Skill.tactical) {
        skills.add(Row(
          children: [
            getSkillIcon(skill, 0, Sport.values[team.sport],
                color: Theme.of(context).iconTheme.color),
            Expanded(
                child: Slider(
              min: Constants.weightMin,
              max: Constants.weightMax,
              divisions: Constants.weightDivisions,
              value: (team.weights[skill]!).toDouble(),
              onChanged: isAdmin
                  ? (double value) {
                      setState(() {
                        team.setWeight(skill, value.toInt());
                      });
                    }
                  : null,
            )),
            Text((team.weights[skill]!).toStringAsFixed(0))
          ],
        ));
      }
    }
    skills.add(Text(context.l10n.players));

    var listView = ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final sorted = players.keys.toList()..sort();
        final name = sorted[index];
        final player = players[name]!;

        List<Widget> factors = [];
        for (var skillType in Skill.values) {
          final skill = player.skills[skillType]!;
          factors.add(getSkillIcon(skillType, skill, Sport.values[team.sport],
              color: Theme.of(context).iconTheme.color));
          if (skillType != Skill.tactical) {
            factors.add(Text("$skill"));
          }
        }
        for (var tag in players[name]!.tags) {
          factors.add(TagText.tag(tag));
        }

        if (isAdmin) {
          return Card(
            child: ListTile(
              title: Text(name),
              trailing: SizedBox(width: 100, child: Row(children: factors)),
              onTap: () {
                navigateTo(
                    context,
                    PlayerScreen(
                      playerName: name,
                      teamKey: widget.teamKey,
                      data: widget.data,
                    ), callback: (value) {
                  setState(() {});
                });
              },
              onLongPress: () => dialog(name),
            ),
          );
        } else {
          return Card(
            child: ListTile(
              title: Text(name),
              trailing: SizedBox(width: 100, child: Row(children: factors)),
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
      body: Column(
        children: [
          Wrap(children: [
            Row(children: tags),
            Column(children: skills),
          ]),
          Expanded(child: listView)
        ],
      ),
      floatingActionButton: (isAdmin)
          ? FloatingActionButton(
              onPressed: () => dialog(null),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  void dialog(String? defaultText) async {
    final team = widget.data.get().team(widget.teamKey);
    String? input;
    if (defaultText != null) {
      input = await stringDialog(
        context,
        title: context.l10n.playerName,
        defaultText: defaultText,
        deleteFunction: () {
          team.removePlayer(defaultText);
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
      team.renamePlayer(defaultText, input);
    } else {
      await team.addPlayer(input);
    }
    setState(() {});
  }
}
