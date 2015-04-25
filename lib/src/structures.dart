part of binary_types;

/**
 * Struct binary type.
 */
class StructType extends StructureType {
  /**
   * Creates new instantce of the binary struct type.
   *
   * Parameters:
   *   [String] tag
   *   Tag of the struct type.
   *
   *   [DataModel] dataModel
   *   Data model of binary type.
   *
   *   [int] align
   *   Data alignment for binary type.
   *
   *   [int] pack
   *   Data padding for binary type.
   */
  StructType(String tag, DataModel dataModel, {int align}) : super("struct", tag, dataModel, align: align);

  StructType _clone({int align}) {
    var clone = new StructType(tag, _dataModel, align: align);
    clone._key = _getKey();
    return clone;
  }

  Map _getValue(int base, int offset) {
    var value = {};
    for (var member in members.values) {
      value[member.name] = _getMemberValue(member, base, offset);
    }

    return value;
  }

  void _initialize(int base, int offset, value) {
    Unsafe.memorySet(base, offset, 0, size);
    if (value is Map<String, dynamic>) {
      for (var key in value.keys) {
        var member = members[key];
        if (member == null) {
          BinaryTypeError.memberNotFound(this, key);
        }

        _initializeMember(member, base, offset, value[key]);
      }
    } else if (value is List) {
      var length = value.length;
      var members = this.members.values.toList();
      if (length > members.length) {
        BinaryTypeError.valueLengthExceedsNumberOfMembers(this, members.length, length);
      }

      for (var i = 0; i < length; i++) {
        _initializeMember(members[i], base, offset, value[i]);
      }
    } else {
      super._initialize(base, offset, value);
    }
  }

  void _setValue(int base, int offset, value) {
    if (value is Map<String, dynamic>) {
      for (var key in value.keys) {
        if (key is! String) {
          throw new ArgumentError("The map of members contains invalid elements");
        }

        var member = members[key];
        if (member == null) {
          BinaryTypeError.memberNotFound(this, key);
        }

        _setMemberValue(member, base, offset, value[key]);
      }
    } else {
      super._setValue(base, offset, value);
    }
  }
}

class StructureMember {
  /**
   * Data alignment.
   */
  final int align;

  /**
   * Name of the member.
   */
  final String name;

  /**
   * Type of the member.
   */
  final BinaryType type;

  /**
   * Width of the bit-field member.
   */
  final int width;

  int _offset;

  int _position;

  StructureMember(this.name, this.type, {this.align, this.width}) {
    _checkName(name);
    if (type == null) {
      throw new ArgumentError.notNull("type");
    }

    if (align != null) {
      _Utils.checkPowerOfTwo(align, "align");
    }

    if (width != null) {
      if (width < 0) {
        throw new ArgumentError.value(width, "width");
      }

      if (width == 0 && name != null) {
        throw new ArgumentError("Zero-length bit-field '$name' should be unnamed");
      }

      if (!(type is BoolType || type is IntType || type is EnumType)) {
        throw new ArgumentError("Invalid type of the bit-field: ${type.runtimeType}");
      }
    }
  }

  /**
   * Returns true when member is a bit-field; otherwise false.
   */
  bool get isBitFiled => width != null;

  /**
   * Offset of the member.
   */
  int get offset => _offset;

  /**
   * Position of the bit-field.
   */
  int get position => _position;

  void _checkName(String name) {
    if (name != null && name.isEmpty) {
      throw new ArgumentError("Name should be not empty string or unspecified.");
    }
  }
}

/**
 * Structure binary type.
 */
abstract class StructureType extends BinaryType {
  static int _ids = 0;

  String _key;

  /**
   * Tag.
   */
  final String tag;

  Map<String, StructureMember> _members = <String, StructureMember>{};

  int _size = 0;

  StorageUnits _storageUnits;

  StructureType(String kind, this.tag, DataModel dataModel, {int align}) : super(dataModel, align: align) {
    if (tag != null && tag.isEmpty) {
      throw new ArgumentError("Name should be not empty string or unspecified");
    }
  }

  dynamic get defaultValue {
    if (size == 0) {
      BinaryTypeError.unableGetDefaultValueForIncompleteType(this);
    }

    var value = <String, dynamic>{};
    for (var member in members.values) {
      value[member.name] = member.type.defaultValue;
    }

    return value;
  }

  BinaryKind get kind => BinaryKind.STRUCT;

  /**
   * Returns the members of the structural binary type.
   */
  Map<String, StructureMember> get members {
    var original = _original as StructureType;
    return new UnmodifiableMapView<String, StructureMember>(original._members);
  }

  String get name {
    if (_name == null) {
      var sb = new StringBuffer();
      if (this is StructType) {
        sb.write("struct ");
      } else {
        sb.write("union ");
      }

      if (tag != null) {
        sb.write(tag);
      } else {
        sb.write("<unnamed>");
      }

      _name = sb.toString();
    }

    return _name;
  }

  int get size {
    var original = _original as StructureType;
    return original._size;
  }

  /**
   * Returns the storage units of the structural binary type.
   */
  StorageUnits get storageUnits {
    var original = _original as StructureType;
    return original._storageUnits;
  }

  /**
   * Adds the members to the incomplete structured binary type.
   *
   * Parameters:
   *   [Map]<[String], [BinaryType]> members
   *   [List]<[StructureMember]> members
   *   Members to add.
   *
   *   [int] align
   *   Data alignment of structural type.
   *
   *   [bool] packed
   *   Indicates that the structural type are packed or not.
   */
  void addMembers(members, {int align, bool packed: false}) {
    if (members == null) {
      throw new ArgumentError.notNull("members");
    }

    if (!isOriginal) {
      BinaryTypeError.unableModifyTypeSynonym(_original, name);
    }

    if (align != null) {
      _Utils.checkPowerOfTwo(align, "align");
    }

    if (packed == null) {
      throw new ArgumentError.notNull("packed");
    }

    if (this.members.length != 0) {
      BinaryTypeError.unableRedeclareType(name);
    }

    if (members is Map<String, BinaryType>) {
      members = _typesToMembers(members);
    } else if (members is! List<StructureMember>) {
      throw new ArgumentError.value(members, "members");
    }

    members = members as List<StructureMember>;
    _storageUnits = new StorageUnits(members, this, packed: packed);
    _members = storageUnits.members;
    if (members.length == 0) {
      throw new ArgumentError("Members should contain at least one named element");
    }

    var isStruct = this is StructType;
    var largestAlign = 0;
    var largestSize = 0;
    var offset = 0;
    for (var member in storageUnits.members.values) {
      var align = member.align;
      var size = member.type.size;
      if (largestAlign < align) {
        largestAlign = align;
      }

      if (largestSize < size) {
        largestSize = size;
      }

      if (isStruct) {
        offset = _Utils.alignOffset(offset, align);
        offset += size;
      }
    }

    if (isStruct) {
      _size = _Utils.alignOffset(offset, largestAlign);
    } else {
      if (largestAlign > largestSize) {
        _size = largestAlign;
      } else {
        _size = _Utils.alignOffset(largestSize, largestAlign);
      }
    }

    if (align == null) {
      align = largestAlign;
    } else {
      if (align < largestAlign) {
        align = largestAlign;
      }
    }

    _align = align;
    if (_size < _align) {
      _size = _align;
    }
  }

  bool _compatible(BinaryType other, bool strong) {
    if (other is StructureType) {
      if (identical(original, other.original)) {
        return true;
      }
    }

    return false;
  }

  BinaryData _getElement(int base, int offset, index) {
    if (index is String) {
      var member = members[index];
      if (member == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      if (!member.isBitFiled) {
        return new BinaryData._internal(member.type, base, offset + member._offset);
      }
    }

    return super._getElement(base, offset, index);
  }

  dynamic _getElementValue(int base, int offset, index) {
    if (index is String) {
      var member = members[index];
      if (member == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      return _getMemberValue(member, base, offset);
    } else {
      return super._getElementValue(base, offset, index);
    }
  }

  String _getKey() {
    if (_key == null) {
      if (this is UnionType) {
        _key = "union #${_ids++}";
      } else {
        _key = "struct #${_ids++}";
      }

      _ids &= 0x3fffffff;
    }

    return _key;
  }

  dynamic _getMemberValue(StructureMember member, int base, int offset) {
    if (member.isBitFiled) {
      // TODO: throw new UnsupportedError("_getMemberValue() for bit-field");
      throw new UnsupportedError("_getMemberValue() for bit-field");
    } else {
      return member.type._getValue(base, offset + member._offset);
    }
  }

  void _initializeMember(StructureMember member, int base, int offset, value) {
    if (member.isBitFiled) {
      // TODO: throw new UnsupportedError("_initializeMember() for bit-field");
      throw new UnsupportedError("_initializeMember() for bit-field");
    } else {
      member.type._initialize(base, offset + member._offset, value);
    }
  }

  int _offsetOf(String memberName) {
    var member = members[memberName];
    if (member == null) {
      BinaryTypeError.memberNotFound(this, memberName);
    }

    if (member.isBitFiled) {
      BinaryTypeError.unableGetOffsetOfBitFieldMember(this, memberName);
    }

    return member._offset;
  }

  void _setContent(int base, int offset, value) {
    if (value is BinaryData && _compatible(value.type, true)) {
      var dest = base;
      var src = value.base;
      if (offset != 0) {
        dest += offset;
      }

      offset = value.offset;
      if (offset != 0) {
        src += offset;
      }

      Unsafe.memoryMove(dest, src, size);
    } else {
      super._setContent(base, offset, value);
    }
  }

  void _setElement(int base, int offset, index, value) {
    if (index is String) {
      var member = members[index];
      if (member == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      // TODO: BitFiled.setElement()
      if (!member.isBitFiled) {
        member.type._setContent(base, offset + member._offset, value);
        return;
      }
    }

    super._setElement(base, offset, index, value);
  }

  void _setElementValue(int base, int offset, index, value) {
    if (index is String) {
      var member = members[index];
      if (member == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      _setMemberValue(member, base, offset, value);
      return;
    }

    super._setElementValue(base, offset, index, value);
  }

  void _setMemberValue(StructureMember member, int base, int offset, value) {
    if (member.isBitFiled) {
      // TODO: throw new UnsupportedError("_setMemberValue() for bit-field");
      throw new UnsupportedError("_setMemberValue() for bit-field");
    } else {
      member.type._setValue(base, offset + member._offset, value);
    }
  }

  List<StructureMember> _typesToMembers(Map<String, BinaryType> members) {
    var result = <StructureMember>[];
    for (var name in members.keys) {
      var type = members[name];
      if (name is! String || type is! BinaryType) {
        throw new ArgumentError("The list of members contains invalid elements");
      }

      var member = new StructureMember(name, type);
      result.add(member);
    }

    return result;
  }
}

/**
 * Union binary type.
 */
class UnionType extends StructureType {
  /**
   * Creates new instantce of the binary union type.
   *
   * Parameters:
   *   [String] tag
   *   Tag of the struct type.
   *
   *   [DataModel] dataModel
   *   Data model of binary type.
   *
   *   [Map]<[String], [BinaryType]> members
   *   [List]<[StructureMember]> members
   *   Members of the struct type.
   *
   */
  UnionType(String tag, DataModel dataModel, {int align}) : super("union", tag, dataModel, align: align);

  UnionType _clone({int align}) {
    var clone = new UnionType(tag, _dataModel, align: align);
    clone._key = _getKey();
    return clone;
  }

  void _initialize(int base, int offset, value) {
    Unsafe.memorySet(base, offset, 0, size);
    if (value is Map<String, dynamic>) {
      for (var key in value.keys) {
        if (key is! String) {
          throw new ArgumentError("The map of members contains invalid elements");
        }

        var member = members[key];
        if (member == null) {
          BinaryTypeError.memberNotFound(this, key);
        }

        _initializeMember(member, base, offset, value[key]);
      }
    } else {
      super._initialize(base, offset, value);
    }
  }

  void _setValue(int base, int offset, value) {
    if (value is Map<String, dynamic>) {
      for (var key in value.keys) {
        if (key is! String) {
          throw new ArgumentError("The map of members contains invalid elements");
        }

        var member = members[key];
        if (member == null) {
          BinaryTypeError.memberNotFound(this, key);
        }

        _setMemberValue(member, base, offset, value);
      }
    } else {
      super._setValue(base, offset, value);
    }
  }
}
