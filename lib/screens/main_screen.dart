import 'package:flutter/material.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/dialog/create_team_dialog.dart';
import 'package:teambalancer/screens/shuffle_screen.dart';
import 'package:teambalancer/screens/team_screen.dart';
import 'package:teambalancer/data/data.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Data data = Data();

  @override
  void initState() {
    super.initState();

    data.restoreData(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final teams = data.get().teams;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appName)),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final sorted = teams.keys.toList()..sort();
          final name = sorted[index];
          return Card(
            child: ListTile(
              title: Text(name),
              leading: getSportIcon(data.get().teams[name]!.sport),
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
              onLongPress: () =>
                  dialog(TeamDialogData(name, data.get().teams[name]!.sport)),
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
        deleteFunction: () {
          data.get().teams.remove(defaultData.name);
          data.save();
          setState(() {});
        },
      );
    } else {
      input = await createTeamDialog(context,
          title: context.l10n.createTeam, hintText: context.l10n.teamName);
    }
    if (input == null) return; // empty name not allowed
    if (defaultData != null) {
      data.get().teams[defaultData.name]!.sport = input.sport;
      if (!data.get().teams.containsKey(input.name)) {
        data.get().teams[input.name] = data.get().teams[defaultData.name]!;
        data.get().teams.remove(defaultData.name);
      }
    } else {
      data.get().teams[input.name] = TeamData.init(input.sport, []);
    }
    data.save();
    setState(() {});
  }
}
