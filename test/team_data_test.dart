import 'package:flutter_test/flutter_test.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/player_data.dart';
import 'package:teambalancer/data/team_data.dart';

void main() {
  TeamData createTeam(teamName, int players) {
    var p = <String, PlayerData>{};
    for (int i = 1; i <= players; i++) {
      p["P$i"] = PlayerData({}, [], i);
    }
    return TeamData(teamName, 1, p, {}, [], "ABCDEF");
  }

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

  test('create team data', () {
    var team = createTeam("Team", 2);

    expect(team.name, "Team");
    expect(team.players.length, 2);
  });

  test('team data games', () {
    var team = createTeam("Team", 6);
    team.loadGames([
      {
        "historyId": 1,
        "date": "2000-01-01 12:00:00",
        "groups": [
          [1, 2],
          [3, 4]
        ],
        "result": "4:3",
      },
      {
        "historyId": 2,
        "date": "2000-01-02 12:00:00",
        "groups": [
          [1],
          [3, 4],
          [2, 5, 6],
        ],
        "result": "",
      }
    ]);

    expect(team.games.length, 2);
    expect(team.games[0].groups.length, 2);
    expect(team.games[0].groups[0].members, ["P1", "P2"]);
    expect(team.games[0].groups[0].score, 4);
    expect(team.games[0].groups[1].members, ["P3", "P4"]);
    expect(team.games[0].groups[1].score, 3);
    expect(team.games[1].groups.length, 3);
    expect(team.games[1].groups[0].members, ["P1"]);
    expect(team.games[1].groups[0].score, null);
    expect(team.games[1].groups[1].members, ["P3", "P4"]);
    expect(team.games[1].groups[1].score, null);
    expect(team.games[1].groups[2].members, ["P2", "P5", "P6"]);
    expect(team.games[1].groups[2].score, null);
  });

  test('team data result', () {
    var team = createTeam("Team", 6);

    team.loadGames([
      {
        "historyId": 1,
        "date": "2000-01-01 12:00:00",
        "groups": [
          [1, 2],
          [3, 4]
        ],
        "result": "4:3",
      }
    ]);

    expect(team.games[0].result(), "4:3");

    team.games[0].setResult("6:2");
    expect(team.games[0].result(), "6:2");

    team.games[0].setResult("22"); // ignored
    expect(team.games[0].result(), "6:2");
  });

  test('player history', () {
    var team = createTeam("Team", 4);

    team.loadGames([
      {
        "historyId": 1,
        "date": "2000-01-01 12:00:00",
        "groups": [
          [1, 2],
          [3, 4]
        ],
        "result": "4:3",
      },
      {
        "historyId": 2,
        "date": "2000-01-01 14:00:00",
        "groups": [
          [1, 3],
          [2, 4]
        ],
        "result": "2:3",
      },
      {
        "historyId": 3,
        "date": "2000-01-01 13:00:00",
        "groups": [
          [1, 3],
          [2, 4]
        ],
        "result": "2:0",
      },
      {
        "historyId": 4,
        "date": "2000-01-01 15:00:00",
        "groups": [
          [2],
          [4]
        ],
        "result": "2:2",
      },
      {
        "historyId": 5,
        "date": "2000-01-01 16:00:00",
        "groups": [
          [1, 2],
          [4]
        ],
        "result": "",
      }
    ]);

    // sorted correctly?
    expect(team.games.map((e) => e.historyId).toList(), [1, 3, 2, 4, 5]);

    final p1 = team.players["P1"]!;
    final p2 = team.players["P2"]!;

    expect(p1.history, [
      GameResult.won,
      GameResult.won,
      GameResult.lost,
      GameResult.miss,
      GameResult.noScore
    ]);
    expect(p1.getWinPercentage(), 2 / 3);
    expect(p1.skills[Skill.form], closeTo(0.7 + 0.6, 0.01));

    expect(p2.history, [
      GameResult.won,
      GameResult.lost,
      GameResult.won,
      GameResult.draw,
      GameResult.noScore
    ]);
    expect(p2.getWinPercentage(), 2 / 3);
    expect(p2.skills[Skill.form], closeTo(0.45 + 0.8 + 0.6, 0.01));
  });

  test('refresh games', () {
    var team = createTeam("Team", 4);

    team.loadGames([
      {
        "historyId": 1,
        "date": "2000-01-01 12:00:00",
        "groups": [
          [1, 2],
          [3, 4]
        ],
        "result": "4:3",
      },
      {
        "historyId": 2,
        "date": "2000-01-01 14:00:00",
        "groups": [
          [1, 3],
          [2, 4]
        ],
        "result": "2:3",
      },
    ]);

    expect(team.games.map((e) => e.historyId).toList(), [1, 2]);
    expect(team.players["P1"]!.history, [GameResult.won, GameResult.lost]);
    expect(team.players["P2"]!.history, [GameResult.won, GameResult.won]);

    team.games[0].date = DateTime(2000, 1, 2, 11, 0, 0);
    team.refreshGames();
    expect(team.games.map((e) => e.historyId).toList(), [2, 1]);
    expect(team.players["P1"]!.history, [GameResult.lost, GameResult.won]);
    expect(team.players["P2"]!.history, [GameResult.won, GameResult.won]);

    expect(team.games[1].result(), "4:3");
    team.games[1].setResult("2:2");
    team.refreshGames();
    expect(team.players["P1"]!.history, [GameResult.lost, GameResult.draw]);
    expect(team.players["P2"]!.history, [GameResult.won, GameResult.draw]);
  });
}
