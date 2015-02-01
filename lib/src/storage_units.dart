part of binary_types;

/**
 * Storage unit is an addressable storage unit.
 */
class StorageUnit {
  /**
   * Alignment of the storage unit.
   */
  final int align;

  /**
   * Binary type of the storage unit.
   */
  final BinaryType type;

  /**
   * Creates new storage unit.
   *
   * Parameters:
   *   [BinaryType] type
   *   Binary type of the storage unit.
   *
   *   [int] align
   *   Alignment of the storage unit.
   */
  StorageUnit(this.type, this.align) {
    if (type == null) {
      throw new ArgumentError.notNull("type");
    }

    if (align == null) {
      throw new ArgumentError.notNull("align");
    }

    if (align < 0) {
      throw new ArgumentError.value(align, "align");
    }

    var powerOf2 = (align != 0) && ((align & (align - 1)) == 0);
    if (!powerOf2) {
      throw new ArgumentError("Align '$align' should be power of 2 value.");
    }
  }

  /**
   * Returns the size of the storage unit.
   */
  int get size => type.size;
}

/**
 * Storage units is a container of the storage units.
 */
class StorageUnits {
  List<StorageUnit> _elements;

  Map<String, StructureMember> _members;

  /**
   * Creates new storage units.
   *
   * Parameters:
   *   [List]<[StructureMember]> members
   *   List of the members of the structural type.
   *
   *   [StructureType] structureType
   *   Structural type for which storage units is created.
   *
   *   [bool] packed
   *   Indicates that the storage units should be packed or not.
   */
  StorageUnits(List<StructureMember> members, StructureType structureType, {bool packed: false}) {
    if (members == null) {
      throw new ArgumentError.notNull("members");
    }

    if (structureType == null) {
      throw new ArgumentError.notNull("structureType");
    }

    if (packed == null) {
      throw new ArgumentError.notNull("packed");
    }

    _elements = <StorageUnit>[];
    _members = <String, StructureMember>{};
    members = _normalizeMembers(members, structureType);
    var groups = _groupMembers(members, structureType, packed);
    _buildUnits(groups, structureType, packed);
    _elements = new UnmodifiableListView<StorageUnit>(_elements);
    _members = new UnmodifiableMapView<String, StructureMember>(_members);
  }

  List<StorageUnit> get elements => _elements;

  Map<String, StructureMember> get members => _members;

  void _addMember(StructureMember member) {
    var name = member.name;
    if (name != null) {
      _members[name] = member;
    }
  }

  void _buildUnits(List<List<StructureMember>> groups, StructureType structureType, bool packed) {
    var dataModel = structureType.dataModel;
    var isStruct = structureType is StructType;
    var length = groups.length;
    var offset = 0;
    for (var i = 0; i < length; i++) {
      var group = groups[i];
      var member = group.first;
      if (member.isBitFiled) {
        if (packed) {
          offset = _Utils.alignOffset(offset, 1);
          var position = 0;
          for (var member in group) {
            var newMember = new StructureMember(member.name, member.type, align: 1, width: member.width);
            newMember._offset = offset;
            newMember._position = position;
            _addMember(newMember);
            position += newMember.width;
          }

          var intType = IntType.create(1, false, dataModel);
          var unit = new StorageUnit(intType, 1);
          _elements.add(unit);
          var sizeInBytes = _Utils.alignOffset(position, 8) ~/ 8;
          if (sizeInBytes > 1) {
            for (var i = 1; i < sizeInBytes; i++) {
              var unit = new StorageUnit(intType, 1);
              _elements.add(unit);
            }
          }

          if (isStruct) {
            offset += sizeInBytes;
          }

        } else {
          var last = group.last;
          var type = last.type;
          var align = type.align;
          offset = _Utils.alignOffset(offset, align);
          var position = 0;
          for (var member in group) {
            var newMember = new StructureMember(member.name, member.type, align: align, width: member.width);
            newMember._offset = offset;
            newMember._position = position;
            _addMember(newMember);
            position += newMember.width;
          }

          var unit = new StorageUnit(last.type, align);
          _elements.add(unit);
          if (isStruct) {
            offset += type.size;
          }

        }
      } else {
        assert(group.length == 1);
        var memberType = member.type;
        if (memberType is ArrayType) {
          var elementType = memberType.type;
          var elementCount = memberType.length;
          var align = _Utils.getMemberAlignment(memberType, member.align, packed);
          offset = _Utils.alignOffset(offset, align);
          var newMember = new StructureMember(member.name, memberType, align: align);
          newMember._offset = offset;
          _addMember(newMember);
          for (var i = 0; i < elementCount; i++) {
            if (i != 0) {
              align = 1;
            }

            var unit = new StorageUnit(elementType, align);
            _elements.add(unit);
          }

          if (isStruct) {
            offset += memberType.size;
          }

        } else {
          var align = _Utils.getMemberAlignment(member.type, member.align, packed);
          offset = _Utils.alignOffset(offset, align);
          var newMember = new StructureMember(member.name, member.type, align: align);
          newMember._offset = offset;
          _addMember(newMember);
          var unit = new StorageUnit(memberType, align);
          _elements.add(unit);
          if (isStruct) {
            offset += memberType.size;
          }
        }
      }
    }
  }

  List<List<StructureMember>> _groupMembers(List<StructureMember> members, StructureType structType, bool packed) {
    var result = <List<StructureMember>>[];
    var length = members.length;
    for (var i = 0; i < length; i++) {
      var member = members[i];
      if (member.isBitFiled) {
        var group = <StructureMember>[member];
        if (packed) {
          for (i++; i < length; i++) {
            var member = members[i];
            if (!member.isBitFiled) {
              i--;
              break;
            }

            group.add(member);
          }

        } else {
          var totalBits = member.width;
          var unitSize = member.type.size;
          var maxBits = unitSize * 8;
          for (i++; i < length; i++) {
            var member = members[i];
            if (!member.isBitFiled) {
              i--;
              break;
            }

            var memberSize = member.type.size;
            var width = member.width;
            if (width == 0) {
              group.add(member);
              break;
            }

            totalBits += width;
            if (totalBits >= maxBits || memberSize != unitSize) {
              i--;
              break;
            }

            group.add(member);
          }
        }

        result.add(group);
      } else {
        result.add(<StructureMember>[member]);
      }
    }

    return result;
  }

  List<StructureMember> _normalizeMembers(List<StructureMember> members, StructureType structureType) {
    var result = <StructureMember>[];
    var dataModel = structureType.dataModel;
    var isStruct = structureType is StructType;
    var length = members.length;
    var leading = true;
    for (var i = 0; i < length; i++) {
      var member = members[i];
      if (member is! StructureMember) {
        throw new ArgumentError("The list of members contains invalid elements");
      }

      if (member.type.dataModel != dataModel) {
        BinaryTypeError.differentDataModel();
      }

      if (member.isBitFiled) {
        if (member.width == 0) {
          if (leading) {
            continue;
          } else {
            var largest = member;
            var size = largest.type.size;
            for (i++; i < length; i++) {
              var member = members[i];
              if (!member.isBitFiled || member.width != 0) {
                i--;
                break;
              }

              var memberSize = member.type.size;
              if (size < memberSize) {
                size = memberSize;
                largest = member;
              }
            }

            result.add(largest);
          }

        } else {
          result.add(member);
          leading = false;
        }

      } else {
        result.add(member);
        leading = true;
      }
    }

    var names = new Set<String>();
    length = result.length;
    for (var i = 0; i < length; i++) {
      var member = result[i];
      var memberName = member.name;
      if (memberName != null) {
        if (names.contains(memberName)) {
          BinaryTypeError.redefinitionOfMemberIsNotAllowed(structureType, memberName);
        }

        names.add(memberName);
      }

      var memberType = member.type;
      if (memberType.size == 0) {
        if (memberType.kind == BinaryKinds.ARRAY) {
          if (i + 1 != length && isStruct) {
            BinaryTypeError.flexibleArrayMemberNotAtEndOfStruct(structureType, member.name);
          }

        } else {
          BinaryTypeError.incompleteMemberType(structureType, memberType);
        }
      }
    }

    return result;
  }
}
