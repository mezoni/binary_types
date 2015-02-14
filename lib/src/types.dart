part of binary_types;

/**
 * Binary types.
 */
class BinaryTypes {

  DataModel _dataModel;

  Map<String, BinaryType> _tags = new Map<String, BinaryType>();

  Map<String, BinaryType> _types = new Map<String, BinaryType>();

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

      _types.addAll(types._types);
      _tags.addAll(types._tags);
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

  void _init() {
    // _Bool
    _types["_Bool"] = new BoolType(_dataModel);

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
