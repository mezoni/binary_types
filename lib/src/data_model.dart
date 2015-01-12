part of binary_types;

/**
 * Data model of binary types.
 */
// TODO: Add??? sizeOfEnum with default sizeOfInt
class DataModel {
  int _alignOfPointer;

  int _hashCode;

  int _sizeOfLong;

  int _sizeOfPointer;

  /**
   * Returns the alignment of data for the binary type "double".
   */
  final int alignOfDouble;

  /**
   * Returns the alignment of data for the binary type "float".
   */
  final int alignOfFloat;

  /**
   * Returns the alignment of data for the binary type "16-bit integer".
   */
  final int alignOfInt16;

  /**
   * Returns the alignment of data for the binary type "32-bit integer".
   */
  final int alignOfInt32;

  /**
   * Returns the alignment of data for the binary type "64-bit integer".
   */
  final int alignOfInt64;

  /**
   * Returns the alignment of data for the binary type "8-bit integer".
   */
  final int alignOfInt8;

  /**
   * Indicates when the binary type "char" is a signed type.
   */
  final bool isCharSigned;

  /**
   * Returns the size of the binary type "char".
   */
  final int sizeOfChar;

  /**
   * Returns the size of the binary type "double".
   */
  final int sizeOfDouble;

  /**
   * Returns the size of the binary type "float".
   */
  final int sizeOfFloat;

  /**
   * Returns the size of the binary type "int".
   */
  final int sizeOfInt;

  /**
   * Returns the size of the binary type "long long int".
   */
  final int sizeOfLongLong;

  /**
   * Returns the size of the binary type "short int".
   */
  final int sizeOfShort;

  DataModel({this.alignOfDouble: 8, this.alignOfFloat: 4, this.alignOfInt16: 2, this.alignOfInt32: 4, this.alignOfInt64: 8, this.alignOfInt8: 1, this.isCharSigned: true, this.sizeOfChar: 1, this.sizeOfDouble: 8, this.sizeOfFloat: 4, this.sizeOfInt: 4, int sizeOfLong, this.sizeOfLongLong: 8, this.sizeOfShort: 2}) {
    var sizeOfPointer = Unsafe.sizeOfPointer;
    _alignOfPointer = sizeOfPointer;
    _sizeOfPointer = sizeOfPointer;
    switch (sizeOfPointer) {
      case 4:
        _sizeOfLong = sizeOfLong == null ? 4 : sizeOfLong;
        break;
      case 8:
        _sizeOfLong = sizeOfLong == null ? 8 : sizeOfLong;
        break;
      default:
        throw new UnsupportedError("Unsupported size of pointer: ${sizeOfPointer}");
    }
  }

  /**
   * Returns the alignment of data for the binary type "pointer".
   */
  int get alignOfPointer => _alignOfPointer;

  int get hashCode {
    if (_hashCode == null) {
      _hashCode = _calculateHashCode();
    }

    return _hashCode;
  }

  /**
   * Returns the size of the binary type "long int".
   */
  int get sizeOfLong => _sizeOfLong;

  /**
   * Returns the size of the binary type "pointer".
   */
  int get sizeOfPointer => _sizeOfPointer;

  bool operator ==(other) {
    if (other is DataModel) {
      return hashCode == other.hashCode;
    }

    return false;
  }

  int _calculateHashCode() {
    var hashCode = 0;
    var list = new List<int>(15);
    list[0] = alignOfInt8;
    list[1] = alignOfInt16;
    list[2] = alignOfInt32;
    list[3] = alignOfInt64;
    list[4] = alignOfDouble;
    list[5] = alignOfFloat;
    list[6] = alignOfPointer;
    list[7] = sizeOfChar;
    list[8] = sizeOfShort;
    list[9] = sizeOfInt;
    list[10] = sizeOfLong;
    list[11] = sizeOfLongLong;
    list[12] = sizeOfDouble;
    list[13] = sizeOfFloat;
    list[14] = sizeOfPointer;
    for (var i = 0; i < 15; i++) {
      var value = list[i];
      while (value != 0) {
        hashCode <<= 1;
        hashCode |= value & 1;
        value >>= 1;
      }
    }

    hashCode <<= 1;
    hashCode |= isCharSigned ? 0 : 1;
    return hashCode;
  }
}
