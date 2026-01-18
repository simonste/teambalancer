import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final String score;
  final ThemeData theme;
  final VoidCallback? onTap;

  const ScoreCard(this.score, {required this.theme, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(score, style: const TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}
