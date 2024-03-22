import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';

void navigateTo(BuildContext context, Widget widget, {Function? callback}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
  ).then((value) {
    if (callback != null) {
      callback();
    }
  });
}

Icon getSportIcon(Sport sport, {Color? color}) {
  switch (sport) {
    case Sport.football:
      return Icon(Icons.sports_soccer, color: color);
    case Sport.floorball:
      return Icon(Icons.sports_hockey, color: color);
    case Sport.basketball:
      return Icon(Icons.sports_basketball, color: color);
  }
}

Icon getSkillIcon(Skill skill, int value, Sport sport) {
  switch (skill) {
    case Skill.physical:
      return const Icon(Icons.directions_run_rounded);
    case Skill.technical:
      return getSportIcon(sport);
    case Skill.tactical:
      return getTacticsIcon(value);
  }
}

Icon getTacticsIcon(int value, {Color? color}) {
  if (value < Constants.defaultSkill) {
    return Icon(Icons.shield, color: color);
  } else if (value == Constants.defaultSkill) {
    return Icon(Icons.circle_outlined, color: color);
  } else {
    return Icon(Icons.arrow_outward, color: color);
  }
}
