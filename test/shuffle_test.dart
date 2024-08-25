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

    for (var i = 0; i < 4; i++) {
      var groups = ShuffleWeighted(parameter: shuffleParameter).shuffle();

      expect(groups.length, 2);
      expect(groups[0].members.length, 2);
      expect(groups[1].members.length, 2);
    }
  });

  test('draw groups weights', () {
    var shuffleParameter = prepareShuffle(4);
    shuffleParameter.players['P1']!.skills[Skill.physical] = 1;
    shuffleParameter.players['P2']!.skills[Skill.physical] = 1;
    shuffleParameter.players['P3']!.skills[Skill.physical] = 5;
    shuffleParameter.players['P4']!.skills[Skill.physical] = 5;

    for (var i = 0; i < 4; i++) {
      var groups = ShuffleWeighted(parameter: shuffleParameter).shuffle();

      expect(groups.length, 2);
      var m0 = groups[0].members;
      var m1 = groups[1].members;
      expect(m0.length, 2);
      expect(m1.length, 2);

      // two two better players should not be in the same group
      expect(m0.keys.contains("P1") && m0.keys.contains("P2"), false);
      expect(m0.keys.contains("P3") && m0.keys.contains("P4"), false);
    }
  });

  test('draw uneven', () {
    var shuffleParameter = prepareShuffle(5);

    for (var i = 0; i < 4; i++) {
      var groups = ShuffleWeighted(parameter: shuffleParameter).shuffle();

      expect(groups.length, 2);
      expect(groups[0].members.length + groups[1].members.length, 5);
    }
  });

  test('draw 4 groups', () {
    var shuffleParameter = prepareShuffle(6);
    shuffleParameter.noOfGroups = 4;

    for (var i = 0; i < 4; i++) {
      var groups = ShuffleWeighted(parameter: shuffleParameter).shuffle();

      expect(groups.length, 4);
      expect(groups[0].members.length, inInclusiveRange(1, 2));
      expect(groups[1].members.length, inInclusiveRange(1, 2));
      expect(groups[2].members.length, inInclusiveRange(1, 2));
      expect(groups[3].members.length, inInclusiveRange(1, 2));
    }
  });
}
