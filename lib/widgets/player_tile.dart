import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/widgets/player_history.dart';
import 'package:teambalancer/widgets/player_skills.dart';
import 'package:teambalancer/widgets/tag_text.dart';

class PlayerTile extends StatelessWidget {
  final String name;
  final List<GameResult> history;
  final Map<Skill, double> skills;
  final List<String> tags;
  final Sport sport;

  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  const PlayerTile(
      {super.key,
      required this.name,
      required this.history,
      required this.skills,
      required this.sport,
      this.tags = const <String>[],
      this.onTap,
      this.onLongPress});

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    for (var e in tags) {
      list.add(TagText.tag(e, theme: Theme.of(context)));
    }
    list.add(PlayerSkills(skills, sport: sport.index));

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(children: [
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(name), PlayerHistory(history)]),
        ),
        Row(
          children: list,
        ),
      ]),
    );
  }
}
