part of binary_types;

/**
 * Double binary type.
 */
class DoubleType extends FloatingPointType {
  static final double _min = 4.9406564584124654e-324;

  static final double _max = 1.7976931348623157e+308;

  DoubleType(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = _dataModel.alignOfDouble;
    }
  }

  BinaryKind get kind => BinaryKind.DOUBLE;

  String get name {
    if (_name == null) {
      _name = "double";
    }

    return _name;
  }

  int get size => _dataModel.sizeOfDouble;

  DoubleType _clone({int align}) {
    return new DoubleType(_dataModel, align: align);
  }

  double _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getFloat64(offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is int) {
      value = value.toDouble();
    }

    if (value is double) {
      new _PhysicalData(base, 0).setFloat64(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

/**
 * Float binary type.
 */
class FloatType extends FloatingPointType {
  static const double _min = 1.40129846e-45;

  static const double _max = 3.40282347e+38;

  FloatType(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = dataModel.alignOfFloat;
    }
  }

  BinaryKind get kind => BinaryKind.FLOAT;

  String get name {
    if (_name == null) {
      _name = "float";
    }

    return _name;
  }

  int get size => _dataModel.sizeOfFloat;

  FloatType _clone({int align}) {
    return new FloatType(_dataModel, align: align);
  }

  double _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getFloat32(offset);
  }

  void _setValue(int base, int offset, value) {
    if (value is int) {
      value = value.toDouble();
    }

    if (value is double) {
      new _PhysicalData(base, 0).setFloat32(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}

/**
 * Floating point binary type.
 */
abstract class FloatingPointType extends BinaryType {
  static const double _min = 0.0;

  static const double _max = 0.0;

  FloatingPointType(DataModel dataModel, {int align}) : super(dataModel, align: align);

  double get defaultValue {
    return 0.0;
  }

  double _cast(value) {
    if (value is int) {
      value = value.toDouble();
    }

    if (value is double) {
      if (value < _min) {
        return _min;
      } else if (value > _max) {
        return _max;
      }

      return value;
    } else {
      return super._cast(value);
    }
  }

  bool _compatible(BinaryType other, bool strong) {
    return other.kind == kind && other.dataModel == dataModel;
  }

  void _initialize(int base, int offset, value) {
    _setValue(base, offset, value);
  }

  void _setContent(int base, int offset, value) {
    if (value is BinaryData && value.type is FloatingPointType) {
      _setValue(base, offset, value.value);
    } else {
      super._setContent(base, offset, value);
    }
  }
}
