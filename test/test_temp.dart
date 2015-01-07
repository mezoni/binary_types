import "package:binary_types/binary_types.dart";

void main() {
  var t = new BinaryTypes();
  t.declare("");
  t.typeDef("foo", t["int"], align: 2);
  t.typeDef("foo", t["int"], align: 8);
}
