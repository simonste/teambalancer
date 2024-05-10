import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/shuffle.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/player_data.dart';
import 'package:teambalancer/screens/groups_screen.dart';

class ShuffleScreen extends StatefulWidget {
  const ShuffleScreen({required this.teamName, required this.data, super.key});

  final String teamName;
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

  @override
  Widget build(BuildContext context) {
    final team = widget.data.get().teams[widget.teamName]!;
    final players = team.players;
    if (parameter.weights.isEmpty) {
      parameter.weights = team.weights;
      parameter.players = Map<String, PlayerData>.from(team.players);
    }

    var listView = ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final sorted = players.keys.toList()..sort();
        final name = sorted[index];
        return Card(
          child: ListTile(
            title: Text(name),
            leading: Checkbox(
              value: parameter.players.containsKey(name),
              onChanged: (bool? value) {
                toggle(name, players[name]!);
                setState(() {});
              },
            ),
            onTap: () {
              toggle(name, players[name]!);
              setState(() {});
            },
          ),
        );
      },
    );

    var groupButtons = List<Widget>.generate(Constants.maxGroups - 1, (i) {
      final no = i + 2;
      final selected = (parameter.noOfGroups == no);
      return TextButton(
        style: selected
            ? ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary))
            : null,
        onPressed: () => setState(() {
          parameter.noOfGroups = no;
        }),
        child: Text("$no",
            style: selected
                ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                : null),
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
                    Expanded(child: ButtonBar(children: groupButtons)),
                  ]),
                  Text(context.l10n.noOfPlayers(parameter.players.length))
                ],
              )),
          Expanded(child: listView)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final groups = ShuffleWeighted(parameter: parameter).shuffle();
          navigateTo(
              context,
              GroupScreen(
                  teamName: widget.teamName,
                  data: widget.data,
                  groups: groups));
        },
        child: const Icon(Icons.shuffle),
      ),
    );
  }
}
