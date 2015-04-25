part of binary_types;

/**
 * Array binary type.
 */
class ArrayType extends BinaryType {
  String _key;

  /**
   * Number of elements.
   */
  final int length;

  /**
   * Type of elements in this dimension.
   */
  final BinaryType type;

  BinaryType _targetType;

  int _size;

  int _typeSize;

  ArrayType(this.type, this.length, DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (type == null) {
      throw new ArgumentError("type: $type");
    }

    if (length == null || length < 0) {
      throw new ArgumentError("length: $length");
    }

    if (type is ArrayType) {
      ArrayType arrayType = type;
      _targetType = arrayType._targetType;
    } else {
      _targetType = type;
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

  BinaryKind get kind => BinaryKind.ARRAY;

  String get name {
    if (_name == null) {
      _name = formatName();
    }

    return _name;
  }

  int get size => _size;

  ArrayType _clone({int align}) {
    var clone = new ArrayType(type, length, _dataModel, align: align);
    clone._key = _getKey();
    return clone;
  }

  bool _compatible(BinaryType other, bool strong) {
    if (other is ArrayType) {
      var arrayType = other;
      if (length == arrayType.length) {
        return type._compatible(arrayType.type, strong) && other.dataModel == dataModel;
      }
    }

    return false;
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

  String _getKey() {
    if (_key == null) {
      var sb = new StringBuffer();
      void dimensions(ArrayType type) {
        sb.write("[");
        sb.write(type.length);
        sb.write("]");
        var elementType = type.type;
        if (elementType.kind == BinaryKind.ARRAY) {
          dimensions(elementType);
        }
      }

      sb.write(_targetType._getKey());
      dimensions(this);
      _key = sb.toString();
    }

    return _key;
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

      for (var i = 0, offs = offset; i < available; i++, offs += _typeSize) {
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
}
