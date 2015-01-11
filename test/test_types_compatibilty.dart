import 'package:binary_types/binary_types.dart';
import 'package:unittest/unittest.dart';

final _t = new BinaryTypes();

void main() {
  // TODO: Test functions compatibilties
  // TODO: Test structures compatibilties
  var x = _t.short_t.compatible(_t.unsigned_short_t, true);
  group("Binary types compatibilties.", () {
    test("Arrays types.", () {
      _compare(_t.char_t.array(1), _t.signed_char_t.array(1), false, true);
      _compare(_t.char_t.array(1), _t.signed_char_t.array(2), false, false);
      _compare(_t.char_t.array(1).array(1), _t.signed_char_t.array(1).array(1), false, true);
      _compare(_t.char_t.array(1).array(1), _t.signed_char_t.array(1).array(2), false, false);
    });

    test("Pointer types.", () {
      _compare(_t.char_t.ptr(), _t.signed_char_t.ptr(), false, true);
      _compare(_t.char_t.ptr().ptr(), _t.signed_char_t.ptr(), false, false);
      _compare(_t.char_t.ptr().ptr(), _t.signed_char_t.ptr().ptr(), false, true);
    });

    test("Floating points types.", () {
      _compare(_t.float_t, _t.float_t, true, true);
      _compare(_t.double_t, _t.float_t, false, false);
    });

    test("Integer types.", () {
      // Compatible
      _compare(_t.char_t, _t.signed_char_t, false, true);
      _compare(_t.char_t, _t.unsigned_char_t, false, true);
      _compare(_t.signed_char_t, _t.unsigned_char_t, false, true);
      _compare(_t.short_t, _t.unsigned_short_t, false, true);
      _compare(_t.int_t, _t.unsigned_int_t, false, true);
      _compare(_t.long_t, _t.unsigned_long_t, false, true);
      _compare(_t.long_long_t, _t.unsigned_long_long_t, false, true);

      // Incompatible type
      _compare(_t.char_t, _t.short_t, false, false);
      _compare(_t.char_t, _t.unsigned_short_t, false, false);
      _compare(_t.char_t, _t.int_t, false, false);
      _compare(_t.char_t, _t.unsigned_int_t, false, false);
      _compare(_t.char_t, _t.int_t, false, false);
      _compare(_t.char_t, _t.unsigned_int_t, false, false);
      _compare(_t.char_t, _t.long_t, false, false);
      _compare(_t.char_t, _t.unsigned_long_t, false, false);
      _compare(_t.char_t, _t.long_long_t, false, false);
      _compare(_t.char_t, _t.unsigned_long_long_t, false, false);

      _compare(_t.signed_char_t, _t.short_t, false, false);
      _compare(_t.signed_char_t, _t.unsigned_short_t, false, false);
      _compare(_t.signed_char_t, _t.int_t, false, false);
      _compare(_t.signed_char_t, _t.unsigned_int_t, false, false);
      _compare(_t.signed_char_t, _t.int_t, false, false);
      _compare(_t.signed_char_t, _t.unsigned_int_t, false, false);
      _compare(_t.signed_char_t, _t.long_t, false, false);
      _compare(_t.signed_char_t, _t.unsigned_long_t, false, false);
      _compare(_t.signed_char_t, _t.long_long_t, false, false);
      _compare(_t.signed_char_t, _t.unsigned_long_long_t, false, false);

      _compare(_t.unsigned_char_t, _t.short_t, false, false);
      _compare(_t.unsigned_char_t, _t.unsigned_short_t, false, false);
      _compare(_t.unsigned_char_t, _t.int_t, false, false);
      _compare(_t.unsigned_char_t, _t.unsigned_int_t, false, false);
      _compare(_t.unsigned_char_t, _t.int_t, false, false);
      _compare(_t.unsigned_char_t, _t.unsigned_int_t, false, false);
      _compare(_t.unsigned_char_t, _t.long_t, false, false);
      _compare(_t.unsigned_char_t, _t.unsigned_long_t, false, false);
      _compare(_t.unsigned_char_t, _t.long_long_t, false, false);
      _compare(_t.unsigned_char_t, _t.unsigned_long_long_t, false, false);

      _compare(_t.short_t, _t.int_t, false, false);
      _compare(_t.short_t, _t.unsigned_int_t, false, false);
      _compare(_t.short_t, _t.long_t, false, false);
      _compare(_t.short_t, _t.unsigned_long_t, false, false);
      _compare(_t.short_t, _t.long_long_t, false, false);
      _compare(_t.short_t, _t.unsigned_long_long_t, false, false);

      _compare(_t.unsigned_short_t, _t.int_t, false, false);
      _compare(_t.unsigned_short_t, _t.unsigned_int_t, false, false);
      _compare(_t.unsigned_short_t, _t.long_t, false, false);
      _compare(_t.unsigned_short_t, _t.unsigned_long_t, false, false);
      _compare(_t.unsigned_short_t, _t.long_long_t, false, false);
      _compare(_t.unsigned_short_t, _t.unsigned_long_long_t, false, false);

      _compare(_t.int_t, _t.long_t, false, false);
      _compare(_t.int_t, _t.unsigned_long_t, false, false);
      _compare(_t.int_t, _t.long_long_t, false, false);
      _compare(_t.int_t, _t.unsigned_long_long_t, false, false);

      _compare(_t.unsigned_int_t, _t.long_t, false, false);
      _compare(_t.unsigned_int_t, _t.unsigned_long_t, false, false);
      _compare(_t.unsigned_int_t, _t.long_long_t, false, false);
      _compare(_t.unsigned_int_t, _t.unsigned_long_long_t, false, false);

      _compare(_t.long_t, _t.long_long_t, false, false);
      _compare(_t.long_t, _t.unsigned_long_long_t, false, false);

      _compare(_t.unsigned_long_t, _t.long_long_t, false, false);
      _compare(_t.unsigned_long_t, _t.unsigned_long_long_t, false, false);
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
