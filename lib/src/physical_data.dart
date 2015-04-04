part of binary_types;

/**
 * External byte data sequence with unlimited access to hardware memory.
 *
 * Allows access to the data in both directions with positive and negative
 * offsets.
 *
 * Length of the byte sequence always set to the maximum size of the
 * addressable memory.
 */
class _PhysicalData implements ByteData {
  /**
   * Base address of the hardware memory.
   */
  final int base;

  final int elementSizeInBytes = 8;

  /**
   * Displacement from the base of the hardware memory.
   */
  final offsetInBytes;

  int _address;

  _PhysicalData(this.base, this.offsetInBytes) {
    if (base == null) {
      throw new ArgumentError.notNull("base");
    }

    if (offsetInBytes == null) {
      throw new ArgumentError.notNull("offsetInBytes");
    }
  }

  int get address {
    if (_address == null) {
      if (offsetInBytes == 0) {
        _address = base;
      } else {
        _address = base + offsetInBytes;
      }
    }

    return _address;
  }

  /**
   * Not implemented yet.
   */
  ByteBuffer get buffer {
    throw new UnsupportedError("get buffer");
  }

  /**
   * Returns the length in bytes. Intentionally always as the maximum size of
   * the addressable memory.
   */
  int get lengthInBytes => 1 << Unsafe.sizeOfPointer;

  double getFloat32(int byteOffset, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.readFloat32(base, offsetInBytes + byteOffset);
  }

  double getFloat64(int byteOffset, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.readFloat64(base, offsetInBytes + byteOffset);
  }

  int getInt16(int byteOffset, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.readInt16(base, offsetInBytes + byteOffset);
  }

  int getInt32(int byteOffset, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.readInt32(base, offsetInBytes + byteOffset);
  }

  int getInt64(int byteOffset, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.readInt64(base, offsetInBytes + byteOffset);
  }

  int getInt8(int byteOffset) {
    return Unsafe.readInt8(base, offsetInBytes + byteOffset);
  }

  int getUint16(int byteOffset, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.readUint16(base, offsetInBytes + byteOffset);
  }

  int getUint32(int byteOffset, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.readUint32(base, offsetInBytes + byteOffset);
  }

  int getUint64(int byteOffset, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.readUint64(base, offsetInBytes + byteOffset);
  }

  int getUint8(int byteOffset) {
    return Unsafe.readUint8(base, offsetInBytes + byteOffset);
  }

  void setFloat32(int byteOffset, double value, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.writeFloat32(base, offsetInBytes + byteOffset, value);
  }

  void setFloat64(int byteOffset, double value, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.writeFloat64(base, offsetInBytes + byteOffset, value);
  }

  void setInt16(int byteOffset, int value, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.writeInt16(base, offsetInBytes + byteOffset, value);
  }

  void setInt32(int byteOffset, int value, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.writeInt32(base, offsetInBytes + byteOffset, value);
  }

  void setInt64(int byteOffset, int value, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.writeInt64(base, offsetInBytes + byteOffset, value);
  }

  void setInt8(int byteOffset, int value) {
    return Unsafe.writeInt8(base, offsetInBytes + byteOffset, value);
  }

  void setUint16(int byteOffset, int value, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.writeUint16(base, offsetInBytes + byteOffset, value);
  }

  void setUint32(int byteOffset, int value, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.writeUint32(base, offsetInBytes + byteOffset, value);
  }

  void setUint64(int byteOffset, int value, [Endianness endian = null]) {
    if (endian != null && !identical(endian, Endianness.HOST_ENDIAN)) {
      throw new ArgumentError("Endianness should be the same as the byte order on the machine");
    }

    return Unsafe.writeUint64(base, offsetInBytes + byteOffset, value);
  }

  void setUint8(int byteOffset, int value) {
    return Unsafe.writeUint8(base, offsetInBytes + byteOffset, value);
  }
}
