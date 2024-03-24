import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/shuffle.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/screens/groups_screen.dart';

class ShuffleScreen extends StatefulWidget {
  const ShuffleScreen({required this.teamName, required this.data, super.key});

  final String teamName;
  final Data data;
  @override
  State<ShuffleScreen> createState() => _ShuffleScreenState();
}

class ShuffleParameter {
  bool separateTagged = true;
  int noOfGroups = 2;
  Map<String, bool> available = {};

  void allAvailable(List<String> players) =>
      available = {for (var key in players) key: true};
}

class _ShuffleScreenState extends State<ShuffleScreen> {
  var parameter = ShuffleParameter();

  @override
  Widget build(BuildContext context) {
    final team = widget.data.get().teams[widget.teamName]!;
    final players = team.players;
    if (parameter.available.isEmpty) {
      parameter.allAvailable(players.keys.toList());
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
              value: parameter.available[name],
              onChanged: (bool? value) {
                parameter.available[name] = value!;
                setState(() {});
              },
            ),
            onTap: () {
              parameter.available[name] = !parameter.available[name]!;
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
          Wrap(children: [
            Row(
              children: [
                Text(context.l10n.noOfGroups),
                Expanded(child: ButtonBar(children: groupButtons)),
              ],
            )
          ]),
          Expanded(child: listView)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final groups = Shuffle(team: team, parameter: parameter).shuffle();
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
