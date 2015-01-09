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
  final i = alloc("int");
  final ia = alloc("int[10]", [0, 10, 20]);
  final ip = alloc("int*");

  // ip = &i;
  // *ip = 41;
  // ip = &ia[2];
  ip.value = i;
  ip.value.value = ia[2].value;
  ip.value = ia[1];
  ip.value.value = 41;

  // Test it
  print(i.value); // 20
  print(ia[1].value); // 41
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
