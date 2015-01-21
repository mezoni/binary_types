part of binary_types;

class EnumType extends BinaryType {
  final String tag;

  BinaryType _type;

  Map<String, int> _values;

  EnumType(this.tag, values, DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (values == null) {
      throw new ArgumentError.notNull("values");
    }

    if (values is List) {
      var list = values;
      values = <String, int>{};
      for (var name in list) {
        if (name is String) {
          values[name] = null;
        } else {
          throw new ArgumentError("List of value contains illegal elements.");
        }
      }

    } else if (values is! Map) {
      throw new ArgumentError.value(values, "values");
    }

    // TODO: sizeOfEnum?
    var sizeOfEnum = dataModel.sizeOfInt;
    _type = IntType.create(sizeOfEnum, true, dataModel, align: align);
    var prev = -1;
    var signed = false;
    var max = (1 << (sizeOfEnum * 8 - 1)) - 1;
    var min = -(max + 1);
    _values = <String, int>{};
    for (var name in values.keys) {
      if (name is! String || name.isEmpty) {
        BinaryTypeError.illegalMemberName(this, name);
      }

      var value = values[name];
      if (value is int) {
        prev = value;
      } else if (value == null) {
        value = ++prev;
      } else {
        throw new ArgumentError("List of values contains illegal elements.");
      }

      if (value < 0) {
        signed = true;
      }

      if (value < min || value > max) {
        BinaryTypeError.enumerationValueOutOfRange(this, name, value, _type);
      }

      _values[name] = value;
    }
  }

  int get defaultValue => 0;

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

  int get size => _dataModel.sizeOfInt;

  Map<String, int> get values => new UnmodifiableMapView<String, int>(_values);

  dynamic _cast(value) => _type._cast(value);

  BinaryType _clone({int align}) {
    return new EnumType(tag, values, dataModel);
  }

  bool _compatible(BinaryType other, bool strong) {
    // TODO: Improve
    return identical(this, other);
  }

  int _getTypeElement(String name) {
    var value = _values[name];
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
