import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teambalancer/common/constants.dart';

import 'overall_test.dart';

bool driverTest = false;

extension AppHelper on WidgetTester {
  Future<void> prepare(IntegrationTestWidgetsFlutterBinding? binding) async {
    await launchApp();
    await binding?.convertFlutterSurfaceToImage();
  }

  Future<void> takeScreenshot(
      IntegrationTestWidgetsFlutterBinding? binding, name) async {
    if (Platform.isAndroid) {
      await pumpAndSettle();
    }
    await pumpAndSettle();
    await binding?.takeScreenshot(name);
    await pumpAndSettle();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding? binding;
  if (driverTest) {
    binding = IntegrationTestWidgetsFlutterBinding();
  } else {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  }

  // remove debug banner for screenshots
  WidgetsApp.debugAllowBannerOverride = false;

  setUp(() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  });

  testWidgets('screenshot', (tester) async {
    await tester.prepare(binding);

    await tester.addTeam("Football team", Sport.football);

    await tester.takeScreenshot(binding, 'screenshot1');
    await tester.pump(const Duration(seconds: 1));
    await tester.deleteTeam("Football team");
  });
}
