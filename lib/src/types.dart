part of binary_types;

/**
 * Binary types.
 */
class BinaryTypes {
  DataModel _dataModel;

  Map<String, MacroDefinition> _definitions = <String, MacroDefinition>{};

  Map<String, int> _enumerators = new Map<String, int>();

  Map<String, dynamic> _environment = new Map<String, dynamic>();

  Map<String, String> _headers = new Map<String, String>();

  Map<String, Prototype> _prototypes = <String, Prototype>{};

  Map<String, BinaryType> _tags = new Map<String, BinaryType>();

  Map<String, BinaryType> _types = new Map<String, BinaryType>();

  Map<String, Variable> _variables = <String, Variable>{};

  /**
   * Creates new types.
   *
   * Parameters:
   *   [DataModel] dataModel
   *   Data model for the binary types.
   *
   *   [BinaryTypes] types
   *   Previously declared types (all declared types will be imported).
   */
  BinaryTypes({DataModel dataModel, BinaryTypes types}) {
    if (dataModel == null) {
      if (types != null) {
        dataModel = types["int"].dataModel;
      } else {
        dataModel = new DataModel();
      }
    }

    _dataModel = dataModel;
    if (types != null) {
      if (types["int"].dataModel != dataModel) {
        BinaryTypeError.differentDataModel();
      }

      _definitions.addAll(types._definitions);
      _enumerators.addAll(types._enumerators);
      _environment.addAll(types._environment);
      _headers.addAll(types._headers);
      _tags.addAll(types._tags);
      _types.addAll(types._types);
    } else {
      _init();
    }
  }

  BinaryType operator [](String name) {
    if (name == null) {
      throw new ArgumentError("name: $name");
    }

    var type = _types[name];
    if (type != null) {
      return type;
    }

    var charCodes = name.codeUnits;
    var length = charCodes.length;
    if (length > 2) {
      var c = charCodes[length - 1];
      // Pointers
      if (c == 42) {
        var position = length - 2;
        c = charCodes[position];
        while (c == 32) {
          c = charCodes[--position];
        }

        var name = new String.fromCharCodes(charCodes.sublist(0, position + 1));
        return this[name].ptr();
      }

      // Arrays
      if (c == 93) {
        for (var i = length - 2; i > 0; i--) {
          c = charCodes[i];
          if (!(c >= 48 && c <= 57)) {
            if (i > 0 && c == 91) {
              var size = int.parse(new String.fromCharCodes(charCodes.sublist(i + 1, length - 1)), onError: (s) {});
              if (size != null && size >= 0) {
                var position = i - 1;
                c = charCodes[position];
                while (c == 32) {
                  c = charCodes[--position];
                }

                var name = new String.fromCharCodes(charCodes.sublist(0, position + 1));
                return this[name].array(size);
              }
            }

            break;
          }
        }
      }
    }

    BinaryTypeError.typeNotDefined(name);
    return null;
  }

  void _cloneBasicInt(IntType type, List<String> names, [bool typedef = false]) {
    for (var fullname in names) {
      BinaryType copy;
      if (typedef) {
        copy = type.clone(fullname);
      } else {
        copy = type.copy(fullname);
      }

      _types[fullname] = copy;
    }
  }

  void _cloneInt(int size, bool signed, List<String> names, [bool typedef = false]) {
    var type = IntType.create(size, signed, _dataModel);
    return _cloneBasicInt(type, names, typedef);
  }

  void _define(String name, dynamic value) {
    var fragments = new UnmodifiableListView([value.toString()]);
    var definition = new MacroDefinition(fragments: fragments, name: name);
    _definitions[name] = definition;
  }

  String _getDataModelName() {
    var bits = <int>[];
    bits.add(_dataModel.sizeOfChar * 8);
    bits.add(_dataModel.sizeOfShort * 8);
    bits.add(_dataModel.sizeOfInt * 8);
    bits.add(_dataModel.sizeOfLong * 8);
    bits.add(_dataModel.sizeOfPointer * 8);
    bits.add(_dataModel.sizeOfLongLong * 8);
    var model = bits.join("/");
    switch (model) {
      case "8/16/32/64/64/64":
        return "LP64";
      case "8/16/64/64/64/64":
        return "ILP64";
      case "8/16/32/32/64/64":
        return "LLP64";
      case "8/16/32/32/32/64":
        return "ILP32";
      case "8/16/16/32/32/64":
        return "LP32";
    }

    return "";
  }

  void _init() {
    // _Bool
    _types["_Bool"] = new BoolType(_dataModel);

    // char
    _types["char"] = IntType.createChar(null, _dataModel);

    // Signed integers
    var variants = _reproduce2([["char", "signed"]]);
    _cloneBasicInt(IntType.createChar(true, _dataModel), variants);
    variants = _reproduce2([["short"], ["short", "int"], ["short", "int", "signed"], ["short", "signed"]]);
    _cloneBasicInt(IntType.createShort(true, _dataModel), variants);
    variants = _reproduce2([["int"], ["int", "signed"], ["signed"]]);
    _cloneBasicInt(IntType.createInt(true, _dataModel), variants);
    variants = _reproduce2([["long"], ["long", "int"], ["long", "int", "signed"], ["long", "signed"]]);
    _cloneBasicInt(IntType.createLong(true, _dataModel), variants);
    variants =
        _reproduce2([["long long"], ["long long", "int"], ["long long", "int", "signed"], ["long long", "signed"]]);
    _cloneBasicInt(IntType.createLongLong(true, _dataModel), variants);

    // Unsigned integers
    variants = _reproduce2([["char", "unsigned"]]);
    _cloneBasicInt(IntType.createChar(false, _dataModel), variants);
    variants = _reproduce2([["short", "int", "unsigned"], ["short", "unsigned"]]);
    _cloneBasicInt(IntType.createShort(false, _dataModel), variants);
    variants = _reproduce2([["int", "unsigned"], ["unsigned"]]);
    _cloneBasicInt(IntType.createInt(false, _dataModel), variants);
    variants = _reproduce2([["long", "int", "unsigned"], ["long", "unsigned"]]);
    _cloneBasicInt(IntType.createLong(false, _dataModel), variants);
    variants = _reproduce2([["long long", "int", "unsigned"], ["long long", "unsigned"]]);
    _cloneBasicInt(IntType.createLongLong(false, _dataModel), variants);

    // Floating points
    _types["float"] = new FloatType(_dataModel);
    _types["double"] = new DoubleType(_dataModel);

    // Void
    _types["void"] = new VoidType(_dataModel);

    var sizeOfChar = _dataModel.sizeOfChar;

    // Definitions
    if (_dataModel.isCharSigned) {
      _define("__CHAR_MIN", -(1 << sizeOfChar * 8) ~/ 2);
      _define("__CHAR_MAX", (1 << sizeOfChar * 8) ~/ 2 - 1);
    } else {
      _define("__CHAR_MIN", 0);
      _define("__CHAR_MAX", (1 << sizeOfChar * 8) - 1);
    }

    // For "limits.h"
    _define("__CHAR_BIT", sizeOfChar * 8);
    _define("__SHORT_BIT", _dataModel.sizeOfShort * 8);
    _define("__INT_BIT", _dataModel.sizeOfInt * 8);
    _define("__LONG_BIT", _dataModel.sizeOfLong * 8);
    _define("__LLONG_BIT", _dataModel.sizeOfLongLong * 8);
    _define("__PTR_BIT", _dataModel.sizeOfPointer * 8);
    // For "stdint.h"
    _define("__INT8_TYPE", IntType.create(1, true, _dataModel).name);
    _define("__INT16_TYPE", IntType.create(2, true, _dataModel).name);
    _define("__INT32_TYPE", IntType.create(4, true, _dataModel).name);
    _define("__INT64_TYPE", IntType.create(8, true, _dataModel).name);
    _define("__UINT8_TYPE", IntType.create(1, false, _dataModel).name);
    _define("__UINT16_TYPE", IntType.create(2, false, _dataModel).name);
    _define("__UINT32_TYPE", IntType.create(4, false, _dataModel).name);
    _define("__UINT64_TYPE", IntType.create(8, false, _dataModel).name);
    _define("__INTPTR_TYPE", IntType.create(_dataModel.sizeOfPointer, true, _dataModel).name);
    _define("__UINTPTR_TYPE", IntType.create(_dataModel.sizeOfPointer, false, _dataModel).name);

    // Common information
    _define("__ARCH", SysInfo.processors.first.architecture);
    _define("__DATA_MODEL", _getDataModelName());
    _define("__OS", Platform.operatingSystem);
  }

  List<String> _reproduce2(List<List<String>> lists) {
    var result = <String>[];
    for (var list in lists) {
      var elements = <List>[];
      _rerpoduce(list, elements);
      for (var element in elements) {
        var name = element.join(" ");
        result.add(name);
      }
    }

    return result;
  }

  List<List> _rerpoduce(List list, List<List> result) {
    var length = list.length;
    if (length == 0) {
      return result;
    }

    var copy = [];
    copy.addAll(list);
    if (length == 1) {
      result.add(copy);
      return result;
    }

    for (var i = 0; i < length; i++) {
      var element = copy.first;
      var results = <List>[];
      var rest = copy.sublist(1);
      if (rest.length != 0) {
        _rerpoduce(rest, results);
        for (var r in results) {
          var foo = [element];
          foo.addAll(r);
          result.add(foo);
        }
      } else {
        result.add([element]);
      }

      if (i + 1 < length) {
        copy.removeAt(0);
        copy.add(element);
      }
    }

    return result;
  }
}
