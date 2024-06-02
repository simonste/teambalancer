import 'package:flutter/material.dart';
import 'package:flutter_svg_test/flutter_svg_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/main.dart' as app;

String? text(Key key, {int? elementNo}) {
  var elements = find.byKey(key).evaluate();
  Text textWidget;
  if (elementNo == null) {
    textWidget = elements.single.widget as Text;
  } else {
    textWidget = elements.elementAt(elementNo).widget as Text;
  }
  return textWidget.data;
}

extension AppHelper on WidgetTester {
  Future<void> launchApp() async {
    app.main();
    // pump three times to assure android app is launched
    await pumpAndSettle();
    await pumpAndSettle();
    await pumpAndSettle();
  }

  Future<void> slideTo(Skill skill, int value) async {
    final slider = find.byKey(Key(skill.name));
    final prefSlider = slider.evaluate().single.widget as Slider;
    const sliderPadding = 24;
    final totalWidth = getSize(slider).width - 2 * sliderPadding;
    final range = prefSlider.max - prefSlider.min;
    final distancePerIncrement = (totalWidth / range);
    final ticksFromCenter = prefSlider.value - prefSlider.min - (range / 2);
    final currentOffsetFromCenter = ticksFromCenter * distancePerIncrement;
    final sliderPos = getCenter(slider) + Offset(currentOffsetFromCenter, 0);
    final slideTicks = value - prefSlider.value;
    final offsetFromCurrent = slideTicks * distancePerIncrement;
    // overshoot seems to be necessary
    final overshoot = offsetFromCurrent.sign * 0.1 * distancePerIncrement;
    await dragFrom(sliderPos, Offset(offsetFromCurrent + overshoot, 0));
    await pumpAndSettle();
    expect((slider.evaluate().single.widget as Slider).value, value);
  }

  Future<void> addTeam(String teamName, Sport sport) async {
    await tap(find.byType(FloatingActionButton));
    await pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await enterText(find.byType(TextField), teamName);
    await tap(find.svgAssetWithPath(getAsset(sport)));
    await pump();
    await tap(find.text('Ok'));
    await pumpAndSettle();
  }

  Future<void> deleteTeam(String teamName) async {
    await longPress(find.text(teamName));
    await pumpAndSettle();
    await tap(find.byIcon(Icons.delete));
    await pumpAndSettle();
    await tap(find.text('Ok'));
    await pumpAndSettle();
  }

  Future<void> addPlayer(String playerName) async {
    await tap(find.byType(FloatingActionButton));
    await pumpAndSettle();
    await enterText(find.byType(TextField), playerName);
    await pump();
    await tap(find.text('Ok'));
    await pumpAndSettle();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  });

  testWidgets('create team', (tester) async {
    await tester.launchApp();

    await tester.addTeam("Team", Sport.floorball);

    expect(find.svgAssetWithPath(getAsset(Sport.floorball)), findsOneWidget);
    expect(find.text("Team"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.addPlayer("Player one");
    await tester.addPlayer("Player two");
    await tester.addPlayer("Player three");
    await tester.addPlayer("Player four");

    await tester.tap(find.text("Player one"));
    await tester.pumpAndSettle();

    await tester.tap(find.svgAssetWithPath(getAsset(Tactics.defense)));
    await tester.slideTo(Skill.physical, 4);
    await tester.slideTo(Skill.technical, 1);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();

    expect(find.svgAssetWithPath(getAsset(Tactics.defense)), findsOneWidget);

    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Team"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Player three"));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text("Group 1"), findsOneWidget);
    expect(find.text("Player three"), findsNothing);

    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();
    await tester.deleteTeam("Team");

    expect(find.text("Team"), findsNothing);
  });
}
