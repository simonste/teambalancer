import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/shuffle.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/player_data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/screens/groups_screen.dart';
import 'package:teambalancer/widgets/player_card.dart';

class ShuffleScreen extends StatefulWidget {
  const ShuffleScreen({required this.teamKey, required this.data, super.key});

  final TeamKey teamKey;
  final Data data;
  @override
  State<ShuffleScreen> createState() => _ShuffleScreenState();
}

class _ShuffleScreenState extends State<ShuffleScreen> {
  var parameter = ShuffleParameter();

  void toggle(String player, PlayerData data) {
    if (parameter.players.containsKey(player)) {
      parameter.players.remove(player);
    } else {
      parameter.players[player] = data;
    }
  }

  ButtonStyle? buttonStyle(selected) {
    return selected
        ? ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
                Theme.of(context).colorScheme.primary))
        : null;
  }

  TextStyle? textStyle(selected) {
    return selected
        ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.data.get().team(widget.teamKey);
    final players = team.players;
    if (parameter.weights.isEmpty) {
      parameter.weights = team.weights;
      parameter.players = Map<String, PlayerData>.from(team.players);
    }
    final sorted = players.keys.toList()..sort();

    var gridView = GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 3 / 1,
        ),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final name = sorted[index];
          final selected = parameter.players.containsKey(name);
          return GestureDetector(
            onTap: () {
              toggle(name, players[name]!);
              setState(() {});
            },
            child: PlayerCard.select(
              name,
              selected: selected,
              theme: Theme.of(context),
            ),
          );
        });

    var groupButtons = List<Widget>.generate(Constants.maxGroups - 1, (i) {
      final no = i + 2;
      final selected = (parameter.noOfGroups == no);
      return TextButton(
        style: buttonStyle(selected),
        onPressed: () => setState(() {
          parameter.noOfGroups = no;
        }),
        child: Text("$no", style: textStyle(selected)),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.shuffle)),
      body: Column(
        children: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Wrap(
                children: [
                  Row(children: [
                    Text(context.l10n.noOfGroups),
                    Expanded(child: OverflowBar(children: groupButtons)),
                  ]),
                  Text(context.l10n.noOfPlayers(parameter.players.length))
                ],
              )),
          Expanded(child: gridView)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final groups = ShuffleWeighted(parameter: parameter).shuffle();
          navigateTo(
              context,
              GroupScreen(
                  teamKey: widget.teamKey, data: widget.data, groups: groups));
        },
        child: const Icon(Icons.shuffle),
      ),
    );
  }
}
