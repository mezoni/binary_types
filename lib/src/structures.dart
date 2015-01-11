part of binary_types;

/**
 * Struct binary type.
 */
class StructType extends StructureType {
  List<int> _offsets;

  Map<String, int> _ordinals;

  int _size = 0;

  List<BinaryType> _types;

  StructType(String tag, Map<String, BinaryType> members, DataModel dataModel, {int align, String name, int pack}) : this._internal(tag, members, dataModel, null, align: align, name: name, pack: pack);

  StructType._internal(String tag, Map<String, BinaryType> members, DataModel dataModel, StructureType original, {int align, String name, int pack}) : super("struct", tag, dataModel, original, align: align, name: name) {
    _offsets = new List<int>();
    _ordinals = new LinkedHashMap<String, int>();
    _types = new List<BinaryType>();

    if (members != null) {
      addMembers(members, pack: pack);
    }
  }

  int get size => _size;

  void addMembers(Map<String, BinaryType> members, {int pack}) {
    super._addMembers(members, pack: pack);
    var align = _align;
    var index = 0;
    var largestAlign = 0;
    var offset = 0;
    for (var name in _members.keys) {
      var type = _members[name];
      _ordinals[name] = index++;
      _types.add(type);
      var typeAlign = type.align;
      if (_pack != null && typeAlign > _pack) {
        typeAlign = _pack;
      }

      if (largestAlign < typeAlign) {
        largestAlign = typeAlign;
      }

      var rest = offset % typeAlign;
      if (rest != 0) {
        offset = offset - rest + typeAlign;
      }

      _offsets.add(offset);
      offset += type.size;
    }

    _align = largestAlign;
    _size = offset;
    var rest = _size % largestAlign;
    if (rest != 0) {
      _size = size - rest + largestAlign;
    }

    if (align != null) {
      if (_align < align) {
        _align = align;
      }
    }

    if (_size < _align) {
      _size = _align;
    }
  }

  StructType _clone(String name, {int align}) {
    if (members.isEmpty) {
      BinaryTypeError.unableCloneIncompleteType(this);
    }

    // TODO:
    return new StructType._internal(tag, members, _dataModel, _original, align: align, name: name, pack: _pack);
  }

  BinaryData _getElement(int base, int offset, index) {
    if (index is String) {
      var i = _ordinals[index];
      if (i == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      return new BinaryData._internal(_types[i], base, offset + _offsets[i]);
    } else {
      return super._getElement(base, offset, index);
    }
  }

  dynamic _getElementValue(int base, int offset, index) {
    if (index is String) {
      var i = _ordinals[index];
      if (i == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      return _types[i]._getValue(base, offset + _offsets[i]);
    } else {
      return super._getElementValue(base, offset, index);
    }
  }

  Map _getValue(int base, int offset) {
    var value = {};
    for (var name in _ordinals.keys) {
      var i = _ordinals[name];
      value[name] = _types[i]._getValue(base, offset + _offsets[i]);
    }

    return value;
  }

  void _initialize(int base, int offset, value) {
    Unsafe.memorySet(base, offset, 0, size);
    if (value is Map) {
      for (var name in value.keys) {
        if (!_members.containsKey(name)) {
          BinaryTypeError.memberNotFound(this, name);
        }

        var index = _ordinals[name];
        _types[index]._initialize(base, offset + _offsets[index], value[name]);
      }

    } else if (value is List) {
      if (value.length > _members.length) {
        BinaryTypeError.valueLengthExceedsNumberOfMembers(this, _members.length, value.length);
      }

      var length = value.length;
      for (var i = 0; i < length; i++) {
        _types[i]._initialize(base, offset + _offsets[i], value[i]);
      }

    } else {
      super._initialize(base, offset, value);
    }
  }

  int _offsetOf(String memberName) {
    var i = _ordinals[memberName];
    if (i == null) {
      BinaryTypeError.memberNotFound(this, memberName);
    }

    return _offsets[i];
  }

  void _setElement(int base, int offset, index, value) {
    if (index is String) {
      var i = _ordinals[index];
      if (i == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      _types[i]._setContent(base, offset + _offsets[i], value);
    } else {
      super._setElement(base, offset, index, value);
    }
  }

  void _setElementValue(int base, int offset, index, value) {
    if (index is String) {
      var i = _ordinals[index];
      if (i == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      _types[i]._setValue(base, offset + _offsets[i], value);
    } else {
      super._setElementValue(base, offset, index, value);
    }
  }

  void _setValue(int base, int offset, value) {
    if (value is Map) {
      if (_members.length != value.length) {
        BinaryTypeError.valueLengthMustBeEqualNumberOfMembers(this, _members.length, value.length);
      }

      for (var index in value.keys) {
        var i = _ordinals[index];
        if (i == null) {
          BinaryTypeError.memberNotFound(this, index);
        }

        _types[i]._setValue(base, offset + _offsets[i], value[index]);
      }

    } else {
      super._setValue(base, offset, value);
    }
  }
}

/**
 * Structure binary type.
 */
abstract class StructureType extends BinaryType {
  Map<String, BinaryType> _members;

  StructureType _original;

  int _pack;

  String _tag;

  StructureType(String kind, String tag, DataModel dataModel, StructureType original, {int align, String name}) : super(dataModel, align: align, name: name) {
    if (tag != null && tag.isEmpty) {
      throw new ArgumentError("Name should be not empty string or unspecified.");
    }

    if (name == null) {
      if (tag != null) {
        _name = "$kind $tag";
      } else {
        _name = "$kind <unnamed>";
      }

      _namePrefix = "$_name ";
    }

    if (original == null) {
      original = this;
    }

    _members = new LinkedHashMap<String, BinaryType>();
    _original = original;
    _tag = tag;
  }

  dynamic get defaultValue {
    if (_members.length == 0) {
      BinaryTypeError.unableGetDefaultValueForIncompleteType(this);
    }

    var value = {};
    for (var name in members.keys) {
      value[name] = members[name].defaultValue;
    }

    return value;
  }

  BinaryKinds get kind => BinaryKinds.STRUCT;

  /**
   * Returns the members of the structural binary type.
   */
  Map<String, BinaryType> get members => new UnmodifiableMapView(_members);

  /**
   * Returns the data structure padding.
   */
  int get pack => _pack;

  /**
   * Returns the tag.
   */
  String get tag => _tag;

  bool operator ==(other) {
    if (other is StructureType) {
      return _compatible(other, true);
    }

    return false;
  }

  /**
   * Adds the members to the incomplete structured binary type.
   *
   * Parameters:
   *   [Map]<[String], [BinaryType]> members
   *   Members to add.
   *
   *   [int] pack
   *   Data structure padding.
   */
  void addMembers(Map<String, BinaryType> members, {int pack});

  void _addMembers(Map<String, BinaryType> members, {int pack}) {
    if (members == null) {
      throw new ArgumentError("members: $members");
    }

    if (members.length == 0) {
      BinaryTypeError.requiresAtLeastOneMember(this);
    }

    if (_members.length != 0) {
      BinaryTypeError.redefinitionOfMembersIsNotAllowed(this);
    }

    if (pack != null) {
      var powerOf2 = (pack != 0) && ((pack & (pack - 1)) == 0);
      if (!powerOf2) {
        throw new ArgumentError("Pack '$pack' should be power of 2 value.");
      }
    }

    _pack = pack;
    for (var name in members.keys) {
      if (name is! String || name.isEmpty) {
        BinaryTypeError.illegalMemberName(this, name);
      }

      var type = members[name];
      if (type == null) {
        throw new ArgumentError("List of members contains illegal elements.");
      }

      if (type.size == 0) {
        BinaryTypeError.incompleteMemberType(this, name, type);
      }

      if (type.dataModel != dataModel) {
        BinaryTypeError.differentDataModel("member $type '$name'");
      }
    }

    _members.addAll(members);
  }

  bool _compatible(BinaryType other, bool strong) {
    return other is StructureType && identical(_original, other._original);
  }

  void _setContent(int base, int offset, value) {
    if (value is BinaryData && value.type == this) {
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
}

/**
 * Union binary type.
 */
class UnionType extends StructureType {
  String _largest;

  int _size = 0;

  UnionType(String tag, Map<String, BinaryType> members, DataModel dataModel, {int align, String name, int pack}) : this._internal(tag, members, dataModel, null, align: align, name: name, pack: pack);

  UnionType._internal(String tag, Map<String, BinaryType> members, DataModel dataModel, StructureType original, {int align, String name, int pack}) : super("union", tag, dataModel, original, align: align, name: name) {
    if (members != null) {
      addMembers(members, pack: pack);
    }
  }

  int get size => _size;

  void addMembers(Map<String, BinaryType> members, {int pack}) {
    super._addMembers(members, pack: pack);
    var align = _align;
    var largestAlign = 0;
    for (var name in members.keys) {
      var type = members[name];
      var typeSize = type.size;
      if (typeSize > _size) {
        _size = typeSize;
        _largest = name;
      }

      var typeAlign = type.align;
      if (_pack != null && typeAlign > _pack) {
        typeAlign = _pack;
      }

      if (largestAlign < typeAlign) {
        largestAlign = typeAlign;
      }
    }

    _align = largestAlign;
    var rest = _size % largestAlign;
    if (rest != 0) {
      _size = size - rest + largestAlign;
    }

    if (align != null) {
      if (_align < align) {
        _align = align;
      }
    }

    if (_size < _align) {
      _size = _align;
    }
  }

  UnionType _clone(String name, {int align}) {
    if (members.isEmpty) {
      BinaryTypeError.unableCloneIncompleteType(this);
    }

    // TODO:
    return new UnionType._internal(tag, _members, _dataModel, _original, align: align, name: name, pack: _pack);
  }

  BinaryData _getElement(int base, int offset, index) {
    if (index is String) {
      var type = _members[index];
      if (type == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      return new BinaryData._internal(type, base, offset);
    } else {
      return super._getElement(base, offset, index);
    }
  }

  dynamic _getElementValue(int base, int offset, index) {
    if (index is String) {
      var type = _members[index];
      if (type == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      return type._getValue(base, offset);
    } else {
      return super._getElementValue(base, offset, index);
    }
  }

  Map _getValue(int base, int offset) {
    var value = {};
    value[_largest] = _members[_largest]._getValue(base, offset);
    return value;
  }

  void _initialize(int base, int offset, value) {
    Unsafe.memorySet(base, offset, 0, size);
    if (value is Map) {
      if (value.length != 1) {
        BinaryTypeError.onlyOneMemberOfUnionCanBeInitialized();
      }

      var name = value.keys[0];
      var type = _members[name];
      if (type == null) {
        BinaryTypeError.memberNotFound(this, name);
      }

      type._initialize(base, offset, value[name]);
    } else if (value is List) {
      if (value.length != 1) {
        BinaryTypeError.onlyFirstMemberOfUnionCanBeInitialized();
      }

      var name;
      for (name in _members.keys) {
        break;
      }

      var type = _members[name];
      type._initialize(base, offset, value[0]);
    } else {
      super._initialize(base, offset, value);
    }
  }

  int _offsetOf(String memberName) {
    if (_members[memberName] == null) {
      BinaryTypeError.memberNotFound(this, memberName);
    }

    return 0;
  }

  void _setElement(int base, int offset, index, value) {
    if (index is String) {
      var type = _members[index];
      if (type == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      type._setContent(base, offset, value);
    } else {
      super._setElement(base, offset, index, value);
    }
  }

  dynamic _setElementValue(int base, int offset, index, value) {
    if (index is String) {
      var type = _members[index];
      if (type == null) {
        BinaryTypeError.memberNotFound(this, index);
      }

      return type._setValue(base, offset, value);
    } else {
      return super._getElementValue(base, offset, index);
    }
  }

  void _setValue(int base, int offset, value) {
    if (value is Map) {
      for (var name in value.keys) {
        var type = _members[name];
        if (type == null) {
          BinaryTypeError.memberNotFound(this, name);
        }

        type._setValue(base, offset, value[name]);
      }
    } else if (value is List) {
    } else {
      super._setValue(base, offset, value);
    }
  }
}
