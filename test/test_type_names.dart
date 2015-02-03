import 'package:binary_types/binary_types.dart';

void main() {
  var t = new BinaryTypes();
  var dataMode = t.int_t.dataModel;
  var types = <BinaryType>[];
  var type = new FunctionType("myfunc", t["int"], [(t["void*"])], dataMode);
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
  types.add(new EnumType("Color", ["RED", "GREEN", "RED"], dataMode));
  print("=====================");
  print("Types:");
  for (var type in types) {
    print(type);
  }

  print("=====================");
  print("Objects:");
  var maxLength = 0;
  var lines = [];
  for (var type in types) {
    var str = "";
    if (type.size > 0) {
      var object = type.alloc();
      str = object.toString();
    } else {
      str = "Skip incomplete type";
    }

    if (maxLength < str.length) {
      maxLength = str.length;
    }

    lines.add([str, type]);
  }

  for (var line in lines) {
    String object = line[0];
    BinaryType type = line[1];
    var pad = "".padRight(maxLength - object.length, " ");
    print("$object$pad // $type");
  }

  print("=====================");
  print("Typedefs:");
  var index = 0;
  for (var type in types) {
    var name = "t${index++}";
    var newType = type.clone(name);
    print(newType.typedefName);
  }
}
