import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/screens/shuffle_screen.dart';
import 'package:calc/calc.dart';
import 'dart:developer' as developer;

class Group {
  final String name;
  List<String> members = [];
  Map<Skill, int> skills = {};

  Group(this.name);
}

class Shuffle {
  final ShuffleParameter parameter;
  final TeamData team;
  late List<Group> _groups;
  Map<Skill, int> totalSkills = {};

  Shuffle({required this.parameter, required this.team}) {
    _groups = List<Group>.generate(
        parameter.noOfGroups, (i) => Group("Group ${i + 1}"),
        growable: false);

    for (var skill in Skill.values) {
      totalSkills[skill] = team.players.keys
          .toList()
          .fold(0, (prev, name) => prev + _weightedSkill(name, skill));

      for (var group in _groups) {
        group.skills[skill] = 0;
      }
    }
    developer.log(
        'Possible Groups: ${possibleGroups(team.players.length, parameter.noOfGroups)}',
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

  int _weightedSkill(String name, Skill skill) {
    if (parameter.available[name]!) {
      return team.players[name]!.skills[skill]! * team.weights[skill]!;
    }
    return 0;
  }

  void _addToGroup(String name, int groupNo) {
    var group = _groups[groupNo];
    group.members.add(name);
    for (var skill in Skill.values) {
      group.skills[skill] = group.skills[skill]! + _weightedSkill(name, skill);
    }
  }

  // https://en.wikipedia.org/wiki/Alias_method  ??
  // https://de.wikipedia.org/wiki/MCMC-Verfahren

  List<Group> shuffle() {
    final players = team.players.keys.toList()..sort();

    players.shuffle();

    var g = 0;
    for (var p = 0; p < team.players.length; p++) {
      final player = players[p];
      if (parameter.available[player]!) {
        _addToGroup(player, g);

        g = (g + 1) % parameter.noOfGroups;
      }
    }
    return _groups;
  }
}
