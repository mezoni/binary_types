part of binary_types;

/*
 * Bool binary type
 */
class BoolType extends BinaryType {
  BoolType(DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (align == null) {
      _align = 1;
    }
  }

  bool get defaultValue => false;

  BinaryKind get kind => BinaryKind.BOOL;

  String get name {
    if (_name == null) {
      _name = "_Bool";
    }

    return _name;
  }

  int get size => 1;

  bool _cast(value) {
    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value != 0;
    }

    if (value is double) {
      return value.toInt() != 0;
    } else {
      return super._cast(value);
    }
  }

  BoolType _clone({int align}) {
    return new BoolType(_dataModel, align: align);
  }

  bool _compatible(BinaryType other, bool strong) {
    return other is BoolType && other.dataModel == _dataModel;
  }

  String _getKey() {
    return "_Bool";
  }

  bool _getValue(int base, int offset) {
    return new _PhysicalData(base, 0).getInt8(offset) != 0;
  }

  void _initialize(int base, int offset, value) {
    _setValue(base, offset, value);
  }

  void _setValue(int base, int offset, value) {
    if (value is bool) {
      value = value ? 1 : 0;
    } else if (value is double) {
      value = value.toInt() != 0 ? 1 : 0;
    }

    if (value is int) {
      new _PhysicalData(base, 0).setInt8(offset, value);
    } else {
      super._setValue(base, offset, value);
    }
  }
}
