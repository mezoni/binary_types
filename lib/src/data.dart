part of binary_types;

/**
 * Binary data of the specified binary type.
 */
class BinaryData {
  final int base;

  final int offset;

  final BinaryType type;

  BinaryData._internal(this.type, this.base, this.offset);

  /**
   * Returns the memory address of this binary data.
   */
  int get address {
    if (offset == 0) {
      return base;
    }

    return base + offset;
  }

  /**
   * Reads the data from the memory and returns the converted value.
   */
  // TODO: Provide the alternative accessor with shorter name
  dynamic get value {
    return type._getValue(base, offset);
  }

  /**
   * Converts the value and stores it in the memory.
   */
  // TODO: Provide the alternative accessor with shorter name
  void set value(value) {
    type._setValue(base, offset, value);
  }

  bool operator ==(other) {
    return type._compareContent(base, offset, other);
  }

  BinaryData operator [](index) {
    return type._getElement(base, offset, index);
  }

  bool get isNullPtr {
    if (base != 0) {
      return false;
    }

    return offset == 0;
  }

  void operator []=(index, value) {
    type._setElement(base, offset, index, value);
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
    return type._getElementValue(base, offset, index);
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
    type._setElementValue(base, offset, index, value);
  }

  String toString() => type.formatName(pointers: 1);
}
