import 'package:flutter_test/flutter_test.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/player_data.dart';

void main() {
  final weights = {for (var s in Skill.values) s: 1};

  PlayerData player(int id) =>
      PlayerData({for (var s in Skill.values) s: id.toDouble()}, [], id);

  /// Group 1: P1, P2, P3 -- Group 2: P4, P5
  Game createGame() {
    final g1 = GroupData("Group 1", weights)
      ..members = {"P1": player(1), "P2": player(2), "P3": player(3)};
    final g2 = GroupData("Group 2", weights)
      ..members = {"P4": player(4), "P5": player(5)};
    return Game(date: DateTime(2026), groups: [g1, g2], historyId: 1);
  }

  test('group of a player', () {
    final game = createGame();
    expect(game.groupOf(1), 0);
    expect(game.groupOf(5), 1);
    expect(game.groupOf(6), isNull);
    expect(game.contains(4), isTrue);
    expect(game.contains(6), isFalse);
  });

  test('move a player to a group', () {
    final game = createGame();
    game.moveToGroup(2, 1);
    expect(game.groups[0].members.keys, ["P1", "P3"]);
    expect(game.groups[1].members.keys, containsAll(["P2", "P4", "P5"]));

    // moving to its own group or moving an unknown player changes nothing
    game.moveToGroup(2, 1);
    game.moveToGroup(6, 0);
    expect(game.groups[0].members.length, 2);
    expect(game.groups[1].members.length, 3);
  });

  test('remove a player from the game', () {
    final game = createGame();
    game.removePlayer(4);
    expect(game.contains(4), isFalse);
    expect(game.groups[1].members.keys, ["P5"]);

    game.removePlayer(6); // not part of the game
    expect(game.groups[0].members.length + game.groups[1].members.length, 4);
  });

  test('add a player to the smallest group', () {
    final game = createGame();
    final p6 = player(6);
    game.addPlayer("P6", p6);
    expect(game.groupOf(6), 1);

    // on a tie the first group gets the player
    game.addPlayer("P7", player(7));
    expect(game.groupOf(7), 0);

    // a player already in the game is not added twice
    game.addPlayer("P6", p6);
    expect(game.groups[1].members.length, 3);
  });

  test('an added player keeps the skills of when it was added', () {
    final game = createGame();
    final p6 = player(6);
    game.addPlayer("P6", p6);
    p6.skills[Skill.tactical] = 1;
    expect(game.groups[1].members["P6"]!.skills[Skill.tactical], 6);
  });
}
