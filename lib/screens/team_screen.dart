import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/preference_data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/dialog/string_dialog.dart';
import 'package:teambalancer/screens/player_screen.dart';
import 'package:teambalancer/widgets/scaffold_with_hiding_fab.dart';
import 'package:teambalancer/widgets/tag_text.dart';
import 'dart:developer' as developer;

class TeamScreen extends StatefulWidget {
  const TeamScreen({required this.teamKey, required this.data, super.key});

  final TeamKey teamKey;
  final Data data;
  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  void addSkillWeightsWidget(skills, team, isAdmin) {
    for (var skill in Skill.values) {
      if (skill == Skill.technical ||
          skill == Skill.physical ||
          skill == Skill.form) {
        skills.add(Row(
          children: [
            getSkillIcon(skill, 3.8, Sport.values[team.sport],
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
  }

  Widget subtitle(List<GameResult> history) {
    var row = <Widget>[];

    getColor(gameResult) {
      switch (gameResult) {
        case GameResult.won:
          return Colors.green;
        case GameResult.lost:
          return Colors.red;
        case GameResult.draw:
          return Colors.yellow;
        case GameResult.miss:
        case GameResult.noScore:
          return Colors.black;
      }
    }

    for (int i = 0; i < history.length; i++) {
      row.add(Container(
        width: 10,
        height: 3,
        decoration: BoxDecoration(
            color: getColor(history[i]),
            border:
                const Border(right: BorderSide(color: Colors.white, width: 1))),
      ));
    }
    return Row(children: row);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.data.isAdmin(widget.teamKey);
    final team = widget.data.get().team(widget.teamKey);
    final players = team.players;
    developer.log('build team screen ${players.length} players',
        name: 'teambalancer data');

    List<Widget> tags = [];
    for (var tag in team.tags) {
      tags.add(TagText.tag(tag));
    }

    List<Widget> rows = [Text(context.l10n.skillWeights)];
    addSkillWeightsWidget(rows, team, isAdmin);
    rows.add(Text(context.l10n.players));

    var sortingKind =
        widget.data.preferenceData.teams[widget.teamKey.key]!.playerSorting;

    int sorting(String a, String b) {
      switch (sortingKind) {
        case PlayerSorting.name:
          return a.compareTo(b);
        case PlayerSorting.form:
          return players[b]!
              .skills[Skill.form]!
              .compareTo(players[a]!.skills[Skill.form]!);
      }
    }

    var listView = ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final sorted = players.keys.toList()..sort((a, b) => sorting(a, b));
        final name = sorted[index];
        final player = players[name]!;

        List<Widget> factors = [];
        for (var skillType in Skill.values) {
          final skillValue = player.skills[skillType]!;
          final icon = getSkillIcon(
              skillType, skillValue, Sport.values[team.sport],
              color: Theme.of(context).iconTheme.color);

          skillText() {
            switch (skillType) {
              case Skill.tactical:
                return "";
              case Skill.form:
                return "${(skillValue * 10).roundToDouble() / 10}";
              case Skill.physical:
              case Skill.technical:
                return "${skillValue.toInt()}";
            }
          }

          factors.add(Column(children: [
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 24),
                child: SizedBox(height: 24, child: icon)),
            Text(skillText())
          ]));
        }
        for (var tag in players[name]!.tags) {
          factors.add(TagText.tag(tag));
        }

        return Card(
          child: ListTile(
            title: Text(name),
            trailing: SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: factors,
                )),
            subtitle: subtitle(players[name]!.history),
            onTap: isAdmin
                ? () {
                    navigateTo(
                        context,
                        PlayerScreen(
                          playerName: name,
                          teamKey: widget.teamKey,
                          data: widget.data,
                        ), callback: (value) {
                      setState(() {});
                    });
                  }
                : null,
            onLongPress: isAdmin ? () => dialog(name) : null,
          ),
        );
      },
    );

    return ScaffoldWithHidingFab(
      appBar: AppBar(
        title: Text(team.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: () {
              final nextSortingKind = PlayerSorting.values[
                  (sortingKind.index + 1) % PlayerSorting.values.length];
              widget.data.preferenceData.teams[widget.teamKey.key]!
                  .playerSorting = nextSortingKind;
              setState(() {});
            },
          )
        ],
      ),
      body: Column(
        children: [
          Wrap(children: [
            Row(children: tags),
            Column(children: rows),
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
