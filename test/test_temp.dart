import 'package:binary_declarations/binary_declarations.dart';
import 'package:binary_types/binary_types.dart';
import 'package:unittest/unittest.dart';

void main() {
  test0();
}

void test0() {
  var t = new BinaryTypes();
  var types = <BinaryType>[];
  var type = new FunctionType(t["int"], [(t["void*"])], new DataModel());
  types.add(type);
  types.add(type.ptr());
  types.add(type.ptr().ptr());
  type = t["int"];
  types.add(type);
  types.add(type.ptr());
  types.add(type.ptr().ptr());
  types.add(type.array(1));
  types.add(type.array(1).array(2));
  types.add(type.array(1).array(2).ptr());
  types.add(type.array(1).array(2).ptr().ptr());
  types.add(type.array(1).ptr().array(1));
  print("=====================");
  print("Types:");
  for (var type in types) {
    print(type);
  }

  print("=====================");
  print("Objects:");
  for (var type in types) {
    if (type.size > 0) {
      var obj = type.alloc();
      print(obj);
    } else {
      print("Skip incomplete type");
    }
  }

  print("=====================");
  print("Typedefs:");
  var index = 0;
  for (var type in types) {
    var newType = "TYPE${index++}";
    t[newType] = type;
    print(t[newType].typedefName);
  }
}

List<String> _addBeforeAndAfter(List<String> lines, String before, String after) {
  var length = lines.length;
  var result = new List<String>(length);
  for (var i = 0; i < length; i++) {
    result[i] = "$before${lines[i]}$after";
  }

  return result;
}

void _checkPresentation(String text, BinaryDeclarations declarations) {
  var lines = text.split("\n");
  var length = lines.length;
  var list = declarations.toList();
  expect(length, list.length, reason: "Text lines count");
  for (var i = 0; i < length; i++) {
    var line = lines[i];
    var actual = list[i].toString() + ";";
    expect(actual, line, reason: "Wrong presentation at line $i");
  }
}

List<String> _getFullListOfIntegerTypes() {
  var result = <String>[];
  result.add("char");
  result.add("int");
  var types = <String>["long", "long long", "short"];
  for (var type in types) {
    result.add(type);
    result.add("$type int");
  }

  return _getSignedAndUnsignedTypes(result);
}

List<String> _getSignedAndUnsignedTypes(List<String> types) {
  var result = <String>[];
  for (var type in types) {
    result.add(type);
    result.add("signed $type");
    result.add("unsigned $type");
  }

  return result;
}
