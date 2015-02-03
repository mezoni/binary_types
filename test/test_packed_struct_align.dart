import 'package:binary_types/binary_types.dart';
import 'package:unittest/unittest.dart';

/**
 * Based on the following source code.
 * https://github.com/llvm-mirror/clang/blob/master/test/Sema/struct-packed-align.c
 */
void main() {
  var t = new BinaryTypes();
  var helper = new BinaryTypeHelper(t);
  helper.declare(_header);
  group("Struct packing and aligning.", () {
    test("Packing.", () {
      /*
       * struct s {
       *   char a;
       *   int b __attribute__((packed));
       *   char c;
       *   int d;
       * };
       */
      var type = t["struct s"];
      // sizeof(struct s) == 12
      expect(type.size, 12, reason: "sizeof(struct s) == 12");
      // __alignof(struct s) == 4
      expect(type.align, 4, reason: "__alignof(struct s) == 4");

      /*
       * struct __attribute__((packed)) packed_s {
       *   char a;
       *   int b __attribute__((packed));
       *   char c;
       *   int d;
       * };
       */
      type = t["struct packed_s"];
      // sizeof(struct packed_s) == 10
      expect(type.size, 10, reason: "sizeof(struct packed_s) == 10");
      // __alignof(struct packed_s) == 1
      expect(type.align, 1, reason: "__alignof(struct packed_s) == 1");

      /*
       * struct fas {
       *   char a;
       *   int b[];
       * };
       */
      type = t["struct fas"];
      // sizeof(struct fas) == 4
      expect(type.size, 4, reason: "sizeof(struct fas) == 4");
      // __alignof(struct fas) == 4
      expect(type.align, 4, reason: "__alignof(struct fas) == 4");

      /*
       * struct __attribute__((packed)) packed_fas {
       *   char a;
       *   int b[];
       * };
       */
      type = t["struct packed_fas"];
      // sizeof(struct packed_fas) == 1
      expect(type.size, 1, reason: "sizeof(struct packed_fas) == 1");
      // __alignof(struct packed_fas) == 1
      expect(type.align, 1, reason: "__alignof(struct packed_fas) == 1");

      /*
       * struct packed_after_fas {
       *   char a;
       *   int b[];
       * } __attribute__((packed));
       */
      type = t["struct packed_after_fas"];
      // sizeof(struct packed_after_fas) == 1
      expect(type.size, 1, reason: "sizeof(struct packed_after_fas) == 1");
      // __alignof(struct packed_after_fas) == 4
      expect(type.align, 1, reason: "__alignof(struct packed_after_fas) == 1");
    });

    test("Aligning.", () {
      /*
       * struct __attribute__((aligned(8))) as1 {
       *   char c;
       * };
       */
      var type = t["struct as1"];
      // sizeof(struct as1) == 8
      expect(type.size, 8, reason: "sizeof(struct as1) == 8");
      // __alignof(struct as1) == 8
      expect(type.align, 8, reason: "__alignof(struct as1) == 8");

      /*
       * struct __attribute__((aligned)) as1_2 {
       *   char c;
       * };
       */
      type = t["struct as1_2"];
      // sizeof(struct as1_2) == 16
      expect(type.size, 16, reason: "sizeof(struct as1_2) == 16");
      // __alignof(struct as1_2) == 16
      expect(type.align, 16, reason: "__alignof(struct as1_2) == 16");

      /*
       * struct as2 {
       *   char c;
       *   int __attribute__((aligned(8))) a;
       * };
       */
      type = t["struct as2"];
      // sizeof(struct as2) == 16
      expect(type.size, 16, reason: "sizeof(struct as2) == 16");
      // __alignof(struct as2) == 8
      expect(type.align, 8, reason: "__alignof(struct as2) == 8");

      /*
       * struct __attribute__((packed)) as3 {
       *   char c;
       *   int a;
       *   int __attribute__((aligned(8))) b;
       * };
       */
      type = t["struct as3"];
      // sizeof(struct as3) == 16
      expect(type.size, 16, reason: "sizeof(struct as3) == 16");
      // __alignof(struct as3) == 8
      expect(type.align, 8, reason: "__alignof(struct as3) == 8");

      /*
       * // Packed union
       * union __attribute__((packed)) au4 {char c; int x;};
       */
      type = t["union au4"];
      // sizeof(union au4) == 4
      expect(type.size, 4, reason: "sizeof(union au4) == 4");
      // __alignof(union au4) == 1
      expect(type.align, 1, reason: "__alignof(union au4) == 1");

      /*
       * // Aligned union
       * union au5 { char c __attribute__((aligned(4)));};
       */
      type = t["union au5"];
      // sizeof(union au5) == 4
      expect(type.size, 4, reason: "sizeof(union au5) == 4");
      // __alignof(union au5) == 4
      expect(type.align, 4, reason: "__alignof(union au5) == 4");

      /*
       * // Alignment+packed
       * struct as6 {char c; int x __attribute__((packed, aligned(2)));};
       */
      type = t["struct as6"];
      // sizeof(struct as6) == 6
      expect(type.size, 6, reason: "sizeof(struct as6) == 6");
      // __alignof(struct as6) == 2
      expect(type.align, 2, reason: "__alignof(struct as6) == 2");

      /*
       * union au6 {char c; int x __attribute__((packed, aligned(2)));};
       */
      type = t["union au6"];
      // sizeof(union au6) == 4
      expect(type.size, 4, reason: "sizeof(union au6) == 4");
      // __alignof(union au6) == 2
      expect(type.align, 2, reason: "__alignof(union au6) == 2");

      /*
       * // Check postfix attributes
       * union au7 {char c; int x;} __attribute__((packed));
       */
      type = t["union au7"];
      // sizeof(union au7) == 4
      expect(type.size, 4, reason: "sizeof(union au7) == 4");
      // __alignof(union au7) == 1
      expect(type.align, 1, reason: "__alignof(union au7) == 1");

      /*
       * struct packed_fas2 {
       *   char a;
       *   int b[];
       * } __attribute__((packed));
       */
      type = t["struct packed_fas2"];
      // sizeof(struct packed_fas2) == 1
      expect(type.size, 1, reason: "sizeof(struct packed_fas2) == 1");
      // __alignof(struct packed_fas2) == 1
      expect(type.align, 1, reason: "__alignof(struct packed_fas2) == 1");

      /*
       * // Attribute aligned can round down typedefs.  PR9253
       * typedef long long  __attribute__((aligned(1))) nt;
       * struct nS {
       * char buf_nr;
       * nt start_lba;
       * };
       */
      type = t["struct nS"];
      // sizeof(struct nS) == 9
      expect(type.size, 9, reason: "sizeof(struct nS) == 9");
      // __alignof(struct nS) == 1
      expect(type.align, 1, reason: "__alignof(struct nS) == 1");
    });
  });
}

String _header = '''
// https://github.com/llvm-mirror/clang/blob/master/test/Sema/struct-packed-align.c
// Packed structs.
struct s {
    char a;
    int b  __attribute__((packed));
    char c;
    int d;
};

struct __attribute__((packed)) packed_s {
    char a;
    int b  __attribute__((packed));
    char c;
    int d;
};

struct fas {
    char a;
    int b[];
};

struct __attribute__((packed)) packed_fas {
    char a;
    int b[];
};

struct packed_after_fas {
    char a;
    int b[];
} __attribute__((packed));

// Alignment

struct __attribute__((aligned(8))) as1 {
    char c;
};

// FIXME: Will need to force arch once max usable alignment isn't hard
// coded.
struct __attribute__((aligned)) as1_2 {
    char c;
};

struct as2 {
    char c;
    int __attribute__((aligned(8))) a;
};

struct __attribute__((packed)) as3 {
    char c;
    int a;
    int __attribute__((aligned(8))) b;
};

// rdar://5921025
struct packedtest {
  int ted_likes_cheese;
  void *args[] __attribute__((packed));
};

// Packed union
union __attribute__((packed)) au4 {char c; int x;};

// Aligned union
union au5 { char c __attribute__((aligned(4)));};

// Alignment+packed
struct as6 {char c; int x __attribute__((packed, aligned(2)));};

union au6 {char c; int x __attribute__((packed, aligned(2)));};

// Check postfix attributes
union au7 {char c; int x;} __attribute__((packed));

struct packed_fas2 {
    char a;
    int b[];
} __attribute__((packed));

// Attribute aligned can round down typedefs.  PR9253
typedef long long  __attribute__((aligned(1))) nt;

struct nS {
  char buf_nr;
  nt start_lba;
};
''';
