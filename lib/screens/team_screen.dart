import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/preference_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/dialog/string_dialog.dart';
import 'package:teambalancer/screens/player_screen.dart';
import 'package:teambalancer/widgets/player_tile.dart';
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
  Widget getTagsWidget(TeamData team, isAdmin) {
    if (team.tags.isEmpty && !isAdmin) {
      return const SizedBox();
    }

    List<Widget> tags = [];
    for (var tag in team.tags) {
      tags.add(InkWell(
        child: TagText.tag(tag, theme: Theme.of(context)),
        onTap: () => tagDialog(tag),
      ));
    }
    if (isAdmin) {
      tags.add(InkWell(
        child: TagText.tag(
          "+ ${context.l10n.newTag}",
          theme: Theme.of(context),
        ),
        onTap: () => tagDialog(null),
      ));
    }

    return ExpansionTile(
      title: Text(context.l10n.tags),
      initiallyExpanded: false,
      children: [Row(children: tags)],
    );
  }

  Widget getSkillWeightsWidget(TeamData team, isAdmin) {
    List<Widget> skillSlider = [];
    for (var skill in Skill.values) {
      if (skill == Skill.technical ||
          skill == Skill.physical ||
          skill == Skill.form) {
        skillSlider.add(Row(
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
    return ExpansionTile(
      title: Text(context.l10n.skillWeights),
      initiallyExpanded: true,
      children: skillSlider,
    );
  }

  Widget getPlayersTitle(sortingKind) {
    return ListTile(
        title: Text(context.l10n.players),
        trailing: IconButton(
          icon: const Icon(Icons.sort_by_alpha),
          onPressed: () {
            final nextSortingKind = PlayerSorting
                .values[(sortingKind.index + 1) % PlayerSorting.values.length];
            widget.data.preferenceData.teams[widget.teamKey.key]!
                .playerSorting = nextSortingKind;
            setState(() {});
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.data.isAdmin(widget.teamKey);
    final team = widget.data.get().team(widget.teamKey);
    final players = team.players;
    final sortingKind =
        widget.data.preferenceData.teams[widget.teamKey.key]!.playerSorting;
    developer.log('build team screen ${players.length} players',
        name: 'teambalancer data');

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

    final topWidgets = [
      getTagsWidget(team, isAdmin),
      getSkillWeightsWidget(team, isAdmin),
      getPlayersTitle(sortingKind),
    ];

    var listView = ListView.builder(
      itemCount: players.length + topWidgets.length,
      itemBuilder: (context, index) {
        if (index < topWidgets.length) {
          return topWidgets[index];
        }

        final sorted = players.keys.toList()..sort((a, b) => sorting(a, b));
        final name = sorted[index - topWidgets.length];
        final player = players[name]!;

        return Card(
          child: PlayerTile(
            name: name,
            skills: player.skills,
            sport: Sport.values[team.sport],
            tags: player.tags,
            history: players[name]!.history,
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
            onLongPress: isAdmin ? () => playerDialog(name) : null,
          ),
        );
      },
    );

    return ScaffoldWithHidingFab(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: listView,
      floatingActionButton: (isAdmin)
          ? FloatingActionButton(
              onPressed: () => playerDialog(null),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  void playerDialog(String? defaultText) async {
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

  void tagDialog(String? defaultText) async {
    final team = widget.data.get().team(widget.teamKey);
    String? input;
    if (defaultText != null) {
      input = await stringDialog(
        context,
        title: context.l10n.tag,
        defaultText: defaultText,
        deleteFunction: () {
          team.removeTag(defaultText);
          setState(() {});
        },
      );
    } else {
      input = await stringDialog(context,
          title: context.l10n.newTag, hintText: context.l10n.tag);
    }
    if (input == null) return; // empty name not allowed
    if (defaultText != null) {
      if (team.tags.contains(input)) {
        return;
      }
      await team.renameTag(defaultText, input);
    } else {
      await team.addTag(input);
    }
    setState(() {});
  }
}
