import 'package:binary_types/binary_types.dart';
import 'package:unittest/unittest.dart';

final _t = new BinaryTypes();

void main() {
  // TODO: Test functions compatibilties
  // TODO: Test structures compatibilties
  group("Binary types compatibilties.", () {
    test("Arrays types.", () {
      _compare(_t["char"].array(1), _t["signed char"].array(1), false, true);
      _compare(_t["char"].array(1), _t["signed char"].array(2), false, false);
      _compare(_t["char"].array(1).array(1), _t["signed char"].array(1).array(1), false, true);
      _compare(_t["char"].array(1).array(1), _t["signed char"].array(1).array(2), false, false);
    });

    test("Pointer types.", () {
      _compare(_t["char"].ptr(), _t["signed char"].ptr(), false, true);
      _compare(_t["char"].ptr().ptr(), _t["signed char"].ptr(), false, false);
      _compare(_t["char"].ptr().ptr(), _t["signed char"].ptr().ptr(), false, true);
    });

    test("Floating points types.", () {
      _compare(_t["float"], _t["float"], true, true);
      _compare(_t["double"], _t["float"], false, false);
    });

    test("Integer types.", () {
      // Compatible
      _compare(_t["char"], _t["signed char"], false, true);
      _compare(_t["char"], _t["unsigned char"], false, true);
      _compare(_t["signed char"], _t["unsigned char"], false, true);
      _compare(_t["short"], _t["unsigned short"], false, true);
      _compare(_t["int"], _t["unsigned int"], false, true);
      _compare(_t["long"], _t["unsigned long"], false, true);
      _compare(_t["long long"], _t["unsigned long long"], false, true);

      // Incompatible type
      _compare(_t["char"], _t["short"], false, false);
      _compare(_t["char"], _t["unsigned short"], false, false);
      _compare(_t["char"], _t["int"], false, false);
      _compare(_t["char"], _t["unsigned int"], false, false);
      _compare(_t["char"], _t["int"], false, false);
      _compare(_t["char"], _t["unsigned int"], false, false);
      _compare(_t["char"], _t["long"], false, false);
      _compare(_t["char"], _t["unsigned long"], false, false);
      _compare(_t["char"], _t["long long"], false, false);
      _compare(_t["char"], _t["unsigned long long"], false, false);

      _compare(_t["signed char"], _t["short"], false, false);
      _compare(_t["signed char"], _t["unsigned short"], false, false);
      _compare(_t["signed char"], _t["int"], false, false);
      _compare(_t["signed char"], _t["unsigned int"], false, false);
      _compare(_t["signed char"], _t["int"], false, false);
      _compare(_t["signed char"], _t["unsigned int"], false, false);
      _compare(_t["signed char"], _t["long"], false, false);
      _compare(_t["signed char"], _t["unsigned long"], false, false);
      _compare(_t["signed char"], _t["long long"], false, false);
      _compare(_t["signed char"], _t["unsigned long long"], false, false);

      _compare(_t["unsigned char"], _t["short"], false, false);
      _compare(_t["unsigned char"], _t["unsigned short"], false, false);
      _compare(_t["unsigned char"], _t["int"], false, false);
      _compare(_t["unsigned char"], _t["unsigned int"], false, false);
      _compare(_t["unsigned char"], _t["int"], false, false);
      _compare(_t["unsigned char"], _t["unsigned int"], false, false);
      _compare(_t["unsigned char"], _t["long"], false, false);
      _compare(_t["unsigned char"], _t["unsigned long"], false, false);
      _compare(_t["unsigned char"], _t["long long"], false, false);
      _compare(_t["unsigned char"], _t["unsigned long long"], false, false);

      _compare(_t["short"], _t["int"], false, false);
      _compare(_t["short"], _t["unsigned int"], false, false);
      _compare(_t["short"], _t["long"], false, false);
      _compare(_t["short"], _t["unsigned long"], false, false);
      _compare(_t["short"], _t["long long"], false, false);
      _compare(_t["short"], _t["unsigned long long"], false, false);

      _compare(_t["unsigned short"], _t["int"], false, false);
      _compare(_t["unsigned short"], _t["unsigned int"], false, false);
      _compare(_t["unsigned short"], _t["long"], false, false);
      _compare(_t["unsigned short"], _t["unsigned long"], false, false);
      _compare(_t["unsigned short"], _t["long long"], false, false);
      _compare(_t["unsigned short"], _t["unsigned long long"], false, false);

      _compare(_t["int"], _t["long"], false, false);
      _compare(_t["int"], _t["unsigned long"], false, false);
      _compare(_t["int"], _t["long long"], false, false);
      _compare(_t["int"], _t["unsigned long long"], false, false);

      _compare(_t["unsigned int"], _t["long"], false, false);
      _compare(_t["unsigned int"], _t["unsigned long"], false, false);
      _compare(_t["unsigned int"], _t["long long"], false, false);
      _compare(_t["unsigned int"], _t["unsigned long long"], false, false);

      _compare(_t["long"], _t["long long"], false, false);
      _compare(_t["long"], _t["unsigned long long"], false, false);

      _compare(_t["unsigned long"], _t["long long"], false, false);
      _compare(_t["unsigned long"], _t["unsigned long long"], false, false);
    });
  });
}

void _compare(BinaryType t1, BinaryType t2, bool strong, bool acceptable) {
  expect(t1 == t1, true, reason: "$t1 == $t1");
  expect(t1 == t2, strong, reason: "$t1 == $t2");
  expect(t2 == t1, strong, reason: "$t2 == $t1");
  expect(t1.compatible(t1, false), true, reason: "$t1 and $t1 compatible");
  expect(t2.compatible(t1, false), acceptable, reason: "$t2 and $t1 compatible");
  expect(t1.compatible(t2, false), acceptable, reason: "$t1 and $t2 compatible");
}
