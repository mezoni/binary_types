part of binary_types;

/**
 * Binary data of the specified binary type.
 */
class BinaryData {
  final BinaryType type;

  final int _base;

  final int _offset;

  BinaryData._internal(this.type, this._base, this._offset);

  /**
   * Returns the memory address of this binary data.
   */
  int get address {
    if (_offset == 0) {
      return _base;
    }

    return _base + _offset;
  }

  /**
   * Returns the location of this binary data as a reference.
   */
  Reference get location {
    if (type is ArrayType) {
      var arrayType = type;
      return new Reference._internal(arrayType.type, _base, _offset);
    }

    return new Reference._internal(type, _base, _offset);
  }

  /**
   * Reads the data from the memory and returns the converted value.
   */
  // TODO: Provide the alternative accessor with shorter name
  dynamic get value {
    return type._getValue(_base, _offset);
  }

  /**
   * Converts the value and stores it in the memory.
   */
  // TODO: Provide the alternative accessor with shorter name
  void set value(value) {
    type._setValue(_base, _offset, value);
  }

  bool operator ==(other) {
    return type._compareContent(_base, _offset, other);
  }

  BinaryData operator [](index) {
    return type._getElement(_base, _offset, index);
  }

  Reference operator ~() {
    return location;
  }

  void operator []=(index, value) {
    type._setElement(_base, _offset, index, value);
  }

  /**
   * Reads the data of the element from memory, by index, and returns converted value.
   * value.
   *
   * Parameters:
   *   [dynamic] index
   *   Index of the element.
   */
  dynamic getElementValue(index) {
    return type._getElementValue(_base, _offset, index);
  }

  /**
   * Converts the value of the element, by index, and stores data in memory.
   *
   * Parameters:
   *   [dynamic] index
   *   Index of the element.
   *
   *   [dynamic] value
   *   Value to set.
   */
  void setElementValue(index, value) {
    type._setElementValue(_base, _offset, index, value);
  }

  String toString() => "$type:${_Utils.toHex(_base + _offset)}";
}
