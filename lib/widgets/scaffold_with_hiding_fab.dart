import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// https://stackoverflow.com/questions/45631350/flutter-hiding-floatingactionbutton

class ScaffoldWithHidingFab extends StatefulWidget {
  const ScaffoldWithHidingFab(
      {super.key,
      required this.appBar,
      required this.body,
      required this.floatingActionButton});

  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  State<ScaffoldWithHidingFab> createState() => _ScaffoldWithHidingFabState();
}

class _ScaffoldWithHidingFabState extends State<ScaffoldWithHidingFab> {
  bool _showFab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            final ScrollDirection direction = notification.direction;
            setState(() {
              if (direction == ScrollDirection.reverse) {
                _showFab = false;
              } else if (direction == ScrollDirection.forward) {
                _showFab = true;
              }
            });
            return true;
          },
          child: widget.body),
      floatingActionButton: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: _showFab ? Offset.zero : const Offset(0, 2),
          child: widget.floatingActionButton),
    );
  }
}
