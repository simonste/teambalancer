// Runs all integration tests in one app build, which is much faster on CI
// than `flutter test integration_test` with one build per file:
//   flutter test integration_test/all_tests.dart
//
// The screenshot test is left out, `flutter drive` runs it separately.
// Without the `_test.dart` suffix `flutter test integration_test` does not
// run the tests twice.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'admin_test.dart' as admin_test;
import 'deep_link_test.dart' as deep_link_test;
import 'overall_test.dart' as overall_test;
import 'user_test.dart' as user_test;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('overall', overall_test.main);
  group('user', user_test.main);
  group('admin', admin_test.main);
  group('deep link', deep_link_test.main);
}
