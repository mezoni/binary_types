part of binary_types;

/**
 * The reference is a right-hand side value which are composed from the memory
 * address (base and offset) and the binary type of the referenced value.
 */
class Reference2 {
  final int base;

  final int offset;

  int _address;

  BinaryType _type;

  Reference2(BinaryType type, this.base, this.offset) {
    if (type == null) {
      throw new ArgumentError.notNull("type");
    }

    if (base == null) {
      throw new ArgumentError.notNull("base");
    }

    if (offset == null) {
      throw new ArgumentError.notNull("offset");
    }

    if (type is ArrayType) {
      var arrayType = type;
      type = arrayType.type;
    }

    _type = type;
  }

  Reference2._internal(this._type, this.base, this.offset);

  int get address {
    if (_address == null) {
      _address = base;
      if (offset != 0) {
        _address += offset;
      }
    }

    return _address;
  }

  BinaryType get type => _type;

  dynamic get value {
    return _type.getValue(base, offset);
  }

  void set value(dynamic value) {
    _type.setValue(base, offset, value);
  }

  String toString() {
    var address = _Utils.toHex(this.address);
    return "&$type:$address";
  }
}
