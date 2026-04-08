import 'package:flutter/material.dart';

class TagText extends Container {
  static const _borderRadius = BorderRadius.all(Radius.circular(20));
  static const _margin = EdgeInsets.all(5);
  static const _padding = EdgeInsets.all(5);

  TagText.tag(String text, {super.key, required ThemeData theme, active = true})
      : super(
            decoration: BoxDecoration(
              borderRadius: _borderRadius,
              border: Border.all(),
              color: active ? theme.secondaryHeaderColor : null,
            ),
            margin: _margin,
            padding: _padding,
            child: Text(
              text,
              style: TextStyle(color: active ? Colors.white : null),
            ));
}
