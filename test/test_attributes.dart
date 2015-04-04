import 'package:binary_types/binary_types.dart';
import 'package:unittest/unittest.dart';

void main() {
  group("Attributes", () {
    var t = new BinaryTypes();
    var helper = new BinaryTypeHelper(t);
    helper.addHeaders(HEADERS);
    helper.declare(HEADERS.keys.first);
    test("Enums", () {
      var name = "enum enum0";
      var align = t[name].align;
      expect(align, 16, reason: "Align: $name");

      name = "enum enum1";
      align = t[name].align;
      expect(align, 16, reason: "Align: $name");

      name = "enum enum2";
      align = t[name].align;
      expect(align, 32, reason: "Align: $name");
    });

    test("Typedef enums", () {
      var name = "E0";
      var align = t[name].align;
      expect(align, 16, reason: "Align: ${t[name].typedefName}");

      name = "E1";
      align = t[name].align;
      expect(align, 16, reason: "Align: ${t[name].typedefName}");

      name = "E2";
      align = t[name].align;
      expect(align, 32, reason: "Align: ${t[name].typedefName}");

      name = "E3";
      align = t[name].align;
      expect(align, 64, reason: "Align: ${t[name].typedefName}");

      name = "E4";
      align = t[name].align;
      expect(align, 64, reason: "Align: ${t[name].typedefName}");

      name = "E5";
      align = t[name].align;
      expect(align, 64, reason: "Align: ${t[name].typedefName}");
    });

    test("Struct", () {
      var name = "struct struct0";
      var align = t[name].align;
      var size = t[name].size;
      expect(align, 16, reason: "Align: $name");
      expect(size, 16, reason: "Size: $name");

      name = "struct struct1";
      align = t[name].align;
      size = t[name].size;
      expect(align, 16, reason: "Align: $name");
      expect(size, 16, reason: "Size: $name");

      name = "struct struct2";
      align = t[name].align;
      size = t[name].size;
      expect(align, 32, reason: "Align: $name");
      expect(size, 32, reason: "Size: $name");

      name = "struct struct_with_int";
      align = t[name].align;
      size = t[name].size;
      expect(align, t["int"].align, reason: "Alignof $name");
      expect(size, t["int"].size, reason: "Size: $name");

      name = "struct struct_with_char_and_int";
      align = t[name].align;
      size = t[name].size;
      expect(align, t["int"].align, reason: "Alignof $name");
      expect(size, t["int"].size * 2, reason: "Size: $name");

      name = "struct struct_with_char_and_INT1";
      align = t[name].align;
      size = t[name].size;
      expect(align, 1, reason: "Alignof $name");
      expect(size, t["char"].size + t["INT1"].size, reason: "Size: $name");

      name = "struct s_with_i";
      align = t[name].align;
      size = t[name].size;
      expect(align, t["int"].align, reason: "Alignof $name");
      expect(size, t["int"].size * 2, reason: "Size: $name");

      name = "struct s_with_I";
      align = t[name].align;
      size = t[name].size;
      expect(align, 1, reason: "Alignof $name");
      expect(size, t["char"].size + t["INT1"].size, reason: "Size: $name");

      name = "struct s_with_s";
      align = t[name].align;
      size = t[name].size;
      expect(align, t["struct s"].align, reason: "Alignof $name");
      expect(size, t["struct s"].size * 2, reason: "Size: $name");

      name = "struct s_with_I";
      align = t[name].align;
      size = t[name].size;
      expect(align, 1, reason: "Alignof $name");
      expect(size, t["char"].size + t["struct s"].size, reason: "Size: $name");
    });

    test("Typedef integers, floats", () {
      var name = "INT1";
      var align = t[name].align;
      expect(align, 1, reason: "Align: ${t[name].typedefName}");

      name = "INT2";
      align = t[name].align;
      expect(align, 2, reason: "Align: ${t[name].typedefName}");

      name = "INT16";
      align = t[name].align;
      expect(align, 16, reason: "Align: ${t[name].typedefName}");

      name = "FLOAT1";
      align = t[name].align;
      expect(align, 1, reason: "Align: ${t[name].typedefName}");

      name = "FLOAT2";
      align = t[name].align;
      expect(align, 2, reason: "Align: ${t[name].typedefName}");

      name = "FLOAT16";
      align = t[name].align;
      expect(align, 16, reason: "Align: ${t[name].typedefName}");
    });
  });
}

const Map HEADERS = const {"binary_types/test_attributes/header.h": _header};

const String _header = '''
// align 1
typedef int __attribute__((aligned(1))) INT1 __attribute__((aligned(2)));

// align 2
typedef int __attribute__((aligned(2))) INT2 __attribute__((aligned(1)));

// align 16
typedef int INT16 __attribute__((aligned(16)));

// align 1
typedef float __attribute__((aligned(1))) FLOAT1 __attribute__((aligned(2)));

// align 2
typedef float __attribute__((aligned(2))) FLOAT2 __attribute__((aligned(1)));

// align 16
typedef float FLOAT16 __attribute__((aligned(16)));

// align 16
enum enum0 { A1 } __attribute__((aligned(16)));

// align 16
enum __attribute__((aligned(16))) enum1 { A2 };

// align 32
enum __attribute__((aligned(16))) enum2 { A3 } __attribute__((aligned(32)));

// align 16
typedef enum enum3 { A4 } __attribute__((aligned(16))) E0;

// align 16
typedef enum __attribute__((aligned(16))) enum4 { A5 } E1;

// align 32
typedef enum __attribute__((aligned(16))) enum5 { A6 } __attribute__((aligned(32))) E2;

// align 64
typedef enum enum6 { A7 } __attribute__((aligned(16))) E3 __attribute__((aligned(64)));

// align 64
typedef enum __attribute__((aligned(16))) enum7 { A8 } E4 __attribute__((aligned(64)));

// align 64
typedef enum __attribute__((aligned(16))) enum8 { A9 } __attribute__((aligned(32))) E5 __attribute__((aligned(64)));

// align 16
// size 16
struct struct0 { int i; } __attribute__((aligned(16)));

// align 16
// size 16
struct __attribute__((aligned(16))) struct1 { int i; };

// align 32
// size 32
struct __attribute__((aligned(16))) struct2 { int i; } __attribute__((aligned(32)));

// align 4
// size 4
struct struct_with_int { int i; } __attribute__((aligned(1)));

// align 4
// size 8
struct struct_with_char_and_int { char c; int i; } __attribute__((aligned(1)));

// align 1
// size 5
struct struct_with_char_and_INT1 { char c; INT1 i; } __attribute__((aligned(1)));

struct s {
    int i;
};

typedef struct s S; 

struct s_with_i {
    char  c;
    int i __attribute__((aligned(1)));
};

struct s_with_I {
    char  c;
    INT1 i __attribute__((aligned(1)));
};

struct s_with_s {
    char  c;
    struct s s __attribute__((aligned(1)));
};

struct s_with_S {
    char  c;
    S s __attribute__((aligned(1)));
};

// sizeof (struct s_with_i): 8                                                                                                                                 
// alignof(struct s_with_i): 4                                                                                                                                 
// sizeof (struct s_with_I): 5                                                                                                                                 
// alignof(struct s_with_I): 1                                                                                                                                 
// sizeof (struct s_with_s): 8                                                                                                                                   
// alignof(struct s_with_s): 4                                                                                                                                   
// sizeof (struct s_with_S): 5                                                                                                                                   
// alignof(struct s_with_S): 1

''';
