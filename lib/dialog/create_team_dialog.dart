import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';

class TeamDialogData {
  TeamDialogData(this.name, this.sport);

  String name;
  Sport sport;
}

Future<TeamDialogData?> createTeamDialog(BuildContext context,
    {required String title,
    TeamDialogData? defaultData,
    Function? deleteFunction,
    String? hintText}) {
  hintText ??= title;
  var controller = TextEditingController(
      text: (defaultData != null) ? defaultData.name : "");
  var selectedSport =
      (defaultData != null) ? defaultData.sport : Sport.football;
  return showDialog<TeamDialogData>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void finish() {
              if (controller.text.isEmpty) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context)
                    .pop(TeamDialogData(controller.text, selectedSport));
              }
            }

            Widget titleWidget = Text(title);
            if (deleteFunction != null) {
              titleWidget = SizedBox(
                  height: 32,
                  child: Row(children: [
                    Text(title),
                    const Expanded(child: SizedBox.expand()),
                    Expanded(
                        child: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Navigator.of(context).pop();
                        deleteFunction();
                      },
                    ))
                  ]));
            }

            List<Widget> sports = [];
            for (var sport in Sport.values) {
              final selected = sport == selectedSport;
              sports.add(Expanded(
                child: (IconButton(
                  style: selected
                      ? ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primary))
                      : null,
                  onPressed: () => setState(() {
                    selectedSport = sport;
                  }),
                  icon: getSportIcon(sport,
                      color: selected
                          ? Theme.of(context).colorScheme.onPrimary
                          : null),
                )),
              ));
            }

            return AlertDialog(
              title: titleWidget,
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: sports),
                TextField(
                    decoration: InputDecoration(hintText: hintText),
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    controller: controller,
                    onSubmitted: (value) => finish())
              ]),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: Text(context.l10n.ok),
                  onPressed: () => finish(),
                ),
              ],
            );
          },
        );
      });
}
