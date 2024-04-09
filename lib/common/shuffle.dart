import 'package:teambalancer/common/constants.dart';
import 'package:calc/calc.dart';
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
}

class Group {
  final String name;
  final int capacity;
  List<String> members = [];
  Map<Skill, int> skills = {};

  Group(this.name, this.capacity)
      : skills = {for (var key in Skill.values) key: 0};

  bool isComplete() {
    return members.length >= capacity;
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

    developer.log(
        'Possible Groups: ${possibleGroups(parameter.players.length, parameter.noOfGroups)}',
        name: 'shuffle');
  }

  static int possibleGroups(int players, int noOfGroups) {
    int groupSize(int groupNo) {
      var p = players;
      for (var i = 0; i < groupNo; i++) {
        p -= groupSize(i);
      }
      return (p ~/ (noOfGroups - groupNo));
    }

    int factor = 1;
    int freePlayers = players;
    int equalSizedGroups = 1;
    for (var i = 0; i < noOfGroups; i++) {
      final currentGroupSize = groupSize(i);
      factor *= binomialCoefficient(freePlayers, currentGroupSize);
      freePlayers -= currentGroupSize;
      if (i > 0 && groupSize(i - i) == currentGroupSize) {
        equalSizedGroups++;
      }
    }
    return factor ~/ factorial(equalSizedGroups);
  }

  // https://en.wikipedia.org/wiki/Alias_method  ??
  // https://de.wikipedia.org/wiki/MCMC-Verfahren

  List<Group> shuffle() {
    int draws = 4;

    List<Group> bestGroups = [];

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
  final List<Group> _groups;

  ShuffleBase({required this.parameter})
      : _groups = List<Group>.generate(
            parameter.noOfGroups,
            (i) => Group("Group ${i + 1}",
                parameter.players.length ~/ parameter.noOfGroups),
            growable: false);

  void _addToGroup(String name, int groupNo) {
    var group = _groups[groupNo];
    group.members.add(name);

    for (var skill in Skill.values) {
      group.skills[skill] =
          group.skills[skill]! + parameter.weightedSkill(name, skill);
    }
  }

  List<Group> shuffle() {
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
