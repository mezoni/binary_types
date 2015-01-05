part of binary_types;

/**
 * Pointer binary type.
 */
class PointerType extends BinaryType {
  /**
   * Type of the referred data.
   */
  final BinaryType type;

  int _typeSize;

  PointerType(this.type, DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (type == null) {
      throw new ArgumentError("type: $type");
    }

    var stars = [];
    var nextType = this;
    while (nextType is PointerType) {
      stars.add("*");
      nextType = nextType.type;
    }

    if (nextType is FunctionType) {
      var nameParts = nextType._nameParts;
      _name = "${nameParts[0]}${stars.join("")}${nameParts[1]}";
    } else {
      _name = "$type*";
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
    return new Reference._internal(type, 0, 0);
  }

  BinaryKinds get kind => BinaryKinds.POINTER;

  int get size => _dataModel.sizeOfPointer;

  bool operator ==(other) {
    return other is PointerType && (other as PointerType).type == type;
  }

  dynamic _cast(value) {
    if (value is int) {
      return new Reference._internal(type, value, 0);
    } else if (value is Reference) {
      return new Reference._internal(type, value.base, value.offset);
    } else {
      return super._cast(value);
    }
  }

  PointerType _clone({int align}) {
    return new PointerType(type, _dataModel, align: align);
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

  Reference _getValue(int base, int offset) {
    return new Reference._internal(type, Unsafe.readIntPtr(base, offset), 0);
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
    if (value is Reference) {
      var valueType = value.type;
      if (type is VoidType || valueType == type || (valueType is ArrayType && valueType.type == type)) {
        Unsafe.writeIntPtr(base, offset, value.address);
        return;
      }
    }

    super._setValue(base, offset, value);
  }
}
