part of binary_types;

/**
 * Array binary type.
 */
class ArrayType extends BinaryType {
  /**
   * Number of elements.
   */
  final int length;

  /**
   * Type of elements in this dimension.
   */
  final BinaryType type;

  String _dimensions;

  BinaryType _targetType;

  int _size;

  int _typeSize;

  ArrayType(this.type, this.length, DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (type == null) {
      throw new ArgumentError("type: $type");
    }

    if (length == null || length <= 0) {
      throw new ArgumentError("length: $length");
    }

    if (type is ArrayType) {
      ArrayType arrayType = type;
      _targetType = arrayType._targetType;
      _dimensions = "${arrayType._dimensions}";
      _dimensions = "[$length]$_dimensions";

    } else {
      _targetType = type;
      _dimensions = "[$length]";
    }

    if (type.size == 0) {
      BinaryTypeError.arrayNotAllowed(this);
    }

    if (type.dataModel != dataModel) {
      BinaryTypeError.differentDataModel("array type '$type'");
    }

    _align = type.align;
    if (align != null) {
      if (_align < align) {
        _align = align;
      }
    }

    _typeSize = type.size;
    _size = _typeSize * length;
  }

  dynamic get defaultValue {
    var value = new List(length);
    for (var i = 0; i < length; i++) {
      value[i] = type.defaultValue;
    }

    return value;
  }

  BinaryKinds get kind => BinaryKinds.ARRAY;

  String get name {
    if (_name == null) {
      _name = formatName();
    }

    return _name;
  }

  int get size => _size;

  bool operator ==(other) => _compatible(other, true);

  ArrayType _clone({int align}) {
    return new ArrayType(type, length, _dataModel, align: align);
  }

  BinaryData _getElement(int base, int offset, index) {
    if (index is int) {
      if (index < 0 || index >= length) {
        BinaryTypeError.indexOutOfArange(this, index, length);
      }

      return new BinaryData._internal(type, base, offset + _typeSize * index);
    } else {
      return super._getElement(base, offset, index);
    }
  }

  dynamic _getElementValue(int base, int offset, index) {
    if (index is int) {
      if (index < 0 || index >= length) {
        BinaryTypeError.indexOutOfArange(this, index, length);
      }

      return type._getValue(base, offset + _typeSize * index);
    } else {
      return super._getElementValue(base, offset, index);
    }
  }

  List _getValue(int base, int offset) {
    var value = new List(length);
    for (var i = 0; i < length; i++, offset += _typeSize) {
      value[i] = type._getValue(base, offset);
    }

    return value;
  }

  void _initialize(int base, int offset, value) {
    if (value is List) {
      var available = value.length;
      var rest = length - available;
      if (rest < 0) {
        BinaryTypeError.valueLengthExceedsArrayLength(this, value.length);
      }

      for (var i = 0,
          offs = offset; i < available; i++, offs += _typeSize) {
        type._setValue(base, offs, value[i]);
      }

      if (rest > 0) {
        Unsafe.memorySet(base, offset + _typeSize * available, 0, rest * _typeSize);
      }

    } else if (value == null) {
      Unsafe.memorySet(base, 0, 0, _typeSize * length);
    } else {
      super._initialize(base, offset, value);
    }
  }

  void _setElement(int base, int offset, index, value) {
    if (index is int) {
      if (index < 0 || index >= length) {
        BinaryTypeError.indexOutOfArange(this, index, length);
      }

      type._setContent(base, offset + _typeSize * index, value);
    } else {
      super._setElement(base, offset, index, value);
    }
  }

  void _setElementValue(int base, int offset, index, value) {
    if (index is int) {
      if (index < 0 || index >= length) {
        BinaryTypeError.indexOutOfArange(this, index, length);
      }

      type._setValue(base, offset + _typeSize * index, value);
    } else {
      super._setElementValue(base, offset, index, value);
    }
  }

  void _setValue(int base, int offset, value) {
    if (value is List) {
      if (value.length != length) {
        BinaryTypeError.valueLengthMustBeEqualArrayLength(this, value.length);
      }

      for (var i = 0; i < length; i++, offset += _typeSize) {
        type._setValue(base, offset, value[i]);
      }
    } else {
      super._setValue(base, offset, value);
    }
  }

  bool _compatible(BinaryType other, bool strong) {
    if (other is ArrayType) {
      var arrayType = other;
      if (length == arrayType.length) {
        return type._compatible(arrayType.type, strong);
      }
    }

    return false;
  }
}
