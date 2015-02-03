part of binary_types;

/**
 * Binary types.
 */
// TODO: check the uniqueness of tags (enum, struct, union)
class BinaryTypes {

  BinaryType _char_t;

  DataModel _dataModel;

  BinaryType _double_t;

  BinaryType _float_t;

  BinaryType _int_t;

  BinaryType _long_t;

  BinaryType _long_long_t;

  BinaryType _short_t;

  BinaryType _signed_char_t;

  Map<String, BinaryType> _tags = new Map<String, BinaryType>();

  Map<String, BinaryType> _types = new Map<String, BinaryType>();

  BinaryType _unsigned_char_t;

  BinaryType _unsigned_int_t;

  BinaryType _unsigned_long_t;

  BinaryType _unsigned_long_long_t;

  BinaryType _unsigned_short_t;

  BinaryTypes({DataModel dataModel}) {
    if (dataModel == null) {
      dataModel = new DataModel();
    }

    _dataModel = dataModel;
    _init();
  }

  BinaryType get char_t {
    if (_char_t == null) {
      _char_t = this["char"];
    }

    return _char_t;
  }

  BinaryType get double_t {
    if (_double_t == null) {
      _double_t = this["double"];
    }

    return _double_t;
  }

  BinaryType get float_t {
    if (_float_t == null) {
      _float_t = this["float"];
    }

    return _float_t;
  }

  BinaryType get int_t {
    if (_int_t == null) {
      _int_t = this["int"];
    }

    return _int_t;
  }

  BinaryType get long_long_t {
    if (_long_long_t == null) {
      _long_long_t = this["long long"];
    }

    return _long_long_t;
  }

  BinaryType get long_t {
    if (_long_t == null) {
      _long_t = this["long"];
    }

    return _long_t;
  }

  BinaryType get short_t {
    if (_short_t == null) {
      _short_t = this["short"];
    }

    return _short_t;
  }

  BinaryType get signed_char_t {
    if (_signed_char_t == null) {
      _signed_char_t = this["signed char"];
    }

    return _signed_char_t;
  }

  BinaryType get unsigned_char_t {
    if (_unsigned_char_t == null) {
      _unsigned_char_t = this["unsigned char"];
    }

    return _unsigned_char_t;
  }

  BinaryType get unsigned_int_t {
    if (_unsigned_int_t == null) {
      _unsigned_int_t = this["unsigned int"];
    }

    return _unsigned_int_t;
  }

  BinaryType get unsigned_long_long_t {
    if (_unsigned_long_long_t == null) {
      _unsigned_long_long_t = this["unsigned long long"];
    }

    return _unsigned_long_long_t;
  }

  BinaryType get unsigned_long_t {
    if (_unsigned_long_t == null) {
      _unsigned_long_t = this["unsigned long"];
    }

    return _unsigned_long_t;
  }

  BinaryType get unsigned_short_t {
    if (_unsigned_short_t == null) {
      _unsigned_short_t = this["unsigned short"];
    }

    return _unsigned_short_t;
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
        var name = new String.fromCharCodes(charCodes.sublist(0, length - 1));
        return this[name].ptr();
      }

      // Arrays
      if (c == 93) {
        for (var i = length - 2; i > 0; i--) {
          var c = charCodes[i];
          if (!(c >= 48 && c <= 57)) {
            if (i > 0 && c == 91) {
              var size = int.parse(new String.fromCharCodes(charCodes.sublist(i + 1, length - 1)), onError: (s) {});
              if (size != null && size >= 0) {
                var name = new String.fromCharCodes(charCodes.sublist(0, i));
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
    var name = type.name;
    for (var fullname in names) {
      var alias = name;
      if (typedef) {
        alias = fullname;
      }

      var copy = type.clone(alias);
      if (!typedef) {
        copy._original = null;
        copy._typedefName = "";
      }

      _types[fullname] = copy;
    }
  }

  void _cloneInt(int size, bool signed, List<String> names, [bool typedef = false]) {
    var type = IntType.create(size, signed, _dataModel);
    return _cloneBasicInt(type, names, typedef);
  }

  void _init() {
    // char
    _types["char"] = IntType.createChar(null, _dataModel);

    // Signed integers
    _cloneBasicInt(IntType.createChar(true, _dataModel), const ["signed char"]);
    _cloneBasicInt(IntType.createShort(true, _dataModel), const ["short", "short int", "signed short", "signed short int"]);
    _cloneBasicInt(IntType.createInt(true, _dataModel), const ["int", "signed", "signed int"]);
    _cloneBasicInt(IntType.createLong(true, _dataModel), const ["long", "long int", "signed long", "signed long int"]);
    _cloneBasicInt(IntType.createLongLong(true, _dataModel), const ["long long", "long long int", "signed long long", "signed long long int"]);

    // Unsigned integers
    _cloneBasicInt(IntType.createChar(false, _dataModel), const ["unsigned char"]);
    _cloneBasicInt(IntType.createShort(false, _dataModel), const ["unsigned short", "unsigned short int"]);
    _cloneBasicInt(IntType.createInt(false, _dataModel), const ["unsigned", "unsigned int"]);
    _cloneBasicInt(IntType.createLong(false, _dataModel), const ["unsigned long", "unsigned long int"]);
    _cloneBasicInt(IntType.createLongLong(false, _dataModel), const ["unsigned long long", "unsigned long long int"]);

    // Fixed size integers
    _cloneInt(1, true, const ["int8_t"], true);
    _cloneInt(2, true, const ["int16_t"], true);
    _cloneInt(4, true, const ["int32_t"], true);
    _cloneInt(8, true, const ["int64_t"], true);
    _cloneInt(1, false, const ["uint8_t"], true);
    _cloneInt(2, false, const ["uint16_t"], true);
    _cloneInt(4, false, const ["uint32_t"], true);
    _cloneInt(8, false, const ["uint64_t"], true);

    // Pointer size
    _cloneInt(_dataModel.sizeOfPointer, true, const ["intptr_t"], true);

    // Array size
    _cloneInt(_dataModel.sizeOfPointer, false, const ["size_t"], true);

    // Floating points
    _types["float"] = new FloatType(_dataModel);
    _types["double"] = new DoubleType(_dataModel);

    // Void
    _types["void"] = new VoidType(_dataModel);

    // Variable arguments
    _types["..."] = new VaListType(_dataModel);
  }
}
