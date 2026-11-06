import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/sorting.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/preference_data.dart';
import 'package:teambalancer/data/team_key.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen(
      {required this.teamKey, required this.data, super.key});

  final TeamKey teamKey;
  final Data data;
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  PlayerSorting sortingKind = PlayerSorting.name;
  bool reversed = false;

  static const _columnWidths = {
    0: FlexColumnWidth(2.5),
    1: FlexColumnWidth(1),
    2: FlexColumnWidth(1),
    3: FlexColumnWidth(1),
    4: FlexColumnWidth(1),
    5: FlexColumnWidth(1),
  };
  static const _cellPadding = EdgeInsets.symmetric(horizontal: 6);
  static const _rowPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 12);

  void sortBy(PlayerSorting kind) {
    setState(() {
      // a second tap on the same column reverses the order
      reversed = (kind == sortingKind) ? !reversed : false;
      sortingKind = kind;
    });
  }

  Widget headerCell(PlayerSorting kind, Widget label,
      {bool numeric = true, String? tooltip}) {
    final theme = Theme.of(context);
    final active = kind == sortingKind;
    final color =
        active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    final arrow = Icon(
      // name sorts A-Z, numbers sort from the highest
      (kind == PlayerSorting.name) != reversed
          ? Icons.arrow_downward
          : Icons.arrow_upward,
      size: 14,
      color: color,
    );
    final cell = InkWell(
      onTap: () => sortBy(kind),
      child: Padding(
        padding: _cellPadding.copyWith(top: 12, bottom: 12),
        child: Row(
          mainAxisAlignment:
              numeric ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (active && numeric) arrow,
            Flexible(
              child: DefaultTextStyle.merge(
                style: theme.textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                child: label,
              ),
            ),
            if (active && !numeric) arrow,
          ],
        ),
      ),
    );
    return tooltip == null ? cell : Tooltip(message: tooltip, child: cell);
  }

  Widget numberCell(String text) {
    return Padding(
      padding: _cellPadding,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.data.get().team(widget.teamKey);
    final players = team.players;

    var sorted = players.keys.toList()
      ..sort((a, b) => sorting(sortingKind, players, a, b));
    if (reversed) sorted = sorted.reversed.toList();

    final header = Table(
      columnWidths: _columnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          headerCell(PlayerSorting.name, Text(context.l10n.name),
              numeric: false),
          headerCell(PlayerSorting.games, Text(context.l10n.playedShort),
              tooltip: context.l10n.total),
          headerCell(PlayerSorting.won, Text(context.l10n.wonShort),
              tooltip: context.l10n.won),
          headerCell(PlayerSorting.lost, Text(context.l10n.lostShort),
              tooltip: context.l10n.lost),
          headerCell(
              PlayerSorting.winPercentage, Text(context.l10n.winPercentage)),
          headerCell(
              PlayerSorting.form,
              // the form icon is not tinted, its size is 10 + 1.8² px
              getSkillIcon(Skill.form, 1.8, Sport.values[team.sport],
                  color: null)),
        ]),
      ],
    );

    Widget playerRow(String name) {
      final player = players[name]!;
      final history = player.history;
      final won = history.where((gr) => gr == GameResult.won).length;
      final lost = history.where((gr) => gr == GameResult.lost).length;
      final caps = history.where((gr) => gr != GameResult.miss).length;
      final winPercentage =
          (won + lost) > 0 ? "${(100 * won / (won + lost)).round()}" : "–";
      final form = player.skills[Skill.form]!.toStringAsFixed(1);

      return Padding(
        padding: _rowPadding,
        child: Table(
          columnWidths: _columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              Padding(
                padding: _cellPadding,
                child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              numberCell("$caps"),
              numberCell("$won"),
              numberCell("$lost"),
              numberCell(winPercentage),
              numberCell(form),
            ]),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _rowPadding.left),
            child: header,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: sorted.length,
              itemBuilder: (context, i) => playerRow(sorted[i]),
              separatorBuilder: (context, i) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
            ),
          ),
        ],
      ),
    );
  }
}
