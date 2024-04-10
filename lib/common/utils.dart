import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

Tactics getTactics(int value) {
  if (value < Constants.defaultSkill) {
    return Tactics.defense;
  } else if (value == Constants.defaultSkill) {
    return Tactics.neutral;
  } else {
    return Tactics.offense;
  }
}

String getAsset(var type) {
  switch (type) {
    case Sport.football:
      return "assets/sports/football.svg";
    case Sport.floorball:
      return "assets/sports/floorball.svg";
    case Sport.basketball:
      return "assets/sports/basketball.svg";
    case Tactics.defense:
      return "assets/skills/defense.svg";
    case Tactics.neutral:
      return "assets/skills/neutral.svg";
    case Tactics.offense:
      return "assets/skills/offense.svg";
    case Skill.physical:
      return "assets/skills/physical.svg";
  }
  return "";
}

Widget getSportIcon(Sport sport, {Color? color}) {
  ColorFilter? colorFilter =
      color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null;

  return SvgPicture.asset(getAsset(sport), width: 24, colorFilter: colorFilter);
}

Widget getSkillIcon(Skill skill, int value, Sport sport) {
  switch (skill) {
    case Skill.physical:
      return SvgPicture.asset(getAsset(Skill.physical), width: 24);
    case Skill.technical:
      return getSportIcon(sport);
    case Skill.tactical:
      return getTacticsIcon(value);
  }
}

Widget getTacticsIcon(int value, {Color? color}) {
  ColorFilter? colorFilter =
      color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null;
  return SvgPicture.asset(getAsset(getTactics(value)),
      width: 24, colorFilter: colorFilter);
}
