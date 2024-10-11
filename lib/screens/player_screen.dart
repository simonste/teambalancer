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
    final team = widget.data.get().team(widget.teamKey);
    final player = team.players[widget.playerName]!;
    final skills = player.skills;

    final adjustableSkills = [Skill.tactical, Skill.physical, Skill.technical];

    var listView = ListView.builder(
      itemCount: adjustableSkills.length,
      itemBuilder: (context, index) {
        final skillType = adjustableSkills[index];
        final skill = skills[skillType]!;

        if (skillType == Skill.tactical) {
          var groupButtons = List<Widget>.generate(3, (i) {
            final int no = Constants.defaultSkill.toInt() - 1 + i;
            final selected = skill == no;
            return Expanded(
                child: (IconButton(
              style: selected
                  ? ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary))
                  : null,
              onPressed: () => setState(() {
                player.setSkill(skillType, no, widget.teamKey);
              }),
              icon: getTacticsIcon(no,
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).iconTheme.color),
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
              child: TagText.tag(
                tag,
                active: player.tags.contains(tag),
                theme: Theme.of(context),
              ),
              onTap: () {
                player.toggleTag(tag, widget.teamKey);
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
