part of binary_types;

class BinaryTypeHelper {
  final BinaryTypes types;

  BinaryType _char;

  DataModel _dataModel;

  BinaryTypeHelper(this.types) {
    if (types == null) {
      throw new ArgumentError.notNull("types");
    }

    _char = types["char"];
    _dataModel = types["int"].dataModel;
  }

  /**
   * Data model of binary types.
   */
  DataModel get dataModel => _dataModel;

  /**
   * Allocates the memory for null-terminated string and returns the binary
   * array object.
   *
   * Parameters:
   *   [String] string
   *   String to allocate.
   */
  BinaryObject allocString(String string) {
    if (string == null) {
      throw new ArgumentError.notNull("string");
    }

    var characters = string.codeUnits;
    var length = characters.length;
    var address = Unsafe.memoryAllocate(length + 1);
    return _char.array(characters.length + 1).alloc(characters);
  }

  /**
     * DEPRECATED! Use "binary declarations" instead
     *
     * Declares the "function" binary type.
     *
     * Parameters:
     *   [BinaryType] returnType
     *   Type of return value.
     *
     *   [List]<[BinaryType]> parameters
     *   Function parameters.
     */
  @deprecated
  // TODO: Register function in types
  FunctionType declareFunc(String name, BinaryType returnType, List<BinaryType> parameters) {
    return new FunctionType(name, returnType, parameters, dataModel);
  }

  /**
   * DEPRECATED! Use "binary declarations" instead
   *
   * Declares the "struct" binary type.
   *
   * Parameters:
   *   [String] name
   *   Name of the struct.
   *
   *   [Map]<[String], [BinaryType]> members
   *   [Map]<[String], [String]> members
   *   [List]<[StructureMember]> members
   *   Members to the struct.
   *
   *   [int] align
   *   Data alignment for this type.
   *
   *   [int] pack
   *   Data structure padding.
   */
  @deprecated
  StructType declareStruct(String name, members, {int align, bool packed: false}) {
    BinaryType type;
    if (name != null) {
      type = _tryGetType("struct $name");
    }

    if (type is! StructType) {
      type = new StructType(name, null, dataModel, align: align, packed: packed);
      if (name != null) {
        types.registerType(type);
      }
    }

    if (members != null) {
      _addMembers(type, members, packed);
    }

    return type;
  }

  /**
   * DEPRECATED! Use "binary declarations" instead
   *
   * Declares the "union" binary type.
   *
   * Parameters:
   *   [String] name
   *   Name of the union.
   *
   *   [Map]<[String], [BinaryType]> members
   *   [Map]<[String], [String]> members
   *   [List]<[StructureMember]> members
   *   Members to the struct.
   *
   *   [int] align
   *   Data alignment for this type.
   *
   *   [int] pack
   *   Data structure padding.
   */
  @deprecated
  UnionType declareUnion(String name, members, {int align, bool packed}) {
    BinaryType type;
    if (name != null) {
      type = _tryGetType("union $name");
    }

    if (type is! UnionType) {
      type = new UnionType(name, null, dataModel, align: align, packed: packed);
      if (name != null) {
        types.registerType(type);
      }
    }

    if (members != null) {
      _addMembers(type, members, packed);
    }

    return type;
  }

  /**
   * Returns true if the binary type is declared; otherwise: false.
   *
   * Parameters:
   *   [String] name
   *   Name of the binary type.
   */
  @deprecated
  bool isTypeDeclared(String name) {
    if (name == null) {
      throw new ArgumentError.notNull("name");
    }

    try {
      var type = types[name];
    } catch (e) {
      return false;
    }

    return true;
  }

  /**
   * Reads the null-terminated string from memory.
   *
   * Parameters:
   *   [Reference] reference
   *   Reference to the null-terminated string.
   */
  String readString(BinaryData data) {
    if (data == null) {
      throw new ArgumentError.notNull("reference");
    }

    var type = data.type;
    if (type is ArrayType) {
      type = type.type;
    }

    if (type is! IntType) {
      throw new ArgumentError("Referenced type '$type' should be integer type");
    }

    var base = data.base;
    var offset = data.offset;
    var size = type.size;
    var characters = <int>[];
    var index = 0;
    while (true) {
      var value = type.getValue(base, offset);
      if (value == 0) {
        break;
      }

      characters.add(value);
      offset += size;
    }

    return new String.fromCharCodes(characters);
  }

  void _addMembers(StructureType type, members, bool packed) {
    if (members is Map<String, dynamic>) {
      var normalizedMembers = <String, BinaryType>{};
      for (var name in members.keys) {
        normalizedMembers[name] = _getType(members[name]);
      }

      type.addMembers(normalizedMembers, packed: packed);
    } else if (members is List<StructureMember>) {
      type.addMembers(members, packed: packed);
    } else {
      throw new ArgumentError.value(members, "members");
    }
  }

  BinaryType _getType(type, [BinaryType defaultType]) {
    if (type is String) {
      return types[type];
    } else if (type is BinaryType) {
      return type;
    }

    if (defaultType != null) {
      return defaultType;
    }

    throw new ArgumentError("type: $type");
  }

  BinaryType _tryGetType(String name) {
    try {
      return types[name];
    } catch (s) {
    }

    return null;
  }
}
