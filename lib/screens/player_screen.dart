import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/widgets/tag_text.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen(
      {required this.teamKey,
      required this.playerName,
      required this.data,
      super.key});

  final TeamKey teamKey;
  final String playerName;
  final Data data;
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final team = widget.data.get().teams[widget.teamKey.key]!;
    final player = team.players[widget.playerName]!;
    final skills = player.skills;

    var listView = ListView.builder(
      itemCount: Skill.values.length,
      itemBuilder: (context, index) {
        final skillType = Skill.values[index];
        final skill = skills[skillType]!;

        if (skillType == Skill.tactical) {
          var groupButtons = List<Widget>.generate(3, (i) {
            final no = Constants.defaultSkill - 1 + i;
            final selected = skill == no;
            return Expanded(
                child: (IconButton(
              style: selected
                  ? ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary))
                  : null,
              onPressed: () => setState(() {
                player.setSkill(skillType, no, widget.teamKey);
              }),
              icon: getTacticsIcon(no,
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : null),
            )));
          });

          return Card(child: Row(children: groupButtons));
        }

        return Card(
          child: Column(
            children: [
              Text(skillType.name),
              Row(
                children: [
                  Expanded(
                      child: Slider(
                    key: Key(skillType.name),
                    min: Constants.skillMin,
                    max: Constants.skillMax,
                    divisions: Constants.skillDivisions,
                    value: skill.toDouble(),
                    onChanged: (double value) {
                      setState(() {
                        player.setSkill(
                            skillType, value.toInt(), widget.teamKey);
                      });
                    },
                  )),
                  Text(skill.toStringAsFixed(0))
                ],
              )
            ],
          ),
        );
      },
    );

    var tags = team.tags
        .map((tag) => InkWell(
              child: TagText.tag(tag, active: player.tags.contains(tag)),
              onTap: () {
                player.toggleTag(tag);
                setState(() {});
              },
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.playerName)),
      body: Column(
        children: [
          Row(children: tags),
          Expanded(child: listView),
        ],
      ),
    );
  }
}
