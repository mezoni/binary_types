part of binary_types;

/**
 * Data model of binary types.
 */
// TODO: Add??? sizeOfEnum with default sizeOfInt
class DataModel {
  static final DataModel current = new DataModel();

  static Map<String, Object> _ids = <String, Object>{};

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

  Object _id;

  factory DataModel({int alignOfDouble: 8, int alignOfFloat: 4, int alignOfInt16: 2, int alignOfInt32: 4,
      int alignOfInt64: 8, int alignOfInt8: 1, int alignOfPointer, bool isCharSigned: true, int sizeOfChar: 1,
      int sizeOfDouble: 8, int sizeOfFloat: 4, int sizeOfInt: 4, int sizeOfLong, int sizeOfLongLong: 8,
      int sizeOfPointer, int sizeOfShort: 2}) {
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

    var dataModel = new DataModel._internal(
        alignOfDouble: alignOfDouble,
        alignOfFloat: alignOfFloat,
        alignOfInt16: alignOfInt16,
        alignOfInt32: alignOfInt32,
        alignOfInt64: alignOfInt64,
        alignOfInt8: alignOfInt8,
        alignOfPointer: alignOfPointer,
        isCharSigned: isCharSigned,
        sizeOfChar: sizeOfChar,
        sizeOfDouble: sizeOfDouble,
        sizeOfFloat: sizeOfFloat,
        sizeOfInt: sizeOfInt,
        sizeOfLong: sizeOfLong,
        sizeOfLongLong: sizeOfLongLong,
        sizeOfPointer: sizeOfPointer,
        sizeOfShort: sizeOfShort);
    return dataModel;
  }

  DataModel._internal({this.alignOfDouble, this.alignOfFloat, this.alignOfInt16, this.alignOfInt32, this.alignOfInt64,
      this.alignOfInt8, this.alignOfPointer, this.isCharSigned, this.sizeOfChar, this.sizeOfDouble, this.sizeOfFloat,
      this.sizeOfInt, this.sizeOfLong, this.sizeOfLongLong, this.sizeOfPointer, this.sizeOfShort});

  int get hashCode {
    return id.hashCode;
  }

  Object get id {
    if (_id == null) {
      var sb = new StringBuffer();
      sb.write(alignOfDouble);
      sb.write("|");
      sb.write(alignOfFloat);
      sb.write("|");
      sb.write(alignOfInt16);
      sb.write("|");
      sb.write(alignOfInt32);
      sb.write("|");
      sb.write(alignOfInt64);
      sb.write("|");
      sb.write(alignOfInt8);
      sb.write("|");
      sb.write(alignOfPointer);
      sb.write("|");
      sb.write(isCharSigned);
      sb.write("|");
      sb.write(sizeOfChar);
      sb.write("|");
      sb.write(sizeOfDouble);
      sb.write("|");
      sb.write(sizeOfFloat);
      sb.write("|");
      sb.write(sizeOfInt);
      sb.write("|");
      sb.write(sizeOfLong);
      sb.write("|");
      sb.write(sizeOfLongLong);
      sb.write("|");
      sb.write(sizeOfPointer);
      sb.write("|");
      sb.write(sizeOfShort);
      var key = sb.toString();
      _id = _ids[key];
      if (_id == null) {
        _id = new Object();
        _ids[key] = _id;
      }
    }

    return _id;
  }

  bool operator ==(other) {
    if (other is DataModel) {
      return id == other.id;
    }

    return false;
  }
}
