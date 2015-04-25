part of binary_types;

class EnumType extends BinaryType {
  static int _ids = 0;

  String _key;

  final String tag;

  int _defaultValue;

  Map<String, int> _enumerators = <String, int>{};

  int _size = 0;

  BinaryType _type;

  EnumType(this.tag, DataModel dataModel, {int align}) : super(dataModel, align: align);

  int get defaultValue {
    if (size == 0) {
      BinaryTypeError.unableGetDefaultValueForIncompleteType(this);
    }

    var original = _original as EnumType;
    return original._defaultValue;
  }

  Map<String, int> get enumerators {
    var original = _original as EnumType;
    return new UnmodifiableMapView<String, int>(original._enumerators);
  }

  BinaryKind get kind => BinaryKind.ENUM;

  String get name {
    if (_name == null) {
      var sb = new StringBuffer();
      sb.write("enum ");
      if (tag != null) {
        sb.write(tag);
      } else {
        sb.write("<unnamed>");
      }

      _name = sb.toString();
    }

    return _name;
  }

  int get size {
    var original = _original as EnumType;
    return original._size;
  }

  /**
   * Adds the enumerators to the enum binary type.
   *
   * Parameters:
   *   [List]<[String]> enumerators
   *   [Map]<[String], [int]> enumerators
   *   Enumerators to be added to the enum type.
   *
   *   [int] align
   *   Data alignment for the binary type.
   */
  void addEnumerators(enumerators, {int align}) {
    if (enumerators == null) {
      throw new ArgumentError.notNull("enumerators");
    }

    if (!isOriginal) {
      BinaryTypeError.unableModifyTypeSynonym(_original, name);
    }

    if (this.enumerators.length != 0) {
      BinaryTypeError.unableRedeclareType(name);
    }

    var values = <String, int>{};
    if (enumerators is List<String>) {
      var length = enumerators.length;
      for (var i = 0; i < length; i++) {
        var name = enumerators[i];
        if (name is! String) {
          throw new ArgumentError("List of enumerators contains invalid elements.");
        }

        if (values.containsKey(name)) {
          throw new ArgumentError("Duplicate enumerator: $name");
        }

        values[name] = i;
      }
    } else if (enumerators is Map<String, int>) {
      for (var key in enumerators.keys) {
        if (key is! String) {
          throw new ArgumentError("Map of enumerators contains inavlid keys.");
        }

        var value = enumerators[key];
        if (value is! int) {
          throw new ArgumentError("Map of enumerators contains inavlid values.");
        }

        values[key] = value;
      }
    } else {
      throw new ArgumentError.value(enumerators, "enumerators");
    }

    if (values.length == 0) {
      throw new ArgumentError("Enumerators should contain at least one element");
    }

    var sizeOfEnum = dataModel.sizeOfInt;
    _type = IntType.create(sizeOfEnum, true, dataModel, align: align);
    var max = (1 << (sizeOfEnum * 8 - 1)) - 1;
    var min = -(max + 1);
    _enumerators = <String, int>{};
    for (var name in values.keys) {
      var value = values[name];
      if (value < min || value > max) {
        BinaryTypeError.enumeratorOutOfRange(this, name, value, _type);
      }

      _enumerators[name] = value;
    }

    if (align != null) {
      _align = align;
    } else {
      _align = _dataModel.sizeOfInt;
    }

    _defaultValue = _enumerators[_enumerators.keys.first];
    _size = _dataModel.sizeOfInt;
  }

  dynamic _cast(value) => _type._cast(value);

  BinaryType _clone({int align}) {
    var clone = new EnumType(tag, dataModel, align: align);
    clone._key = _getKey();
    return clone;
  }

  bool _compatible(BinaryType other, bool strong) {
    if (other is EnumType) {
      return identical(_original, other._original);
    }

    return false;
  }

  String _getKey() {
    if (_key == null) {
      _key = "enum #${_ids++}";
      _ids &= 0x3fffffff;
    }

    return _key;
  }

  int _getTypeElement(String name) {
    var value = enumerators[name];
    if (value != null) {
      return value;
    }

    return super._getTypeElement(name);
  }

  int _getValue(int base, int offset) {
    return _type._getValue(base, offset);
  }

  void _initialize(int base, int offset, value) {
    _type._initialize(base, offset, value);
  }

  void _setContent(int base, int offset, value) {
    if (value is BinaryData && value.type is EnumType) {
      _setValue(base, offset, value.value);
    } else {
      super._setContent(base, offset, value);
    }
  }

  void _setValue(int base, int offset, value) {
    _type._setValue(base, offset, value);
  }
}
