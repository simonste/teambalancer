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

  double weightedSkill(String name, Skill skill) =>
      players[name]!.skills[skill]! * weights[skill]!;

  double totalSkill(Skill skill) => players.keys
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
        List<String> tags = [];
        for (var skill in Skill.values) {
          error += (group.skill(skill) - avgSkills[skill]!).abs();
        }
        group.members.forEach((name, data) {
          for (var tag in data.tags) {
            if (tags.contains(tag)) {
              // punish duplicate tags in group
              error += group.members.length * 50;
            } else {
              tags.add(tag);
            }
          }
        });
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
            (i) => GroupData("Group ${i + 1}", parameter.weights),
            growable: false);

  void _addToGroup(String playerName, int groupNo) {
    var group = _groups[groupNo];
    group.members[playerName] = parameter.players[playerName]!;
  }

  int _groupNoToAddTo() {
    var smallestGroupLength =
        _groups.map((e) => e.members.length).reduce((a, b) => a < b ? a : b);
    List<int> groupNos = [];
    for (var i = 0; i < _groups.length; i++) {
      if (_groups[i].members.length == smallestGroupLength) {
        groupNos.add(i);
      }
    }

    Random random = Random();
    groupNos.shuffle(random);
    return groupNos[0];
  }

  void _distributeToGroups(List<String> players) {
    for (var p = 0; p < players.length; p++) {
      final playerName = players[p];
      final playerAlreadyDrawn =
          _groups.any((group) => group.members.containsKey(playerName));
      if (!playerAlreadyDrawn) {
        _addToGroup(playerName, _groupNoToAddTo());
      }
    }
  }

  Map<String, List<String>> tagPlayerMap() {
    Map<String, List<String>> playersWithThisTag = {};
    parameter.players.forEach((name, playerData) {
      for (var tag in playerData.tags) {
        if (playersWithThisTag.containsKey(tag)) {
          playersWithThisTag[tag]!.add(name);
        } else {
          playersWithThisTag[tag] = [name];
        }
      }
      if (playerData.tags.isEmpty) {
        if (!playersWithThisTag.containsKey("")) {
          playersWithThisTag[""] = [];
        }
        playersWithThisTag[""]!.add(name);
      }
    });
    return playersWithThisTag;
  }

  List<GroupData> shuffle() {
    Random random = Random();

    List<List<String>> tagGroups = [];
    if (parameter.separateTagged) {
      tagGroups = tagPlayerMap().values.toList();
    } else {
      tagGroups = [parameter.players.keys.toList()];
    }

    for (final tagGroup in tagGroups) {
      final playerNames = tagGroup..shuffle(random);
      _distributeToGroups(playerNames);
    }
    return _groups;
  }
}
