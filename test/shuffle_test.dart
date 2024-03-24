import 'package:flutter_test/flutter_test.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/shuffle.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/screens/shuffle_screen.dart';

void main() {
  test('possible groups', () {
    expect(Shuffle.possibleGroups(4, 1), 1);
    expect(Shuffle.possibleGroups(4, 2), 3);
    expect(Shuffle.possibleGroups(6, 2), 10);
    expect(Shuffle.possibleGroups(6, 3), 15);
    expect(Shuffle.possibleGroups(8, 2), 35);
    expect(Shuffle.possibleGroups(10, 2), 126);
    expect(Shuffle.possibleGroups(12, 2), 462);
    expect(Shuffle.possibleGroups(5, 2), 10);
    expect(Shuffle.possibleGroups(4, 3), 6);
  });

  test('draw groups', () {
    var players = ["P1", "P2", "P3", "P4"];
    var shuffleParameter = ShuffleParameter();
    shuffleParameter.allAvailable(players);
    var shuffle = Shuffle(
        parameter: shuffleParameter,
        team: TeamData.init(Sport.football, players));

    var groups = shuffle.shuffle();

    expect(groups.length, 2);
  });
}
