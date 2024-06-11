import 'package:flutter/material.dart';

class PlayerCard extends Card {
  static Color? cardColor(groupNo, ThemeData theme) {
    switch (groupNo) {
      case 1:
        return theme.colorScheme.primary;
      case 2:
        return theme.colorScheme.secondary;
      default:
        return theme.cardColor;
    }
  }

  static TextStyle? textStyle(groupNo, ThemeData theme) {
    switch (groupNo) {
      case 1:
      case 2:
        return TextStyle(color: theme.colorScheme.onPrimary);
      default:
        return null;
    }
  }

  PlayerCard(String name,
      {required int no, required ThemeData theme, super.key})
      : super(
            color: cardColor(no, theme),
            child: Center(child: Text(name, style: textStyle(no, theme))));

  PlayerCard.select(String name,
      {required bool selected, required ThemeData theme, super.key})
      : super(
            color: cardColor(selected ? 1 : 0, theme),
            child: Center(
                child: Text(name, style: textStyle(selected ? 1 : 0, theme))));
}
