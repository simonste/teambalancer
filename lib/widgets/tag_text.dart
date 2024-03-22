import 'package:flutter/material.dart';

final colors = [
  Colors.cyan,
  Colors.orange,
  Colors.blueGrey,
  Colors.red,
  Colors.blueAccent
];

class TagText extends Container {
  static const _borderRadius = BorderRadius.all(Radius.circular(20));
  static const _margin = EdgeInsets.all(5);
  static const _padding = EdgeInsets.all(5);

  TagText(String text, {super.key, int i = 0})
      : super(
            decoration: BoxDecoration(
              borderRadius: _borderRadius,
              color: colors[i % colors.length],
            ),
            margin: _margin,
            padding: _padding,
            child: Text(text));

  TagText.tag(String text, {super.key, active = true})
      : super(
            decoration: BoxDecoration(
              borderRadius: _borderRadius,
              border: Border.all(),
              color: active ? Colors.black : null,
            ),
            margin: _margin,
            padding: _padding,
            child: Text(
              text,
              style: TextStyle(color: active ? Colors.white : null),
            ));

  TagText.skill(int text, {super.key, int i = 0})
      : super(
            decoration: BoxDecoration(
              borderRadius: _borderRadius,
              color: colors[i % colors.length],
            ),
            margin: _margin,
            width: text * 30,
            padding: _padding,
            child: Center(child: Text(text.toString())));
}
