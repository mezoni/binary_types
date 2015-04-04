part of binary_types;

class BinaryObject extends BinaryData {
  factory BinaryObject._alloc(BinaryType type, [value]) {
    var address;
    var size = type.size;
    if (size > 0) {
      address = Unsafe.memoryAllocate(size);
    } else {
      BinaryTypeError.unableAllocateMemoryForIncompleteType(type);
    }

    var object = new BinaryObject._internal(type, address, 0);
    Unsafe.memoryPeer(object, address, size);
    if (value != null) {
      type._initialize(object.base, object.offset, value);
    }

    return object;
  }
  
  BinaryObject._internal(BinaryType type, int base, int offset) : super._internal(type, base, offset);

  /**
   * Does not do anything. Can be used for preventing deallocation of binary data by the garbage collector.
   */
  void keepAlive() {
    // Nothing, but still keep data alive.
  }

  String toString() => super.toString();
}
