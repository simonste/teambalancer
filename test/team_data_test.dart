import 'package:flutter_test/flutter_test.dart';
import 'package:teambalancer/data/team_data.dart';

void main() {
  test('sorted keys', () {
    var teams = TeamsData({});
    teams.addTeam(TeamData("Gamma", 1, {}, {}, [], "AAAA"));
    teams.addTeam(TeamData("Zeta", 1, {}, {}, [], "BBBB"));
    teams.addTeam(TeamData("Alpha", 1, {}, {}, [], "CCCC"));

    var sorted = teams.getKeysSortedByName();
    expect(sorted[0].key, "CCCC");
    expect(sorted[1].key, "AAAA");
    expect(sorted[2].key, "BBBB");
  });
}
