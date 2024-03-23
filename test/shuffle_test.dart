import 'package:flutter_test/flutter_test.dart';
import 'package:teambalancer/common/shuffle.dart';

void main() {
  test('possible groups', () {
    expect(Shuffle.possibleGroups(4, 1), 1);
    expect(Shuffle.possibleGroups(4, 2), 3);
    expect(Shuffle.possibleGroups(6, 2), 10);
    expect(Shuffle.possibleGroups(6, 3), 15);
    expect(Shuffle.possibleGroups(8, 2), 35);
    expect(Shuffle.possibleGroups(10, 2), 126);
    expect(Shuffle.possibleGroups(12, 2), 462);
    expect(Shuffle.possibleGroups(5, 2), 10);
    expect(Shuffle.possibleGroups(4, 3), 6);
  });
}
