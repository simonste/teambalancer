import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/dialog/confirm_dialog.dart';
import 'package:teambalancer/dialog/create_team_dialog.dart';
import 'package:teambalancer/screens/history_screen.dart';
import 'package:teambalancer/screens/shuffle_screen.dart';
import 'package:teambalancer/screens/team_screen.dart';
import 'package:teambalancer/widgets/scaffold_with_hiding_fab.dart';
import 'package:teambalancer/data/data.dart';
import 'dart:developer' as developer;

class MainScreen extends StatefulWidget {
  final TeamKey? addTeamKey;

  const MainScreen({this.addTeamKey, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Data data = Data();

  @override
  void initState() {
    super.initState();

    data.restoreData(
        updateCallback: () {
          setState(() {});
        },
        addTeamKey: widget.addTeamKey);
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = data.get().getKeysSortedByName();
    developer.log('build main screen ${sortedKeys.length} teams',
        name: 'teambalancer data');
    return ScaffoldWithHidingFab(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        leading: SvgPicture.asset(
          "assets/ICON.svg",
          width: 24,
          colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary, BlendMode.srcIn),
        ),
      ),
      body: ListView.builder(
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final teamKey = sortedKeys[index];
          final team = data.get().team(teamKey);
          final isAdmin = data.isAdmin(teamKey);
          final name = team.name;
          return Card(
            child: ListTile(
              title: Text(name),
              leading: getSportIcon(Sport.values[team.sport],
                  color: Theme.of(context).iconTheme.color),
              subtitle: SizedBox(
                  width: 300,
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      onPressed: () => navigateTo(
                          context,
                          ShuffleScreen(
                            teamKey: teamKey,
                            data: data,
                          )),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () => navigateTo(
                          context,
                          HistoryScreen(
                            teamData: data.data.team(teamKey),
                            isAdmin: isAdmin,
                          )),
                    ),
                    IconButton(
                      icon: Icon(isAdmin ? Icons.settings : Icons.info_outline),
                      onPressed: () => navigateTo(
                          context,
                          TeamScreen(
                            teamKey: teamKey,
                            data: data,
                          )),
                    ),
                    IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          Share.share(
                              'https://teambalancer.simonste.ch/#${team.teamKey}');
                        })
                  ])),
              onTap: () {
                navigateTo(
                    context,
                    ShuffleScreen(
                      teamKey: teamKey,
                      data: data,
                    ));
              },
              onLongPress: isAdmin
                  ? () => dialog(
                      TeamDialogData(name, Sport.values[team.sport], teamKey))
                  : () => confirmDialog(
                          context: context,
                          title: context.l10n.deleteTeam(name),
                          subtitle: "",
                          actions: [
                            DialogAction(
                                text: context.l10n.ok,
                                action: () async {
                                  await data.removeTeam(teamKey, admin: true);
                                  setState(() {});
                                })
                          ]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => dialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void dialog(TeamDialogData? defaultData) async {
    TeamDialogData? input;
    if (defaultData != null) {
      input = await createTeamDialog(
        context,
        title: context.l10n.teamName,
        defaultData: defaultData,
        deleteFunction: () async {
          if (data.isAdmin(defaultData.key)) {
            await confirmDialog(
                context: context,
                title: context.l10n.deleteTeam(defaultData.name),
                subtitle: context.l10n.deleteTeamAdmin,
                actions: [
                  DialogAction(
                      text: context.l10n.deleteForAll,
                      action: () async {
                        await data.removeTeam(defaultData.key, admin: true);
                        setState(() {});
                      }),
                  DialogAction(
                      text: context.l10n.deleteForMe,
                      action: () async {
                        await data.removeTeam(defaultData.key);
                        setState(() {});
                      })
                ]);
          } else {
            await data.removeTeam(defaultData.key);
            setState(() {});
          }
        },
      );
    } else {
      input = await createTeamDialog(context,
          title: context.l10n.createTeam, hintText: context.l10n.teamName);
    }
    if (input == null) return; // empty name not allowed
    if (defaultData != null) {
      data.renameTeam(defaultData.key, input.name, input.sport);
    } else {
      await data.addTeam(input.name, input.sport);
    }
    setState(() {});
  }
}
