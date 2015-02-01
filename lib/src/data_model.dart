part of binary_types;

/**
 * Data model of binary types.
 */
// TODO: Add??? sizeOfEnum with default sizeOfInt
class DataModel {
  static final DataModel current = new DataModel();

  static Map<int, DataModel> _dataModels = <int, DataModel>{};

  /**
   * Alignment of data for the binary type "double".
   */
  final int alignOfDouble;

  /**
   * Alignment of data for the binary type "float".
   */
  final int alignOfFloat;

  /**
   * Alignment of data for the binary type "16-bit integer".
   */
  final int alignOfInt16;

  /**
   * Alignment of data for the binary type "32-bit integer".
   */
  final int alignOfInt32;

  /**
   * Alignment of data for the binary type "64-bit integer".
   */
  final int alignOfInt64;

  /**
   * Alignment of data for the binary type "8-bit integer".
   */
  final int alignOfInt8;

  /**
   * Alignment of data for the binary type "pointer".
   */
  final int alignOfPointer;

  /**
   * Indicates when the binary type "char" is a signed type.
   */
  final bool isCharSigned;

  /**
   * Size of the binary type "char".
   */
  final int sizeOfChar;

  /**
   * Size of the binary type "double".
   */
  final int sizeOfDouble;

  /**
   * Size of the binary type "float".
   */
  final int sizeOfFloat;

  /**
   * Size of the binary type "int".
   */
  final int sizeOfInt;

  /**
   * Size of the binary type "long long int".
   */
  final int sizeOfLongLong;

  /**
   * Size of the binary type "short int".
   */
  final int sizeOfShort;

  /**
   * Size of the binary type "long int".
   */
  final int sizeOfLong;

  /**
   * Size of the binary type "pointer".
   */
  final int sizeOfPointer;

  factory DataModel({int alignOfDouble: 8, int alignOfFloat: 4, int alignOfInt16: 2, int alignOfInt32: 4, int alignOfInt64: 8, int alignOfInt8: 1, int alignOfPointer, bool isCharSigned: true, int sizeOfChar: 1, int sizeOfDouble: 8, int sizeOfFloat: 4, int sizeOfInt: 4, int sizeOfLong, int sizeOfLongLong: 8, int sizeOfPointer, int sizeOfShort: 2}) {
    if (sizeOfPointer == null) {
      sizeOfPointer = Unsafe.sizeOfPointer;
    }

    if (alignOfPointer == null) {
      alignOfPointer = sizeOfPointer;
    }

    switch (sizeOfPointer) {
      case 4:
        sizeOfLong = sizeOfLong == null ? 4 : sizeOfLong;
        break;
      case 8:
        sizeOfLong = sizeOfLong == null ? 8 : sizeOfLong;
        break;
      default:
        throw new UnsupportedError("Unsupported size of pointer: ${sizeOfPointer}");
    }

    var key = 0;
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
        key <<= 1;
        key |= value & 1;
        value >>= 1;
      }
    }

    key <<= 1;
    key |= isCharSigned ? 0 : 1;
    var dataModel = _dataModels[key];
    if (dataModel == null) {
      dataModel = new DataModel._internal(alignOfDouble: alignOfDouble, alignOfFloat: alignOfFloat, alignOfInt16: alignOfInt16, alignOfInt32: alignOfInt32, alignOfInt64: alignOfInt64, alignOfInt8: alignOfInt8, alignOfPointer: alignOfPointer, isCharSigned: isCharSigned, sizeOfChar: sizeOfChar, sizeOfDouble: sizeOfDouble, sizeOfFloat: sizeOfFloat, sizeOfInt: sizeOfInt, sizeOfLong: sizeOfLong, sizeOfLongLong: sizeOfLongLong, sizeOfPointer: sizeOfPointer, sizeOfShort: sizeOfShort);
      _dataModels[key] = dataModel;
    }

    return dataModel;
  }

  DataModel._internal({this.alignOfDouble, this.alignOfFloat, this.alignOfInt16, this.alignOfInt32, this.alignOfInt64, this.alignOfInt8, this.alignOfPointer, this.isCharSigned, this.sizeOfChar, this.sizeOfDouble, this.sizeOfFloat, this.sizeOfInt, this.sizeOfLong, this.sizeOfLongLong, this.sizeOfPointer, this.sizeOfShort});
}
