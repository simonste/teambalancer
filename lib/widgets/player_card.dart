import 'package:flutter/material.dart';
import 'package:teambalancer/data/player_data.dart';
import 'package:teambalancer/widgets/player_skills.dart';

class PlayerCard extends Card {
  static Color cardColor(int groupNo, ThemeData theme) {
    switch (groupNo) {
      case -1:
        return theme.cardColor;
      case 0:
        return theme.colorScheme.primary;
      case 1:
        return theme.colorScheme.secondary;
      case 2:
        return Colors.deepPurple;
      case 3:
        return Colors.amber;
      default:
        return theme.cardColor;
    }
  }

  static TextStyle? textStyle(int groupNo, ThemeData theme) {
    switch (groupNo) {
      case -1:
        return null;
      case 0:
        return TextStyle(color: theme.colorScheme.onPrimary);
      case 1:
        return TextStyle(color: theme.colorScheme.onSecondary);
      case 2:
        return const TextStyle(color: Colors.white);
      case 3:
        return const TextStyle(color: Colors.black);
      default:
        return null;
    }
  }

  PlayerCard(String name,
      {required PlayerData data,
      required int no,
      required ThemeData theme,
      super.key})
      : super(
            color: cardColor(no, theme),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(name, style: textStyle(no, theme)),
                  PlayerSkills.withoutIcon(data.skills)
                ],
              ),
            ));

  PlayerCard.select(String name,
      {required bool selected, required ThemeData theme, super.key})
      : super(
            color: cardColor(selected ? 0 : -1, theme),
            child: Center(
                child: Text(name, style: textStyle(selected ? 0 : -1, theme))));
}
