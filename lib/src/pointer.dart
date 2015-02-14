part of binary_types;

/**
 * Pointer binary type.
 */
class PointerType extends BinaryType {
  int _level;

  BinaryType _targetType;

  BinaryType _type;

  int _typeSize;

  PointerType(BinaryType type, DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (type == null) {
      throw new ArgumentError("type: $type");
    }

    _level = 0;
    _targetType = type;
    _type = type;
    if (type is PointerType) {
      PointerType pointerType = type;
      _level = pointerType.level + 1;
      _targetType = pointerType.targetType;
    }

    if (type.dataModel != dataModel) {
      BinaryTypeError.differentDataModel("pointer type '$type'");
    }

    if (align == null) {
      _align = _dataModel.alignOfPointer;
    }

    _typeSize = type.size;
  }

  dynamic get defaultValue {
    return new BinaryData._internal(type, 0, 0);
  }

  BinaryKinds get kind => BinaryKinds.POINTER;

  /**
   * Returns the level of this pointer in a chain of pointers.
   *
   * Eg.
   *     int*** ippp; // level is 2
   */
  int get level => _level;

  String get name {
    if (_name == null) {
      _name = formatName();
    }

    return _name;
  }

  int get size => _dataModel.sizeOfPointer;

  /**
   * Returns the target type in a chain of pointers.
   *
   * Eg.
   *     int** ipp; // `int` is a target type
   */
  BinaryType get targetType {
    return _targetType;
  }

  /**
   * Type of the referred data.
   */
  BinaryType get type => _type;

  dynamic _cast(value) {
    if (value is int) {
      return new BinaryData._internal(type, value, 0);
    } else if (value is BinaryData) {
      return new BinaryData._internal(type, value.base, value.offset);
    } else {
      return super._cast(value);
    }
  }

  PointerType _clone({int align}) {
    return new PointerType(type, _dataModel, align: align);
  }

  bool _compatible(BinaryType other, bool strong) {
    if (other is PointerType) {
      var pointerType = other;
      if (level == pointerType.level) {
        return targetType._compatible(pointerType.targetType, strong) && other.dataModel == dataModel;
      }
    }

    return false;
  }

  BinaryData _getElement(int base, int offset, index) {
    if (index is int) {
      return new BinaryData._internal(type, Unsafe.readIntPtr(base, offset), _typeSize * index);
    } else {
      return super._getElement(base, offset, index);
    }
  }

  dynamic _getElementValue(int base, int offset, index) {
    if (index is int) {
      return type._getValue(Unsafe.readIntPtr(base, offset), _typeSize * index);
    } else {
      return super._getElement(base, offset, index);
    }
  }

  BinaryData _getValue(int base, int offset) {
    return new BinaryData._internal(type, Unsafe.readIntPtr(base, offset), 0);
  }

  void _initialize(int base, int offset, value) {
    _setValue(base, offset, value);
  }

  void _setContent(int base, int offset, value) {
    if (value is BinaryData) {
      var valueType = value.type;
      // TODO: Support of array type?
      if (valueType is PointerType) {
        if (type is VoidType || valueType.type == type) {
          _setValue(base, offset, value.value);
          return;
        }
      }
    }

    super._setContent(base, offset, value);
  }

  void _setElement(int base, int offset, index, value) {
    if (index is int) {
      type._setContent(base, offset + _typeSize * index, value);
    } else {
      super._setElement(base, offset, index, value);
    }
  }

  void _setElementValue(int base, int offset, index, value) {
    if (index is int) {
      return type._setValue(Unsafe.readIntPtr(base, offset), _typeSize * index, value);
    } else {
      super._setElementValue(base, offset, index, value);
    }
  }

  void _setValue(int base, int offset, value) {
    var compatible = false;
    if (value is BinaryData) {
      var valueType = value.type;
      if (type._compatible(valueType, false)) {
        compatible = true;
      } else if (valueType is ArrayType) {
        if (type._compatible(valueType.type, false)) {
          compatible = true;
        }

      } else if (type.kind == BinaryKinds.VOID) {
        compatible = true;
      }
    }

    if (compatible) {
      Unsafe.writeIntPtr(base, offset, value.address);
    } else {
      super._setValue(base, offset, value);
    }
  }
}
