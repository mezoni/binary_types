part of binary_types;

/**
 * 16-bit signed integer binary type.
 */
class Int16Type extends IntType {
  /**
   * Maximal value.
   */
  static const int MAX = (1 << (SIZE * 8 - 1)) - 1;

  /**
   * Minimal value.
   */
  static const int MIN = -(MAX + 1);

  /**
   * Size, in bytes, of 16-bit signed integer type.
   */
  static const int SIZE = 2;

  Int16Type(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = _dataModel.alignOfInt16;
    }
  }

  BinaryKind get kind => BinaryKind.SINT16;

  int get max => MAX;

  int get min => MIN;

  bool get signed => true;

  int get size => SIZE;

  int _cast(value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      if (value >= MIN && value <= MAX) {
        return value;
      }

      value &= (MAX << 1) + 1;
      return value <= MAX ? value : value - ((MAX << 1) + 2);
    } else if (value is BinaryData) {
      if (value.offset == 0) {
        return value.base;
      }

      return value.base + value.offset;
    } else {
      return super._cast(value);
    }
  }

  int _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getInt16(offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      new _PhysicalData(base, 0).setInt16(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

/**
 * 32-bit signed integer binary type.
 */
class Int32Type extends IntType {
  /**
   * Maximal value.
   */
  static const int MAX = (1 << (SIZE * 8 - 1)) - 1;

  /**
   * Minimal value.
   */
  static const int MIN = -(MAX + 1);

  /**
   * Size, in bytes, of 32-bit signed integer type.
   */
  static const int SIZE = 4;

  Int32Type(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = _dataModel.alignOfInt32;
    }
  }

  BinaryKind get kind => BinaryKind.SINT32;

  int get max => MAX;

  int get min => MIN;

  bool get signed => true;

  int get size => SIZE;

  int _cast(value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      if (value >= MIN && value <= MAX) {
        return value;
      }

      value &= (MAX << 1) + 1;
      return value <= MAX ? value : value - ((MAX << 1) + 2);
    } else if (value is BinaryData) {
      if (value.offset == 0) {
        return value.base;
      }

      return value.base + value.offset;
    } else {
      return super._cast(value);
    }
  }

  int _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getInt32(offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      new _PhysicalData(base, 0).setInt32(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

/**
 * 64-bit signed integer binary type.
 */
class Int64Type extends IntType {
  /**
   * Maximal value.
   */
  static const int MAX = (1 << (SIZE * 8 - 1)) - 1;

  /**
   * Minimal value.
   */
  static const int MIN = -(MAX + 1);

  /**
   * Size, in bytes, of 64-bit signed integer type.
   */
  static const int SIZE = 8;

  Int64Type(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = _dataModel.alignOfInt64;
    }
  }

  BinaryKind get kind => BinaryKind.SINT64;

  int get max => MAX;

  int get min => MIN;

  bool get signed => true;

  int get size => SIZE;

  int _cast(value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      if (value >= MIN && value <= MAX) {
        return value;
      }

      value &= (MAX << 1) + 1;
      return value <= MAX ? value : value - ((MAX << 1) + 2);
    } else if (value is BinaryData) {
      if (value.offset == 0) {
        return value.base;
      }

      return value.base + value.offset;
    } else {
      return super._cast(value);
    }
  }

  int _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getInt64(offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      new _PhysicalData(base, 0).setInt64(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

/**
 * 8-bit signed integer binary type.
 */
class Int8Type extends IntType {
  /**
   * Maximal value.
   */
  static const int MAX = (1 << (SIZE * 8 - 1)) - 1;

  /**
   * Minimal value.
   */
  static const int MIN = -(MAX + 1);

  /**
   * Size, in bytes, of 8-bit signed integer type.
   */
  static const int SIZE = 1;

  Int8Type(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = _dataModel.alignOfInt8;
    }
  }

  BinaryKind get kind => BinaryKind.SINT8;

  int get max => MAX;

  int get min => MIN;

  bool get signed => true;

  int get size => SIZE;

  int _cast(value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      if (value >= MIN && value <= MAX) {
        return value;
      }

      value &= (MAX << 1) + 1;
      return value <= MAX ? value : value - ((MAX << 1) + 2);
    } else if (value is BinaryData) {
      if (value.offset == 0) {
        return value.base;
      }

      return value.base + value.offset;
    } else {
      return super._cast(value);
    }
  }

  int _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getInt8(offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      new _PhysicalData(base, 0).setInt8(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

abstract class IntType extends BinaryType {
  static const int BASIC_TYPE_SIGNED_BY_MODEL = 1;

  static const int BASIC_TYPE_SIGNED = 2;

  static const int BASIC_TYPE_CHAR = 4;

  static const int BASIC_TYPE_INT = 8;

  static const int BASIC_TYPE_SHORT = 16;

  static const int BASIC_TYPE_LONG = 32;

  static const int BASIC_TYPE_LONG_LONG = 64;

  static const int BASIC_TYPE_ALL = BASIC_TYPE_LONG_LONG - 1;

  int _basicType = 0;

  IntType(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (size == dataModel.sizeOfChar) {
      _basicType = BASIC_TYPE_CHAR;
    } else if (size == dataModel.sizeOfShort) {
      _basicType = BASIC_TYPE_SHORT;
    } else if (size == dataModel.sizeOfInt) {
      _basicType = BASIC_TYPE_INT;
    } else if (size == dataModel.sizeOfInt) {
      _basicType = BASIC_TYPE_INT;
    } else if (size == dataModel.sizeOfLongLong) {
      _basicType = BASIC_TYPE_LONG_LONG;
    } else {
      BinaryTypeError.integerSizeNotSupported(size);
    }

    switch (_basicType) {
      case BASIC_TYPE_CHAR:
        _name = signed ? "signed char" : "unsigned char";
        break;
      case BASIC_TYPE_SHORT:
        _name = signed ? "short" : "unsigned short";
        break;
      case BASIC_TYPE_INT:
        _name = signed ? "int" : "unsigned int";
        break;
      case BASIC_TYPE_LONG:
        _name = signed ? "long" : "unsigned long";
        break;
      case BASIC_TYPE_LONG_LONG:
        _name = signed ? "long long" : "unsigned long long";
        break;
    }

    if (signed) {
      _basicType |= BASIC_TYPE_SIGNED;
    }
  }

  int get defaultValue {
    return 0;
  }

  /**
   * Returns the maximal value.
   */
  int get max;

  /**
   * Returns the minimal value.
   */
  int get min;

  String get name => _name;

  /**
   * Indicates when type is signed.
   */
  bool get signed;

  IntType _clone({int align}) {
    var copy = create(size, signed, dataModel, align: align);
    copy._basicType = _basicType;
    return copy;
  }

  bool _compatible(BinaryType other, bool strong) {
    if (other is IntType) {
      var mask = strong ? BASIC_TYPE_ALL : BASIC_TYPE_ALL & ~(BASIC_TYPE_SIGNED_BY_MODEL | BASIC_TYPE_SIGNED);
      return (_basicType & mask == other._basicType & mask) && other.dataModel == dataModel;
    }

    return false;
  }

  void _initialize(int base, int offset, value) {
    _setValue(base, offset, value);
  }

  void _setContent(int base, int offset, value) {
    if (value is BinaryData && value.type is IntType) {
      _setValue(base, offset, value.value);
    } else {
      super._setContent(base, offset, value);
    }
  }

  static IntType create(int size, bool signed, DataModel dataModel, {int align}) {
    if (size == null) {
      throw new ArgumentError.notNull("size");
    }

    if (signed == null) {
      throw new ArgumentError.notNull("signed");
    }

    if (dataModel == null) {
      throw new ArgumentError.notNull("dataModel");
    }

    if (signed) {
      switch (size) {
        case 1:
          return new Int8Type(dataModel, align: align);
        case 2:
          return new Int16Type(dataModel, align: align);
        case 4:
          return new Int32Type(dataModel, align: align);
        case 8:
          return new Int64Type(dataModel, align: align);
        default:
          throw new ArgumentError("size: $size");
      }
    } else {
      switch (size) {
        case 1:
          return new Uint8Type(dataModel, align: align);
        case 2:
          return new Uint16Type(dataModel, align: align);
        case 4:
          return new Uint32Type(dataModel, align: align);
        case 8:
          return new Uint64Type(dataModel, align: align);
        default:
          throw new ArgumentError("size: $size");
      }
    }
  }

  static IntType createChar(bool signed, DataModel dataModel, {int align}) {
    var sign = signed;
    if (signed == null) {
      sign = dataModel.isCharSigned;
    }

    var type = create(dataModel.sizeOfChar, sign, dataModel, align: align);
    switch (signed) {
      case true:
        type._basicType = BASIC_TYPE_CHAR | BASIC_TYPE_SIGNED;
        type._name = "signed char";
        break;
      case false:
        type._basicType = BASIC_TYPE_CHAR;
        type._name = "unsigned char";
        break;
    }

    if (signed == null) {
      type._basicType = BASIC_TYPE_CHAR | BASIC_TYPE_SIGNED_BY_MODEL;
      type._name = "char";
    }

    return type;
  }

  /**
   * Creates basic "int" type.
   *
   * Parameters:
   *   [DataModel] dataModel
   *   Data model of binary type.
   *
   *   [bool] signed
   *   Sign of integer type.
   *
   *   [int] align
   *   Data alignment of binary type.
   */
  static IntType createInt(bool signed, DataModel dataModel, {int align}) {
    var type = create(dataModel.sizeOfInt, signed, dataModel, align: align);
    switch (signed) {
      case true:
        type._basicType = BASIC_TYPE_INT | BASIC_TYPE_SIGNED;
        type._name = "int";
        break;
      case false:
        type._basicType = BASIC_TYPE_INT;
        type._name = "unsigned int";
        break;
    }

    return type;
  }

  /**
   * Creates basic "logn" type.
   *
   * Parameters:
   *   [DataModel] dataModel
   *   Data model of binary type.
   *
   *   [bool] signed
   *   Sign of integer type.
   *
   *   [int] align
   *   Data alignment of binary type.
   */
  static IntType createLong(bool signed, DataModel dataModel, {int align}) {
    var type = create(dataModel.sizeOfLong, signed, dataModel, align: align);
    switch (signed) {
      case true:
        type._basicType = BASIC_TYPE_LONG | BASIC_TYPE_SIGNED;
        type._name = "long";
        break;
      case false:
        type._basicType = BASIC_TYPE_LONG;
        type._name = "unsigned long";
        break;
    }

    return type;
  }

  /**
   * Creates basic "logn long" type.
   *
   * Parameters:
   *   [DataModel] dataModel
   *   Data model of binary type.
   *
   *   [bool] signed
   *   Sign of integer type.
   *
   *   [int] align
   *   Data alignment of binary type.
   */
  static IntType createLongLong(bool signed, DataModel dataModel, {int align}) {
    var type = create(dataModel.sizeOfLongLong, signed, dataModel, align: align);
    switch (signed) {
      case true:
        type._basicType = BASIC_TYPE_LONG_LONG | BASIC_TYPE_SIGNED;
        type._name = "logn long";
        break;
      case false:
        type._basicType = BASIC_TYPE_LONG_LONG;
        type._name = "unsigned logn long";
        break;
    }

    return type;
  }

  /**
   * Creates basic "short" type.
   *
   * Parameters:
   *   [DataModel] dataModel
   *   Data model of binary type.
   *
   *   [bool] signed
   *   Sign of integer type.
   *
   *   [int] align
   *   Data alignment of binary type.
   */
  static IntType createShort(bool signed, DataModel dataModel, {int align}) {
    var type = create(dataModel.sizeOfShort, signed, dataModel, align: align);
    switch (signed) {
      case true:
        type._basicType = BASIC_TYPE_SHORT | BASIC_TYPE_SIGNED;
        type._name = "short";
        break;
      case false:
        type._basicType = BASIC_TYPE_SHORT;
        type._name = "unsigned short";
        break;
    }

    return type;
  }
}

/**
 * 16-bit unsigned integer binary type.
 */
class Uint16Type extends IntType {
  /**
   * Maximal value.
   */
  static const int MAX = (1 << (SIZE * 8)) - 1;

  /**
   * Minimal value.
   */
  static const int MIN = 0;

  /**
   * Size, in bytes, of 16-bit unsigned integer type.
   */
  static const int SIZE = 2;

  Uint16Type(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = _dataModel.alignOfInt16;
    }
  }

  BinaryKind get kind => BinaryKind.UINT16;

  int get max => MAX;

  int get min => MIN;

  bool get signed => false;

  int get size => SIZE;

  int _cast(value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      if (value < MIN || value > MAX) {
        return value &= MAX;
      }

      return value;
    } else if (value is BinaryData) {
      if (value.offset == 0) {
        return value.base;
      }

      return value.base + value.offset;
    } else {
      return super._cast(value);
    }
  }

  int _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getUint16(offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      new _PhysicalData(base, 0).setUint16(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

/**
 * 32-bit unsigned integer binary type.
 */
class Uint32Type extends IntType {
  /**
   * Maximal value.
   */
  static const int MAX = (1 << (SIZE * 8)) - 1;

  /**
   * Minimal value.
   */
  static const int MIN = 0;

  /**
   * Size, in bytes, of 32-bit unsigned integer type.
   */
  static const int SIZE = 4;

  Uint32Type(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = _dataModel.alignOfInt32;
    }
  }

  BinaryKind get kind => BinaryKind.UINT32;

  int get max => MAX;

  int get min => MIN;

  bool get signed => false;

  int get size => SIZE;

  int _cast(value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      if (value < MIN || value > MAX) {
        return value &= MAX;
      }

      return value;
    } else if (value is BinaryData) {
      if (value.offset == 0) {
        return value.base;
      }

      return value.base + value.offset;
    } else {
      return super._cast(value);
    }
  }

  int _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getUint32(offset);
  }

  void _setValue(base, offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      new _PhysicalData(base, 0).setUint32(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

/**
 * 64-bit unsigned integer binary type.
 */
class Uint64Type extends IntType {
  /**
   * Maximal value.
   */
  static const int MAX = (1 << (SIZE * 8)) - 1;

  /**
   * Minimal value.
   */
  static const int MIN = 0;

  /**
   * Size, in bytes, of 64-bit unsigned integer type.
   */
  static const int SIZE = 8;

  Uint64Type(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = _dataModel.alignOfInt64;
    }
  }

  BinaryKind get kind => BinaryKind.UINT64;

  int get max => MAX;

  int get min => MIN;

  bool get signed => false;

  int get size => SIZE;

  int _cast(value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      if (value < MIN || value > MAX) {
        return value &= MAX;
      }

      return value;
    } else if (value is BinaryData) {
      if (value.offset == 0) {
        return value.base;
      }

      return value.base + value.offset;
    } else {
      return super._cast(value);
    }
  }

  int _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getUint64(offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      new _PhysicalData(base, 0).setUint64(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

/**
 * 8-bit unsigned integer binary type.
 */
class Uint8Type extends IntType {
  /**
   * Maximal value.
   */
  static const int MAX = (1 << (SIZE * 8)) - 1;

  /**
   * Minimal value.
   */
  static const int MIN = 0;

  /**
   * Size, in bytes, of 8-bit unsigned integer type.
   */
  static const int SIZE = 1;

  Uint8Type(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = _dataModel.alignOfInt8;
    }
  }

  BinaryKind get kind => BinaryKind.UINT8;

  int get max => MAX;

  int get min => MIN;

  bool get signed => false;

  int get size => SIZE;

  int _cast(value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      if (value < MIN || value > MAX) {
        return value &= MAX;
      }

      return value;
    } else if (value is BinaryData) {
      if (value.offset == 0) {
        return value.base;
      }

      return value.base + value.offset;
    } else {
      return super._cast(value);
    }
  }

  int _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getUint8(offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      new _PhysicalData(base, 0).setUint16(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}
