binary_types
=====

Binary types are set of classes that allows access the binary data in "C" language way.

Version: 0.0.42

[Donate to binary types for dart](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=binary.dart@gmail.com&item_name=binary.types.for.dart&currency_code=USD)

**Interrelated (binary) software**

- [Binary declarations](https://pub.dartlang.org/packages/binary_declarations)
- [Binary generator](https://pub.dartlang.org/packages/binary_generator)
- [Binary interop](https://pub.dartlang.org/packages/binary_interop)
- [Binary marshalling](https://pub.dartlang.org/packages/binary_marshalling)
- [Binary types](https://pub.dartlang.org/packages/binary_types)

**Limitations**

- Long double type not supported (and never be) 
- Bit fields not supported (was started an initial implementation)

**Supported binary types**

- Array type
- Bool type
- Double type
- Enum type
- Float type
- Integer types
- Pointer type
- Struct type
- Union type

**Addidional types**

- Function type
- Void type

**Binary data**

- Binary data (at any memory locations and with binary type checking) 
- Binary data objects (with automatic memory deallocation)

**Binary type system**

- Configurable data models
- Configurable data types
- Packed structural types
- Unlimited typedefs and the redefinitions (only for the compatible types)

**Binary type helper**

- String allocations
- Header declarations
- String reading

**Small example**

```dart
import "package:binary_types/binary_types.dart";

final t = new BinaryTypes();

BinaryData alloc(String type, [value]) => t[type].alloc(value);

void examinePointerElement() {
  // PointerType
  // Element of the pointer is a reffered data at the index.

  // int ia[10];
  // int ip;
  final ia = alloc("int[10]", [0, 10, 20]);
  final ip = alloc("int*");

  // ip = &ia;
  // ip = (ip + 2);
  ip.value = ia;
  ip.value = ip[2];

  // Test it
  print(ip.value);
  print(ip.value.value); // 20
}

void examinePointerElementValue() {
  // PointerType
  // Value of the pointer element is a value of the reffered data.

  // int i;
  // int ia[10];
  // int ip;
  final i = alloc("int", 41);
  final ia = alloc("int[10]", [0, 10, 20]);
  final ip = alloc("int*");

  // ip = &ia
  // i = ip[2] // *(ip + 2)
  ip.value = ia;
  i.value = ip[2].value;

  // Test it
  print(i.value); // 20
}

void examinePointerValue() {
  // PointerType
  // Value of the pointer is a reffered data.

  // int i;
  // int ia[10] = {0, 10, 20};
  // int* ip;
  final i = alloc("int");
  final ia = alloc("int[10]", [0, 10, 20]);
  final ip = alloc("int*");

  // ip = &i;
  // ip = &ia;
  // ip = &ia[2];
  ip.value = i;
  ip.value = ia;
  ip.value = ia[2];

  // Test it
  print(ip.value);
  print(ip.value.value); // 20
}

void main() {
  examinePointerValue();
  examinePointerElement();
  examinePointerElementValue();
}

```
