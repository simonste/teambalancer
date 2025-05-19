import 'package:flutter_test/flutter_test.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/shuffle.dart';
import 'package:teambalancer/data/player_data.dart';

void main() {
  ShuffleParameter prepareShuffle(int noOfPlayers, {int noOfGroups = 2}) {
    var players = List.generate(noOfPlayers, (i) => "P${i + 1}");
    var shuffleParameter = ShuffleParameter();
    shuffleParameter.players = {
      for (var key in players) key: PlayerData.init(0)
    };
    shuffleParameter.weights = {
      for (var key in Skill.values) key: Constants.defaultWeight
    };
    shuffleParameter.noOfGroups = noOfGroups;
    return shuffleParameter;
  }

  void drawMultipleTimes(
    ShuffleParameter shuffleParameter,
    Function(List<List<String>>) checkFunction, {
    bool distinguish = true,
  }) {
    Set<String> groupStrings = {};
    for (var i = 0; i < 4; i++) {
      var groups = ShuffleWeighted(parameter: shuffleParameter).shuffle();
      groupStrings.add(groups.toString());

      var groupsSorted =
          groups.map((group) => group.members.keys.toList()..sort()).toList();
      checkFunction(groupsSorted);
    }
    if (distinguish) {
      expect(groupStrings.length, greaterThan(1));
    }
  }

  test('possible groups', () {
    expect(prepareShuffle(4, noOfGroups: 1).possibleGroups(), 1);
    expect(prepareShuffle(4, noOfGroups: 2).possibleGroups(), 3);
    expect(prepareShuffle(6, noOfGroups: 2).possibleGroups(), 10);
    expect(prepareShuffle(6, noOfGroups: 3).possibleGroups(), 15);
    expect(prepareShuffle(8, noOfGroups: 2).possibleGroups(), 35);
    expect(prepareShuffle(10, noOfGroups: 2).possibleGroups(), 126);
    expect(prepareShuffle(12, noOfGroups: 2).possibleGroups(), 462);
    expect(prepareShuffle(5, noOfGroups: 2).possibleGroups(), 10);
    expect(prepareShuffle(4, noOfGroups: 3).possibleGroups(), 6);
  });

  test('group sizes', () {
    var shuffleParameter = prepareShuffle(4, noOfGroups: 2);
    expect(shuffleParameter.groupSize(groupNo: 0), 2);
    expect(shuffleParameter.groupSize(groupNo: 1), 2);

    shuffleParameter = prepareShuffle(4, noOfGroups: 3);
    expect(shuffleParameter.groupSize(groupNo: 0), 2);
    expect(shuffleParameter.groupSize(groupNo: 1), 1);
    expect(shuffleParameter.groupSize(groupNo: 2), 1);

    shuffleParameter = prepareShuffle(6, noOfGroups: 4);
    expect(shuffleParameter.groupSize(groupNo: 0), 2);
    expect(shuffleParameter.groupSize(groupNo: 1), 2);
    expect(shuffleParameter.groupSize(groupNo: 2), 1);
    expect(shuffleParameter.groupSize(groupNo: 3), 1);
  });

  test('draw groups', () {
    var shuffleParameter = prepareShuffle(4);

    drawMultipleTimes(shuffleParameter, (groups) {
      expect(groups.length, 2);
      expect(groups[0].length, 2);
      expect(groups[1].length, 2);
    });
  });

  test('draw groups weights', () {
    var shuffleParameter = prepareShuffle(4);
    shuffleParameter.players['P1']!.skills[Skill.physical] = 1;
    shuffleParameter.players['P2']!.skills[Skill.physical] = 1;
    shuffleParameter.players['P3']!.skills[Skill.physical] = 5;
    shuffleParameter.players['P4']!.skills[Skill.physical] = 5;

    drawMultipleTimes(shuffleParameter, (groups) {
      expect(groups.length, 2);
      expect(groups[0].length, 2);
      expect(groups[1].length, 2);

      // the two better players should not be in the same group
      expect(groups[0].contains("P1") && groups[0].contains("P2"), false);
      expect(groups[0].contains("P3") && groups[0].contains("P4"), false);
    });
  });

  test('draw uneven', () {
    var shuffleParameter = prepareShuffle(5);

    drawMultipleTimes(shuffleParameter, (groups) {
      expect(groups.length, 2);
      expect(groups[0].length + groups[1].length, 5);
    });
  });

  test('draw 4 groups', () {
    var shuffleParameter = prepareShuffle(6);
    shuffleParameter.noOfGroups = 4;

    drawMultipleTimes(shuffleParameter, (groups) {
      expect(groups.length, 4);
      expect(groups[0].length, inInclusiveRange(1, 2));
      expect(groups[1].length, inInclusiveRange(1, 2));
      expect(groups[2].length, inInclusiveRange(1, 2));
      expect(groups[3].length, inInclusiveRange(1, 2));
    });
  });

  test('draw groups tagged', () {
    var shuffleParameter = prepareShuffle(4);
    shuffleParameter.players['P1']!.tags = ["Goalie"];
    shuffleParameter.players['P3']!.tags = ["Goalie"];

    drawMultipleTimes(shuffleParameter, (groups) {
      expect(groups.length, 2);
      expect(groups[0].length, 2);
      expect(groups[1].length, 2);

      // the two Goalies should not be in the same group
      expect(groups[0].contains("P1") && groups[0].contains("P3"), false);
      expect(groups[0].contains("P2") && groups[0].contains("P4"), false);
    });
  });

  test('draw groups tagged and weight', () {
    var shuffleParameter = prepareShuffle(4);
    shuffleParameter.players['P1']!.tags = ["Goalie"];
    shuffleParameter.players['P3']!.tags = ["Goalie"];
    shuffleParameter.players['P1']!.skills[Skill.physical] = 1;
    shuffleParameter.players['P2']!.skills[Skill.physical] = 1;
    shuffleParameter.players['P3']!.skills[Skill.physical] = 5;
    shuffleParameter.players['P4']!.skills[Skill.physical] = 5;

    drawMultipleTimes(shuffleParameter, (groups) {
      expect(groups.length, 2);
      expect(groups[0].length, 2);
      expect(groups[1].length, 2);

      // the two Goalies should not be in the same group
      // the two better players should not be in the same group
      if (groups[0].contains("P1")) {
        expect(groups[0].toList()..sort(), ["P1", "P4"]);
        expect(groups[1].toList()..sort(), ["P2", "P3"]);
      } else {
        expect(groups[1].toList()..sort(), ["P1", "P4"]);
        expect(groups[0].toList()..sort(), ["P2", "P3"]);
      }
    }, distinguish: false);
  });

  test('draw groups multi tagged', () {
    var shuffleParameter = prepareShuffle(4);
    shuffleParameter.players['P1']!.tags = ["Goalie", "Male"];
    shuffleParameter.players['P2']!.tags = ["Female"];
    shuffleParameter.players['P3']!.tags = ["Goalie", "Female"];
    shuffleParameter.players['P4']!.tags = ["Male"];
    shuffleParameter.players['P1']!.skills[Skill.physical] = 1;
    shuffleParameter.players['P2']!.skills[Skill.physical] = 1;
    shuffleParameter.players['P3']!.skills[Skill.physical] = 5;
    shuffleParameter.players['P4']!.skills[Skill.physical] = 5;

    drawMultipleTimes(shuffleParameter, (groups) {
      expect(groups.length, 2);
      expect(groups[0].length, 2);
      expect(groups[1].length, 2);
      // P1 and P2 should be together in one team (tags are more important than weights)
      if (groups[0].contains("P1")) {
        expect(groups[0].contains("P2"), true);
        expect(groups[0].contains("P3"), false);
        expect(groups[0].contains("P4"), false);
      } else {
        expect(groups[1].contains("P1"), true);
        expect(groups[1].contains("P2"), true);
      }
    }, distinguish: false);
  });
}
