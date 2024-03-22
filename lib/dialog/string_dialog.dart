import 'package:flutter/material.dart';
import 'package:teambalancer/common/localization.dart';

Future<String?> stringDialog(BuildContext context,
    {required String title,
    String defaultText = "",
    Function? deleteFunction,
    String? hintText}) {
  hintText ??= title;
  var controller = TextEditingController(text: defaultText);
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      void finish() {
        if (controller.text.isEmpty) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop(controller.text);
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
                  deleteFunction();
                  Navigator.of(context).pop();
                },
              ))
            ]));
      }

      return AlertDialog(
        title: titleWidget,
        content: TextField(
            decoration: InputDecoration(hintText: hintText),
            autofocus: true,
            keyboardType: TextInputType.text,
            controller: controller,
            onSubmitted: (value) => finish()),
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
}
