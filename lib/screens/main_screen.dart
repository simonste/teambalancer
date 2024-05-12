import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/dialog/confirm_dialog.dart';
import 'package:teambalancer/dialog/create_team_dialog.dart';
import 'package:teambalancer/screens/shuffle_screen.dart';
import 'package:teambalancer/screens/team_screen.dart';
import 'package:teambalancer/data/data.dart';

class MainScreen extends StatefulWidget {
  final String addTeamKey;

  const MainScreen(this.addTeamKey, {super.key});

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
    final teams = data.get().teams;
    return Scaffold(
      appBar: AppBar(
          title: Text(context.l10n.appName),
          leading: const Image(image: AssetImage("assets/ICON-1.png"))),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final sorted = teams.keys.toList()..sort();
          final name = sorted[index];
          return Card(
            child: ListTile(
              title: Text(name),
              leading: getSportIcon(Sport.values[teams[name]!.sport]),
              trailing: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => navigateTo(
                    context,
                    TeamScreen(
                      teamName: name,
                      data: data,
                    )),
              ),
              onTap: () {
                navigateTo(
                    context,
                    ShuffleScreen(
                      teamName: name,
                      data: data,
                    ));
              },
              onLongPress: () => dialog(
                  TeamDialogData(name, Sport.values[teams[name]!.sport])),
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
          if (data.isAdmin(defaultData.name)) {
            await confirmDialog(
                context: context,
                title: context.l10n.deleteTeam(defaultData.name),
                subtitle: context.l10n.deleteTeamAdmin,
                actions: [
                  DialogAction(
                      text: context.l10n.ok,
                      action: () async {
                        await data.removeTeam(defaultData.name, admin: true);
                        setState(() {});
                      })
                ]);
          } else {
            setState(() {
              data.removeTeam(defaultData.name);
            });
          }
        },
      );
    } else {
      input = await createTeamDialog(context,
          title: context.l10n.createTeam, hintText: context.l10n.teamName);
    }
    if (input == null) return; // empty name not allowed
    if (defaultData != null) {
      data.renameTeam(defaultData.name, input.name, input.sport);
    } else {
      await data.addTeam(input.name, input.sport);
    }
    setState(() {});
  }
}
