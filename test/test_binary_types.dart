import 'package:binary_types/binary_types.dart';
import 'package:unittest/unittest.dart';

void main() {
  var test = new Test();
  test.testAlloc();
  test.testArrays();
  test.testCommon();
  test.testCStrings();
  test.testFloats();
  test.testFunctions();
  test.testIntegers();
  test.testPointers();
  test.testStructs();
  print('Done');
}

class Test {
  BinaryTypeHelper helper;

  BinaryTypes types;

  Test() {
    types = new BinaryTypes();
    helper = new BinaryTypeHelper(types);
  }

  void testAlloc() {
    group("Memory allocation.", () {
      test("Memory allocation through binary array.", () {
        var size = 10;
        var ia = helper.alloc("int[$size]", []);
        Expect.isTrue(ia.value.length == size, 'ia.value.length == $size');
      });
    });
  }

  void testArrays() {
    group("Binary arrays.", () {
      test("Access binary data through binary arrays.", () {
        var size = 1000;
        // int ia[1000] = {0};
        var ia = types['int'].array(size).alloc([]);
        for (int index = 0; index < size; index++) {
          // ia[index] = index;
          ia[index].value = index;
        }

        for (int index = 0; index < size; index++) {
          // ia[index] == index;
          Expect.isTrue(ia[index].value == index, 'ia[$index].value == $index');
        }

        for (int index = 0; index < size; index++) {
          // TODO: comparing int
          // Expect.isTrue(ia[index] == ia[index], 'ia[$index] == ia[$index]');
        }

        var list = ia.value;
        for (int index = 0; index < size; index++) {
          Expect.isTrue(list[index] == index, 'list[$index] == $index');
        }

        // Set content
        for (int index = 0; index < size; index++) {
          // ia[index] = ia[index];
          ia[index] = ia[index];
        }
      });
    });
  }

  void testCommon() {
    group("Common operations.", () {
      test("Access data through binary integer and struct types.", () {
        // int8_t int8 = -8;
        final int8 = types['int8_t'].alloc(-8);
        // int16_t int16 = -16;
        final int16 = types['int16_t'].alloc(-16);
        // int32_t int32 = -32;
        final int32 = types['int32_t'].alloc(-32);
        // int64_t int64 = -64;
        final int64 = types['int64_t'].alloc(-64);
        // uint8_t uint8 = 8;
        final uint8 = types['uint8_t'].alloc(8);
        // uint16_t uint16 = 16;
        final uint16 = types['uint16_t'].alloc(16);
        // uint32_t uint32 = 32;
        final uint32 = types['uint32_t'].alloc(32);
        // uint64_t uint64 = 64;
        final uint64 = types['uint64_t'].alloc(64);
        // int* ip = &int32;
        final ip = types['int*'].alloc(int32.location);

        // struct {
        //   int8_t int8;
        //   int16_t int16;
        //   int32_t int32;
        //   int64_t int64;
        //   uint8_t uint8;
        //   uint16_t uint16;
        //   uint32_t uint32;
        //   uint64_t uint64;
        //   int* ip;
        //   void* vp;
        // };
        var struct_t = helper.declareStruct(null, {
          'int8': types['int8_t'],
          'int16': types['int16_t'],
          'int32': types['int32_t'],
          'int64': types['int64_t'],
          'uint8': types['uint8_t'],
          'uint16': types['uint16_t'],
          'uint32': types['uint32_t'],
          'uint64': types['uint64_t'],
          'ip': types['int*'],
          'vp': types['void*']
        });

        // struct {
        //   int8_t int8;
        //   int16_t int16;
        //   int32_t int32;
        //   int64_t int64;
        //   uint8_t uint8;
        //   uint16_t uint16;
        //   uint32_t uint32;
        //   uint64_t uint64;
        //   int* ip;
        //   void* vp;
        // } s1;
        final s1 = struct_t.alloc();
        // Set content
        // s1.int8 = int8;
        s1['int8'] = int8;
        // s1.int16 = int16;
        s1['int16'] = int16;
        // s1.int32 = int32;
        s1['int32'] = int32;
        // s1.int64 = int64;
        s1['int64'] = int64;
        // s1.uint8 = uint8;
        s1['uint8'] = uint8;
        // s1.uint16 = uint16;
        s1['uint16'] = uint16;
        // s1.uint32 = uint32;
        s1['uint32'] = uint32;
        // s1.uint64 = uint64;
        s1['uint64'] = uint64;
        // s1.ip = ip;
        s1['ip'] = ip;
        // s1.vp = ip;
        s1['vp'] = ip;

        Expect.equals(s1['int8'].value, int8.value, 's1.int8 = int8');
        Expect.equals(s1['int16'].value, int16.value, 's1.int16 == int16');
        Expect.equals(s1['int32'].value, int32.value, 's1.int32 == int32');
        Expect.equals(s1['int64'].value, int64.value, 's1.int64 == int64');
        Expect.equals(s1['uint8'].value, uint8.value, 's1.uint8 == uint8');
        Expect.equals(s1['uint16'].value, uint16.value, 's1.uint16 == uint16');
        Expect.equals(s1['uint32'].value, uint32.value, 's1.uint32 == uint32');
        Expect.equals(s1['uint64'].value, uint64.value, 's1.uint64 == uint64');
        Expect.equals(s1['uint64'].value, uint64.value, 's1.uint64 == uint64');
        Expect.equals(s1['ip'][0].value, int32.value, '*s1.int32 == int32');
        // TODO: comparing
        //Expect.equals(s1['ip'], ip, 's1.ip == ip');
        //Expect.equals(s1['vp'], ip, 's1.vp == ip');
        //Expect.equals(s1['ip'], int32.location, 's1.ip = int32');
      });
    });
  }

  void testCStrings() {
    group("'C' string binary types.", () {
      test("Access data through 'C' string binary types.", () {
        var testString = "Hello";
        var codeUnits = testString.codeUnits;
        final ca = helper.allocString(testString);
        var length = testString.length;
        for (var i = 0; i < length; i++) {
          // ca[i]
          var c = ca[i].value;
          Expect.isTrue(c == codeUnits[i], "ca[$i]");
        }

        Expect.isTrue(ca[length].value == 0, "*ca[length] == 0;");

        //
        var strFromMemory = helper.readString(ca.location);
        Expect.isTrue(strFromMemory == testString, "testString == strFromMemory;");
      });
    });
  }

  void testFloats() {
    group("Floating point binary types.", () {
      test("Access data through binary float and double types.", () {
        // float float1 = 0;
        final float1 = types['float'].alloc(0);
        // double double1 = 0;
        final double1 = types['double'].alloc(0);
        double zero = 0.0;

        Expect.equals(float1.value, zero, 'float1 = 0');
        Expect.equals(double1.value, zero, 'float1 = 0');
        Expect.isTrue(float1.value is double, 'float1.value is double');
        Expect.isTrue(double1.value is double, 'double.value is double');

        // float1 = 1.7976931348623157e+308;
        float1.value = 1.7976931348623157e+308;
        // double1 = 1.7976931348623157e+308;
        double1.value = 1.7976931348623157e+308;

        Expect.equals(double.INFINITY, float1.value, 'float1 == Infinity');
        Expect.equals(1.7976931348623157e+308, double1.value, 'double1 == 1.7976931348623157e+308');

        // float1 = 4.9406564584124654e-324;
        float1.value = 4.9406564584124654e-324;
        // double1 = 4.9406564584124654e-324;
        double1.value = 4.9406564584124654e-324;

        Expect.equals(0.0, float1.value, 'float1 == Infinity');
        Expect.equals(4.9406564584124654e-324, double1.value, 'double1 == 4.9406564584124654e-324');

        // float1 = 555;
        float1.value = 555;
        // double1 = 555;
        double1.value = 555;

        Expect.equals(555, float1.value, 'float1 == 555');
        Expect.equals(555, double1.value, 'double1 == 555');

        final uint64 = types['uint64_t'].alloc(18446744073709551615);
        double1.value = uint64.value;
        double1.value += 10000;
        uint64.value = double1.value;
        // ...
      });
    });
  }

  void testFunctions() {
    group("Function declarations.", () {
      test("Arity of declared functions.", () {
        // char* ()(char*)
        var func_t = helper.declareFunc(types['char*'], [types['char*']]);
        // char* ()(...)
        var func_va_args_t = helper.declareFunc(types['char*'], [types['int'], types['...']]);

        Expect.equals(func_t.arity, 1, 'func_t.arity == 1');
        Expect.equals(func_va_args_t.arity, 1, 'func_va_args_t.arity == 1');

        Expect.equals(func_t.variadic, false, 'func_t.variadic == false');
        Expect.equals(func_va_args_t.variadic, true, 'func_va_args_t.variadic == 1');
      });
    });
  }

  void testIntegers() {
    group("Integer binary types.", () {
      test("Access data through different binary integer types.", () {
        // uint64_t uint64 = -1;
        final uint64 = types['uint64_t'].alloc(-1);
        Expect.equals(18446744073709551615, uint64.value, 'uint64_t i = -1; must be 18446744073709551615');

        // int64_t int64 = uint64;
        final int64 = types['int64_t'].alloc(uint64.value);
        Expect.equals(-1, int64.value, 'int64_t i = 18446744073709551615; must be -1');

        // uint32_t uint32 = -1;
        final uint32 = types['uint32_t'].alloc(-1);
        Expect.equals(4294967295, uint32.value, 'uint32_t i = -1; must be 4294967295');

        // int32_t int32 = uint32;
        final int32 = types['int32_t'].alloc(uint32.value);
        Expect.equals(-1, int32.value, 'int32_t i = 4294967295; must be -1');

        // uint16_t uint16 = -1;
        final uint16 = types['uint16_t'].alloc(-1);
        Expect.equals(65535, uint16.value, 'uint16_t i = -1; must be 65535');

        // int16_t int16 = uint16;
        final int16 = types['int16_t'].alloc(uint16.value);
        Expect.equals(-1, int16.value, 'int16_t i = 65535; must be -1');

        // uint8_t uint8 = -1;
        final uint8 = types['uint8_t'].alloc(-1);
        Expect.equals(255, uint8.value, 'uint8_t i = -1; must be 255');

        // int8_t int8 = uint8;
        final int8 = types['int8_t'].alloc(uint8.value);
        Expect.equals(-1, int8.value, 'int8_t i = 255; must be -1');

        var val = 1311768467294899695; // 0x1234567890ABCDEF;

        // uint64 = val;
        uint64.value = val;
        Expect.equals(1311768467294899695, uint64.value, 'uint64_t i = ${val};');

        // int64 = val;
        int64.value = val;
        Expect.equals(1311768467294899695, int64.value, 'uint64_t i = ${val};');

        // uint32 = val;
        uint32.value = val;
        Expect.equals(2427178479, uint32.value, 'uint32_t i = ${val};');

        // int32 = val;
        int32.value = val;
        Expect.equals(-1867788817, int32.value, 'uint32_t i = ${val};');

        // uint16 = val;
        uint16.value = val;
        Expect.equals(52719, uint16.value, 'uint16_t i = ${val};');

        // int16 = val;
        int16.value = val;
        Expect.equals(-12817, int16.value, 'uint16_t i = ${val};');

        // uint8 = val;
        uint8.value = val;
        Expect.equals(239, uint8.value, 'uint8_t i = ${val};');

        // int8 = val;
        int8.value = val;
        Expect.equals(-17, int8.value, 'uint8_t i = ${val};');
      });

      test("Casting data values of different binary integer types.", () {
        // Casting values
        Expect.equals(-1, types['int8_t'].cast(0xff), '-1 == (int8_t)0xff');
        Expect.equals(-1, types['int16_t'].cast(0xffff), '-1 == (int16_t)0xffff');
        Expect.equals(-1, types['int32_t'].cast(0xffffffff), '-1 == (int32_t)0xffffffff');
        Expect.equals(-1, types['int64_t'].cast(0xffffffffffffffff), '-1 == (int64_t)0xffffffffffffffff');
        Expect.equals(0xff, types['uint8_t'].cast(-1), '0xff == (uint8_t)-1');
        Expect.equals(0xffff, types['uint16_t'].cast(-1), '0xffff == (uint16_t)-1');
        Expect.equals(0xffffffff, types['uint32_t'].cast(-1), '0xffffffff == (uint32_t)-1');
        Expect.equals(0xffffffffffffffff, types['uint64_t'].cast(-1), '0xffffffffffffffff == (uint64_t)-1');
      });
    });
  }

  void testPointers() {
    group("Pointer binary types.", () {
      test("Access data through binary pointer types.", () {
        // int i = 0;
        final i = types['int'].alloc(0);
        // int* ip = &i;
        final ip = types['int'].ptr().alloc(i.location);
        // ip = ip;
        ip.value = ip.value;
        // i = 0;
        i.value = 0;
        // ip = &i;
        ip.value = i.location;

        // ip = (int*)10000000;
        ip.value = ip.type.cast(10000000);
        Expect.isTrue(ip.value.address == 10000000, 'ip == 10000000');

        // i = (int)ip;
        i.value = i.type.cast(ip.value);
        Expect.isTrue(i.value == 10000000, 'i == 10000000;');

        var size = 1000;
        // int ia[1000];
        final ia = types['int'].array(1000).alloc();
        // ip = &ia;
        ip.value = ia.location;
        for (var index = 0; index < size; index++) {
          var value = index;
          // ia[index] = value;
          ia[index].value = value;
          // value = ip[index]
          value = ip[index].value;
          Expect.isTrue(ip[index].value == value, 'ip[index] == ia[index]');
          // Fast way
          // value = ip[index]
          value = ip.getElementValue(index);
          Expect.isTrue(ip[index].value == value, 'ip[index] == ia[index]');
          // ip[index] = value
          ip[index].value = value;
          Expect.isTrue(ip[index].value == value, 'ip[index] == ia[index]');
          // Fast way
          // ip[index] = value
          ip.setElementValue(index, value);
          Expect.isTrue(ip[index].value == value, 'ip[index] == ia[index]');
        }

        // ip = &ia;
        ip.value = ia.location;
        for (var index = 0; index < size; index++) {
          Expect.isTrue(ia[index].value == ip[index].value, 'ia[index] == ip[index]');
          Expect.isTrue(ip[index].value == ia[index].value, 'ip[index] == ia[index]');
        }

        // i = 99;
        i.value = 99;
        // ip = &i;
        ip.value = i.location;
        // int* ipa[size];
        final ipa = types['int'].ptr().array(size).alloc();
        for (var index = 0; index < size; index++) {
          // ipa[index] = ip;
          ipa[index] = ip;
          // TODO: comparing
          //Expect.isTrue(ipa[index][0] == i, '*ipa[index] = i;');
          Expect.isTrue(ipa[index][0].value == i.value, '*ipa[index] = i;');
        }

        //
        var fp = types["float*"].alloc();
        var f = types["float"].alloc(42.0);
        fp[0] = f;

        // i = 0;
        i.value = 0;
        // ip = &i;
        ip.value = i.location;
        // *ip = 3333;
        ip[0].value = 3333;
        Expect.isTrue(ip[0].value == i.value, '*ip[0] = i;');
        Expect.isTrue(ip[0].value == 3333, '*ip[0] = 3333;');

        // void* vp = &i;
        final vp = types['void*'].alloc(i.location);
        // vp = &i;
        vp.value = i.location;
        // vp = ip;
        vp.value = ip.value;
        // ip = (int*)vp;
        ip.value = ip.type.cast(vp.value);
      });

      test("Assign array types to pointer types.", () {
        // TODO:
      });
    });
  }

  void testStructs() {
    // TODO: Add test for union type
    group("Structure binary types.", () {
      test("Access data through binary struct and union types.", () {
        // struct _Point {int x; int y;};
        helper.declareStruct('_Point', {
          'x': types['int'],
          'y': types['int']
        });
        Expect.equals('struct _Point', types['struct _Point'].name, '(struct _Point).name == "struct _Point"');

        // typedef struct _Point POINT;
        types['POINT'] = types['struct _Point'];
        Expect.isTrue(types['POINT'] == types['struct _Point'], 'POINT == struct _Point');

        // typedef struct {int i;} struct1_t;
        types['struct1_t'] = helper.declareStruct(null, {
          'i': types['int']
        });
        // typedef struct {int i;} struct2_t;
        types['struct2_t'] = helper.declareStruct(null, {
          'i': types['int']
        });
        // struct1_t
        var struct1_t = types['struct1_t'];
        // struct2_t
        var struct2_t = types['struct2_t'];
        Expect.isTrue(struct1_t != struct2_t, '${struct1_t} != ${struct2_t}');

        // struct {int i;};
        var struct3_t = helper.declareStruct(null, {
          'i': types['int']
        });
        // typedef struct {int i;} struct4_t;
        types['struct4_t'] = struct3_t;
        // typedef struct {int i;} struct4_t;
        types['struct5_t'] = struct3_t;
        // struct4_t
        var struct4_t = types['struct4_t'];
        // struct5_t
        var struct5_t = types['struct5_t'];
        Expect.isTrue(struct4_t == struct5_t, '${struct4_t} == ${struct5_t}');

        // typedef struct {POINT a; POINT b;} RECT;
        types['RECT'] = helper.declareStruct(null, {
          'a': types['POINT'],
          'b': types['struct _Point']
        });
        // RECT rect1 = {.b = {5, 6}};
        final rect1 = types['RECT'].alloc({
          'b': [5, 6]
        });
        Expect.isTrue(rect1['a']['x'].value == 0, '"rect1.b.x.value == 0');
        Expect.isTrue(rect1['b']['y'].value == 6, '"rect1.b.y.value == 6');

        // = rect1;
        var rect1_val = rect1.value;
        Expect.isTrue(rect1_val['a']['x'] == 0, '"(by val) rect1.b.y == 0');
        Expect.isTrue(rect1_val['b']['y'] == 6, '"(by val) rect1.b.y == 6');

        // typedef struct {int i; int* ip; int ia[10]; POINT pt;} struct6_t;
        types['struct6_t'] = helper.declareStruct(null, {
          'i': types['int'],
          'ip': types['int*'],
          'ia': types['int'].array(10),
          'pt': types['POINT']
        });

        // int i = 55555;
        final i = types['int'].alloc(55555);
        // struct6_t struct6 = {
        //    .i = 12345,
        //    .ip = &.i;
        //    .ia = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}},
        //    .pt = {.x = 1, .y = 2}};
        final struct6 = types['struct6_t'].alloc({
          'i': 12345,
          'ip': i.location,
          'ia': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          'pt': {
            'x': 1,
            'y': 2
          }
        });

        Expect.equals(12345, struct6['i'].value, 'struct6.i == 12345');
        Expect.equals(55555, struct6['ip'][0].value, '*struct6.ip == 55555');
        Expect.equals(6, struct6['ia'][6].value, 'struct6.ia[6] == 6');
        Expect.equals(2, struct6['pt']['y'].value, 'struct6.pt.y == 2');

        // = struct6;
        var map_struct6 = struct6.value; // snapshot of struct6

        Expect.equals(12345, map_struct6['i'], 'struct6.i == 12345');
        Expect.equals(55555, map_struct6['ip'].value, '*struct6.ip == 55555');
        Expect.equals(6, map_struct6['ia'][6], 'struct6.ia[6] == 6');
        Expect.equals(2, map_struct6['pt']['y'], 'struct6.pt.y == 2');

        // RECT rect2 = {.a = {.x = 1, .y = 2}, .b = {.x = 3, .y = 4}};
        final rect2 = types['RECT'].alloc({
          'a': {
            'x': 1,
            'y': 2
          },
          'b': {
            'x': 3,
            'y': 4
          }
        });
        // rect2.a = rect2.b;
        rect2['a'] = rect2['b'];
        Expect.equals(3, rect2['a']['x'].value, 'rect.a.x == 3');
        Expect.equals(4, rect2['a']['y'].value, 'rect.a.x == 4');

        types['struct_inner_t'] = helper.declareStruct(null, {
          'ip': types['int*']
        });
        types['struct_outer_t'] = helper.declareStruct(null, {
          'inner': types['struct_inner_t']
        });
        var outer = types['struct_outer_t'].alloc();
        var outerValue = outer.value;
        var ip = outerValue["inner"]["ip"];

        var members = {};
        members["ia"] = types["int"].array(10);
        var struct7_t = helper.declareStruct(null, null);
        Expect.isTrue(struct7_t.size == 0, "sizeof(struct7_t) == 0");
        struct7_t.addMembers(members);
        Expect.isTrue(struct7_t.size != 0, "sizeof(struct7_t) != 0");

        // Forward reference himself
        var struct8_t = helper.declareStruct("struct8_t", {
          "sp": "struct struct8_t*"
        });
        Expect.isTrue(struct8_t.size != 0, "sizeof(struct8_t) != 0");
      });

      // TODO: Add test of struct packing
    });
  }
}

class Expect {
  static void equals(actual, expected, String reason) {
    expect(actual, expected, reason: reason);
  }

  static void isTrue(actual, String reason) {
    expect(actual, true, reason: reason);
  }
}
