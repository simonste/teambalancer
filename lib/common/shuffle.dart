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

class Shuffle {
  final ShuffleParameter parameter;
  final List<Group> _groups;
  Map<Skill, int> totalSkills = {};
  int totalSkill = 0;

  Shuffle({required this.parameter})
      : _groups = List<Group>.generate(
            parameter.noOfGroups,
            (i) => Group("Group ${i + 1}",
                parameter.players.length ~/ parameter.noOfGroups),
            growable: false) {
    for (var skill in Skill.values) {
      totalSkills[skill] = parameter.totalSkill(skill);
      totalSkill += totalSkills[skill]!;
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

  void _addToGroup(String name, int groupNo) {
    var group = _groups[groupNo];
    group.members.add(name);
    for (var skill in Skill.values) {
      group.skills[skill] =
          group.skills[skill]! + parameter.weightedSkill(name, skill);
    }
  }

  // https://en.wikipedia.org/wiki/Alias_method  ??
  // https://de.wikipedia.org/wiki/MCMC-Verfahren

  List<Group> shuffle() {
    Random random = Random();
    final playerNames = parameter.players.keys.toList()..shuffle(random);

    for (var p = 0; p < parameter.players.length; p++) {
      final playerName = playerNames[p];
      if (!_groups[0].isComplete()) {
        // for (var skill in Skill.values) {
        //   final randomNumber = random.nextDouble();
        //   if (randomNumber * totalSkills[skill]! <
        //       parameter.weightedSkill(playerName, skill)) {
        _addToGroup(playerName, 0);
        //     break;
        //   }
        // }
      } else {
        _addToGroup(playerName, 1);
      }
    }
    return _groups;
  }
}
