import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/widgets/tag_text.dart';

class PlayerSkills extends StatelessWidget {
  final Sport sport;
  final Map<Skill, double> skills;
  final List<String> tags = [];
  final bool withIcon;

  PlayerSkills(
    this.skills, {
    super.key,
    required this.sport,
  }) : withIcon = true;

  PlayerSkills.withoutIcon(
    this.skills, {
    super.key,
  })  : withIcon = false,
        sport = Sport.football;

  @override
  Widget build(BuildContext context) {
    List<Widget> factors = [];
    for (var skillType in Skill.values) {
      final skillValue = skills[skillType]!;
      final icon = getSkillIcon(skillType, skillValue, sport,
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

      factors.add(Column(
        children: withIcon
            ? [
                ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 24),
                    child: SizedBox(height: 24, child: icon)),
                Text(skillText())
              ]
            : [
                ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 24),
                    child: SizedBox(child: Text(skillText())))
              ],
      ));
    }
    for (var tag in tags) {
      factors.add(TagText.tag(tag, theme: Theme.of(context)));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: factors,
    );
  }
}
