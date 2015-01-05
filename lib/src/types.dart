part of binary_types;

/**
 * Binary types.
 */
class BinaryTypes {
  /**
   * Data model of binary types.
   */
  DataModel _dataModel;

  Map<String, BinaryType> _types = new Map<String, BinaryType>();

  BinaryTypes({DataModel dataModel}) {
    if (dataModel == null) {
      dataModel = new DataModel();
    }

    _dataModel = dataModel;
    _init();
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

  /**
   * Clones the binary type and register it under a different name (typedef).
   */
  void operator []=(String name, type) {
    _checkTypeName(name);
    BinaryType binaryType;
    if (type is String) {
      binaryType = this[type];
    } else if (type is BinaryType) {
      binaryType = type;
      _checkDataModel(binaryType, "type $type");
    } else {
      throw new ArgumentError("name: $type");
    }

    if (_types.containsKey(name)) {
      BinaryTypeError.unableRedeclareType(name);
    }

    var copy = binaryType.clone();
    copy._name = name;
    _types[name] = copy;
  }

  /**
   * Registers the binary type in the type system.
   *
   * Parameters:
   *   [BinaryType] type
   *   Type to register
   */
  BinaryType registerType(BinaryType type) {
    if (type == null) {
      throw new ArgumentError.notNull("type");
    }

    _checkDataModel(type, "type $type");
    var name = type.name;
    if (_types.containsKey(name)) {
      BinaryTypeError.unableRedeclareType(name);
    }

    _types[name] = type;
    return type;
  }

  void _checkDataModel(BinaryType type, String subject) {
    if (type.dataModel != _dataModel) {
      BinaryTypeError.differentDataModel(subject);
    }
  }

  // TODO: Improve _checkTypeName()
  void _checkTypeName(String name) {
    if (name == null || name.isEmpty || name.trim() != name) {
      throw new ArgumentError("name: $name");
    }

    if (name == "struct" || name == "union") {
      throw new ArgumentError("name: $name");
    }
  }

  void _cloneInt(int size, bool signed, List<String> names) {
    var type = IntType.create(size, signed, _dataModel);
    for (var name in names) {
      _types[name] = type.clone().._name = name;
    }
  }

  BinaryType _getType(type, [BinaryType defaultType]) {
    if (type is String) {
      return this[type];
    } else if (type is BinaryType) {
      return type;
    }

    if (defaultType != null) {
      return defaultType;
    }

    throw new ArgumentError("type: $type");
  }

  void _init() {
    // char
    _cloneInt(_dataModel.sizeOfChar, _dataModel.isCharSigned, const ["char"]);

    // Signed integers
    _cloneInt(_dataModel.sizeOfChar, true, const ["signed char"]);
    _cloneInt(_dataModel.sizeOfShort, true, const ["short", "short int", "signed short", "signed short int"]);
    _cloneInt(_dataModel.sizeOfInt, true, const ["int", "signed", "signed int"]);
    _cloneInt(_dataModel.sizeOfLong, true, const ["long", "long int", "signed long", "signed long int"]);
    _cloneInt(_dataModel.sizeOfLongLong, true, const ["long long", "long long int", "signed long long", "signed long long int"]);

    // Unsigned integers
    _cloneInt(_dataModel.sizeOfChar, false, const ["unsigned char"]);
    _cloneInt(_dataModel.sizeOfShort, false, const ["unsigned short", "unsigned short int"]);
    _cloneInt(_dataModel.sizeOfInt, false, const ["unsigned", "unsigned int"]);
    _cloneInt(_dataModel.sizeOfLong, false, const ["unsigned long", "unsigned long int"]);
    _cloneInt(_dataModel.sizeOfLongLong, false, const ["unsigned long long", "unsigned long long int"]);

    // Fixed size integers
    _cloneInt(1, true, const ["int8_t"]);
    _cloneInt(2, true, const ["int16_t"]);
    _cloneInt(4, true, const ["int32_t"]);
    _cloneInt(8, true, const ["int64_t"]);
    _cloneInt(1, false, const ["uint8_t"]);
    _cloneInt(2, false, const ["uint16_t"]);
    _cloneInt(4, false, const ["uint32_t"]);
    _cloneInt(8, false, const ["uint64_t"]);

    // Pointer size
    _cloneInt(_dataModel.sizeOfPointer, true, const ["intptr_t"]);

    // Array size
    _cloneInt(_dataModel.sizeOfPointer, false, const ["size_t"]);

    // Floating points
    _types["float"] = new FloatType(_dataModel);
    _types["double"] = new DoubleType(_dataModel);

    // Void
    _types["void"] = new VoidType(_dataModel);

    // Variable arguments
    _types["..."] = new VaListType(_dataModel);
  }
}
