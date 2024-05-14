import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/shuffle.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/team_key.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen(
      {required this.groups,
      required this.teamKey,
      required this.data,
      super.key});

  final List<Group> groups;
  final TeamKey teamKey;
  final Data data;
  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Widget skill(String name) {
    return getTacticsIcon(widget.data
            .get()
            .team(widget.teamKey)
            .players[name]!
            .skills[Skill.tactical] ??
        1);
  }

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
      itemCount: widget.groups.length,
      itemBuilder: (context, index) {
        final group = widget.groups[index];

        var weights = <Widget>[];
        group.skills.forEach((key, value) {
          weights.add(Text("$key : ${value.toStringAsFixed(1)}"));
        });

        return Card(
          child: ListTile(
            title: Row(children: [Text(group.name)]),
            subtitle: Column(
                children: group.members
                    .map((element) =>
                        Row(children: [skill(element), Text(element)]))
                    .toList()),
            trailing: Column(children: weights),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.data.get().team(widget.teamKey).name)),
      body: listView,
    );
  }
}
