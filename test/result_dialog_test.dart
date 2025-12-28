import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/dialog/result_dialog.dart';
import 'package:numberpicker/numberpicker.dart';

class InputWrap<T> {
  T? value;
}

class TestApp extends MaterialApp {
  TestApp({super.key, child})
      : super(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) =>
                supportedLocales.first,
            home: Material(child: child));
}

NumberPicker getNumberPicker(Key key) {
  return find.byKey(key).evaluate().single.widget as NumberPicker;
}

extension DialogHelper on WidgetTester {
  Future<void> scrollNumberPicker(Key key, int scrollTo) async {
    final picker = getNumberPicker(key);
    final center = getCenter(find.byKey(key));
    final offsetY = (picker.value - scrollTo) * picker.itemHeight;
    final TestGesture testGesture = await startGesture(center);
    await testGesture.moveBy(Offset(0.0, offsetY));
    await pump();

    expect(getNumberPicker(key).value, scrollTo);
  }

  Future<InputWrap> openDialog(
      {required int noOfGroups, String result = ""}) async {
    var dialogResult = InputWrap();
    await pumpWidget(TestApp(child: Builder(builder: (BuildContext context) {
      return Scaffold(
          body: Center(
        child: InkWell(
          child: const Text('Foo'),
          onTap: () async {
            dialogResult.value = await resultDialog(context,
                noOfGroups: noOfGroups, result: result);
          },
        ),
      ));
    })));

    await tap(find.text('Foo'));
    await pump();
    return dialogResult;
  }
}

void main() {
  testWidgets('2 groups', (WidgetTester tester) async {
    var dialogInput = await tester.openDialog(noOfGroups: 2);

    await tester.scrollNumberPicker(const Key('picker_0'), 3);
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    expect(dialogInput.value, "3:0");
  });

  testWidgets('3 groups', (WidgetTester tester) async {
    var dialogInput = await tester.openDialog(noOfGroups: 3);

    await tester.scrollNumberPicker(const Key('picker_0'), 4);
    await tester.scrollNumberPicker(const Key('picker_2'), 2);
    await tester.scrollNumberPicker(const Key('picker_1'), 3);
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    expect(dialogInput.value, "4:3:2");
  });

  testWidgets('2 groups cancel', (WidgetTester tester) async {
    var dialogInput = await tester.openDialog(noOfGroups: 2);

    await tester.scrollNumberPicker(const Key('picker_0'), 3);
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    expect(dialogInput.value, null);
  });

  testWidgets('2 groups - edit', (WidgetTester tester) async {
    var dialogInput = await tester.openDialog(noOfGroups: 2, result: "4:2");

    getNumberPicker(const Key('picker_0')).value == 4;
    getNumberPicker(const Key('picker_1')).value == 2;

    await tester.scrollNumberPicker(const Key('picker_1'), 9);
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    expect(dialogInput.value, "4:9");
  });
}
