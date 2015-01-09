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

    _name = "int16_t";
  }

  BinaryKinds get kind => BinaryKinds.SINT16;

  int get max => MAX;

  int get min => MIN;

  bool get signed => true;

  int get size => SIZE;

  bool operator ==(other) => other is Int16Type;

  dynamic _cast(value) {
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

  Int16Type _clone({int align}) {
    return new Int16Type(_dataModel, align: align);
  }

  int _getValue(int base, int offset) {
    return Unsafe.readInt16(base, offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      Unsafe.writeInt16(base, offset, value);
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

    _name = "int32_t";
  }

  BinaryKinds get kind => BinaryKinds.SINT32;

  int get max => MAX;

  int get min => MIN;

  bool get signed => true;

  int get size => SIZE;

  bool operator ==(other) => other is Int32Type;

  dynamic _cast(value) {
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

  Int32Type _clone({int align}) {
    return new Int32Type(_dataModel, align: align);
  }

  int _getValue(int base, int offset) {
    return Unsafe.readInt32(base, offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      Unsafe.writeInt32(base, offset, value);
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

    _name = "int64_t";
  }

  BinaryKinds get kind => BinaryKinds.SINT64;

  int get max => MAX;

  int get min => MIN;

  bool get signed => true;

  int get size => SIZE;

  bool operator ==(other) => other is Int64Type;

  dynamic _cast(value) {
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

  Int64Type _clone({int align}) {
    return new Int64Type(_dataModel, align: align);
  }

  int _getValue(int base, int offset) {
    return Unsafe.readInt64(base, offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      Unsafe.writeInt64(base, offset, value);
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

    _name = "int8_t";
  }

  BinaryKinds get kind => BinaryKinds.SINT8;

  int get max => MAX;

  int get min => MIN;

  bool get signed => true;

  int get size => SIZE;

  bool operator ==(other) => other is Int8Type;

  dynamic _cast(value) {
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

  Int8Type _clone({int align}) {
    return new Int8Type(_dataModel, align: align);
  }

  int _getValue(int base, int offset) {
    return Unsafe.readInt8(base, offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      Unsafe.writeInt8(base, offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

abstract class IntType extends BinaryType {
  IntType(DataModel dataModel, {int align}) : super(dataModel, align: align);

  dynamic get defaultValue {
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

  /**
   * Indicates when type is signed.
   */
  bool get signed;

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

  static IntType create(int size, bool signed, DataModel dataModel) {
    if (signed == null) {
      throw new ArgumentError("signed: $signed");
    }

    if (signed) {
      switch (size) {
        case 1:
          return new Int8Type(dataModel);
        case 2:
          return new Int16Type(dataModel);
        case 4:
          return new Int32Type(dataModel);
        case 8:
          return new Int64Type(dataModel);
        default:
          throw new ArgumentError("size: $size");
      }
    } else {
      switch (size) {
        case 1:
          return new Uint8Type(dataModel);
        case 2:
          return new Uint16Type(dataModel);
        case 4:
          return new Uint32Type(dataModel);
        case 8:
          return new Uint64Type(dataModel);
        default:
          throw new ArgumentError("size: $size");
      }
    }
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

    _name = "uint16_t";
  }

  BinaryKinds get kind => BinaryKinds.UINT16;

  int get max => MAX;

  int get min => MIN;

  bool get signed => false;

  int get size => SIZE;

  bool operator ==(other) => other is Uint16Type;

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

  Uint16Type _clone({int align}) {
    return new Uint16Type(_dataModel, align: align);
  }

  int _getValue(int base, int offset) {
    return Unsafe.readUint16(base, offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      Unsafe.writeUint16(base, offset, value);
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

    _name = "uint32_t";
  }

  BinaryKinds get kind => BinaryKinds.UINT32;

  int get max => MAX;

  int get min => MIN;

  bool get signed => false;

  int get size => SIZE;

  bool operator ==(other) => other is Uint32Type;

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

  Uint32Type _clone({int align}) {
    return new Uint32Type(_dataModel, align: align);
  }

  int _getValue(int base, int offset) {
    return Unsafe.readUint32(base, offset);
  }

  void _setValue(base, offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      Unsafe.writeUint32(base, offset, value);
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

    _name = "uint64_t";
  }

  BinaryKinds get kind => BinaryKinds.UINT64;

  int get max => MAX;

  int get min => MIN;

  bool get signed => false;

  int get size => SIZE;

  bool operator ==(other) => other is Uint64Type;

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

  Uint64Type _clone({int align}) {
    return new Uint64Type(_dataModel, align: align);
  }

  int _getValue(int base, int offset) {
    return Unsafe.readUint64(base, offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      Unsafe.writeUint64(base, offset, value);
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

    _name = "uint8_t";
  }

  BinaryKinds get kind => BinaryKinds.UINT8;

  int get max => MAX;

  int get min => MIN;

  bool get signed => false;

  int get size => SIZE;

  bool operator ==(other) => other is Uint8Type;

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

  Uint8Type _clone({int align}) {
    return new Uint8Type(_dataModel, align: align);
  }

  int _getValue(int base, int offset) {
    return Unsafe.readUint8(base, offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is double) {
      value = value.toInt();
    }

    if (value is int) {
      Unsafe.writeUint8(base, offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}
