import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/player_data.dart';
import 'package:teambalancer/data/preference_data.dart';

int sorting(PlayerSorting sortingKind, Map<String, PlayerData> players,
    String a, String b) {
  Function fun;
  switch (sortingKind) {
    case PlayerSorting.name:
      return a.compareTo(b);
    case PlayerSorting.form:
      fun = (String s) => players[s]!.skills[Skill.form]!;
    case PlayerSorting.games:
      fun = (String s) =>
          players[s]!.history.where((gr) => gr != GameResult.miss).length;
    case PlayerSorting.won:
      fun = (String s) =>
          players[s]!.history.where((gr) => gr == GameResult.won).length;
    case PlayerSorting.lost:
      fun = (String s) =>
          players[s]!.history.where((gr) => gr == GameResult.lost).length;
    case PlayerSorting.winPercentage:
      fun = (String s) {
        var w = players[s]!.history.where((gr) => gr == GameResult.won).length;
        var l = players[s]!.history.where((gr) => gr == GameResult.lost).length;
        return w / (w + l);
      };
  }

  return fun(b).compareTo(fun(a));
}
