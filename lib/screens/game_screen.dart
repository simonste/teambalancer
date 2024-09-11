import 'package:calc/calc.dart';
import 'package:flutter/material.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/dialog/result_dialog.dart';
import 'package:teambalancer/widgets/player_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen(
      {required this.game,
      required this.teamData,
      required this.isAdmin,
      super.key});

  final Game game;
  final TeamData teamData;
  final bool isAdmin;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void save() {
    widget.game.save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cols = [
      Row(children: [
        Expanded(
            child: TextButton(
                onPressed: () => dateDialog(widget.game.date),
                child:
                    Text(getDateFormatter(context).format(widget.game.date)))),
        Expanded(
            child: TextButton(
                onPressed: () => timeDialog(widget.game.date),
                child:
                    Text(getTimeFormatter(context).format(widget.game.date)))),
        widget.isAdmin
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  widget.game.remove(widget.teamData.teamKey);
                  Navigator.of(context).pop(widget.game.historyId);
                })
            : const SizedBox()
      ]),
    ];
    cols.add(InkWell(
        onTap: () => _resultDialog(widget.game.result),
        child: Text("${context.l10n.result}: ${widget.game.result}")));

    final noOfGroups = widget.game.groups.length;
    final largestGroup =
        widget.game.groups.fold(0, (s, group) => max(s, group.length));
    var gridView = GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: noOfGroups,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 3 / 1,
        ),
        itemCount: noOfGroups * largestGroup,
        itemBuilder: (context, index) {
          final groupNo = index % noOfGroups;
          final playerIdx = (index / noOfGroups).floor();
          if (widget.game.groups[groupNo].length <= playerIdx) {
            return const SizedBox();
          }
          final name = widget.game.groups[groupNo][playerIdx];
          return GestureDetector(
              onLongPress: () {
                widget.game.moveToNextGroup(name);
                save();
              },
              child:
                  PlayerCard(name, no: groupNo + 1, theme: Theme.of(context)));
        });
    cols.add(Expanded(child: gridView));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamData.name),
      ),
      body: Column(children: cols),
    );
  }

  void dateDialog(DateTime time) async {
    var date = await showDatePicker(
        context: context,
        initialDate: time,
        firstDate: DateTime(2020),
        lastDate: DateTime(2049));

    if (date == null) return; // cancelled
    widget.game.date =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    save();
  }

  void timeDialog(DateTime time) async {
    var timeOfDay = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(time));

    if (timeOfDay == null) return; // cancelled
    widget.game.date = DateTime(
        time.year, time.month, time.day, timeOfDay.hour, timeOfDay.minute);
    save();
  }

  void _resultDialog(String? result) async {
    String? input;
    if (result != null) {
      input = await resultDialog(
        context,
        noOfGroups: widget.game.groups.length,
        result: result,
      );
    }
    if (input == null) return; // empty name not allowed
    widget.game.result = input;
    save();
  }
}
