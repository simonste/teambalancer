import 'package:teambalancer/common/constants.dart';
import 'package:calc/calc.dart';
import 'package:teambalancer/data/group_data.dart';
import 'dart:developer' as developer;
import 'package:teambalancer/data/player_data.dart';

class ShuffleParameter {
  bool separateTagged = true;
  int noOfGroups = 2;

  Map<Skill, int> weights = {};
  Map<String, PlayerData> players = {};

  int weightedSkill(String name, Skill skill) =>
      players[name]!.skills[skill]! * weights[skill]!;

  int totalSkill(Skill skill) => players.keys
      .toList()
      .fold(0, (prev, name) => prev + weightedSkill(name, skill));

  int groupSize({required int groupNo}) {
    var p = players.length;
    for (var i = 0; i < groupNo; i++) {
      p -= groupSize(groupNo: i);
    }
    return (p / (noOfGroups - groupNo)).ceil();
  }

  int possibleGroups() {
    int factor = 1;
    int freePlayers = players.length;
    int equalSizedGroups = 1;
    for (var i = 0; i < noOfGroups; i++) {
      final currentGroupSize = groupSize(groupNo: i);
      factor *= binomialCoefficient(freePlayers, currentGroupSize);
      freePlayers -= currentGroupSize;
      if (i > 0 && groupSize(groupNo: i - 1) == currentGroupSize) {
        equalSizedGroups++;
      }
    }
    return factor ~/ factorial(equalSizedGroups);
  }
}

class ShuffleWeighted {
  final ShuffleParameter parameter;
  Map<Skill, double> avgSkills = {};
  double bestError = double.maxFinite;

  ShuffleWeighted({required this.parameter}) {
    for (var skill in Skill.values) {
      avgSkills[skill] = parameter.totalSkill(skill) / parameter.noOfGroups;
    }

    developer.log('Possible Groups: ${parameter.possibleGroups()}',
        name: 'shuffle');
  }

  // https://en.wikipedia.org/wiki/Alias_method  ??
  // https://de.wikipedia.org/wiki/MCMC-Verfahren

  List<GroupData> shuffle() {
    int draws = max(pow(parameter.possibleGroups(), 0.8).floor(), 5);

    List<GroupData> bestGroups = [];

    for (int i = 0; i < draws; i++) {
      final groups = ShuffleBase(parameter: parameter).shuffle();
      double error = 0;
      for (var group in groups) {
        for (var skill in Skill.values) {
          error += (group.skills[skill]! - avgSkills[skill]!).abs();
        }
      }

      if (error < bestError) {
        developer.log('Groups at Iter $i are better: $error < $bestError',
            name: 'shuffle');
        bestGroups = groups;
        bestError = error;
      }
    }
    return bestGroups;
  }
}

class ShuffleBase {
  final ShuffleParameter parameter;
  final List<GroupData> _groups;

  ShuffleBase({required this.parameter})
      : _groups = List<GroupData>.generate(parameter.noOfGroups,
            (i) => GroupData("Group ${i + 1}", parameter.groupSize(groupNo: i)),
            growable: false);

  void _addToGroup(String playerName, int groupNo) {
    var group = _groups[groupNo];
    group.members[playerName] = parameter.players[playerName]!.playerId;

    for (var skill in Skill.values) {
      group.skills[skill] =
          group.skills[skill]! + parameter.weightedSkill(playerName, skill);
    }
  }

  List<GroupData> shuffle() {
    Random random = Random();
    final playerNames = parameter.players.keys.toList()..shuffle(random);

    for (var p = 0; p < playerNames.length; p++) {
      final playerName = playerNames[p];
      for (var g = 0; g < _groups.length; g++) {
        if (!_groups[g].isComplete()) {
          _addToGroup(playerName, g);
          break;
        }
      }
    }
    return _groups;
  }
}
