part of binary_types;

class EnumType extends BinaryType {
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

  BinaryKinds get kind => BinaryKinds.ENUM;

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
   *   [Map]<[String], [dynamic]> enumerators
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

    if (enumerators is List) {
      var list = enumerators;
      enumerators = <String, int>{};
      for (var name in list) {
        if (name is String) {
          enumerators[name] = null;
        } else {
          throw new ArgumentError("List of value contains illegal elements.");
        }
      }

    } else if (enumerators is! Map<String, dynamic>) {
      throw new ArgumentError.value(enumerators, "enumerators");
    }

    enumerators = enumerators as Map<String, int>;
    if (enumerators.length == 0) {
      throw new ArgumentError("Enumerators should contain at least one element");
    }

    var sizeOfEnum = dataModel.sizeOfInt;
    _type = IntType.create(sizeOfEnum, true, dataModel, align: align);
    var prev = -1;
    var signed = false;
    var max = (1 << (sizeOfEnum * 8 - 1)) - 1;
    var min = -(max + 1);
    _enumerators = <String, int>{};
    for (var name in enumerators.keys) {
      if (name is! String || name.isEmpty) {
        BinaryTypeError.illegalMemberName(this, name);
      }

      var value = enumerators[name];
      if (value is int) {
        prev = value;
      } else if (value == null) {
        value = ++prev;
      } else if (value is String) {
        value = _enumerators[value];
        prev = value;
        if (value == null) {
          throw new ArgumentError("Emumerators contains illegal elements.");
        }

      } else {
        throw new ArgumentError("Emumerators contains illegal elements.");
      }

      if (value < 0) {
        signed = true;
      }

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
    return new EnumType(tag, dataModel, align: align);
  }

  bool _compatible(BinaryType other, bool strong) {
    if (other is EnumType) {
      return identical(_original, other._original);
    }

    return false;
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
