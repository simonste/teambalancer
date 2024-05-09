import 'package:flutter_test/flutter_test.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/shuffle.dart';
import 'package:teambalancer/data/player_data.dart';

void main() {
  ShuffleParameter prepareShuffle(int noOfPlayers) {
    var players = List.generate(noOfPlayers, (i) => "P${i + 1}");
    var shuffleParameter = ShuffleParameter();
    shuffleParameter.players = {
      for (var key in players) key: PlayerData.init(0)
    };
    shuffleParameter.weights = {
      for (var key in Skill.values) key: Constants.defaultWeight
    };
    return shuffleParameter;
  }

  test('possible groups', () {
    expect(ShuffleWeighted.possibleGroups(4, 1), 1);
    expect(ShuffleWeighted.possibleGroups(4, 2), 3);
    expect(ShuffleWeighted.possibleGroups(6, 2), 10);
    expect(ShuffleWeighted.possibleGroups(6, 3), 15);
    expect(ShuffleWeighted.possibleGroups(8, 2), 35);
    expect(ShuffleWeighted.possibleGroups(10, 2), 126);
    expect(ShuffleWeighted.possibleGroups(12, 2), 462);
    expect(ShuffleWeighted.possibleGroups(5, 2), 10);
    expect(ShuffleWeighted.possibleGroups(4, 3), 6);
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
      expect(m0.contains("P1") && m0.contains("P2"), false);
      expect(m0.contains("P3") && m0.contains("P4"), false);
    }
  });
}
