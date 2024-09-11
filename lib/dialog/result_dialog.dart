import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:teambalancer/common/localization.dart';

Future<String?> resultDialog(BuildContext context,
    {required int noOfGroups, String result = ""}) {
  var scores = result.isEmpty ? [] : result.split(":").map(int.parse).toList();
  for (var i = scores.length; i < noOfGroups; i++) {
    scores.add(0);
  }

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        void finish() {
          Navigator.of(context).pop(scores.join(":"));
        }

        return AlertDialog(
          title: Text(context.l10n.result),
          content: Row(
              children: scores
                  .asMap()
                  .entries
                  .map((e) => Expanded(
                          child: NumberPicker(
                        key: Key("picker_${e.key}"),
                        minValue: 0,
                        maxValue: 99,
                        value: e.value,
                        onChanged: (v) => setState(() => scores[e.key] = v),
                      )))
                  .toList()),
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
      });
    },
  );
}
