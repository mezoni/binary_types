part of binary_types;

/**
 * Data model of binary types.
 */
class DataModel {
  int _alignOfPointer;

  int _sizeOfLong;

  int _sizeOfPointer;

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
   * Returns the alignment of data for the binary type "pointer".
   */
  int get alignOfPointer => _alignOfPointer;

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
   * Returns the size of the binary type "long int".
   */
  int get sizeOfLong => _sizeOfLong;

  /**
   * Returns the size of the binary type "long long int".
   */
  final int sizeOfLongLong;

  /**
   * Returns the size of the binary type "pointer".
   */
  int get sizeOfPointer => _sizeOfPointer;

  /**
   * Returns the size of the binary type "short int".
   */
  final int sizeOfShort;
}
