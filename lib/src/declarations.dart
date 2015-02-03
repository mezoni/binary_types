part of binary_types;

class _Declarations {
  final BinaryTypes types;

  DataModel _dataModel;

  _Declarations(this.types) {
    if (types == null) {
      throw new ArgumentError.notNull("types");
    }

    _dataModel = types.int_t.dataModel;
  }

  void declare(String source, {Map<String, String> environment}) {
    if (source == null) {
      throw new ArgumentError.notNull("source");
    }

    var declarations = new Declarations(source, environment: environment);
    Declaration declaration;
    try {
      for (declaration in declarations) {
        if (declaration is TypedefDeclaration) {
          var typedefType = declaration.type;
          var type = typedefType.type;
          var name = typedefType.name;
          var binaryType = _declareType(type);
          var attributes = _Metadata.getAttributes(type.metadata, null);
          attributes = _Metadata.getAttributes(typedefType.metadata, attributes);
          attributes = _Metadata.getAttributes(declaration.metadata, attributes);
          var align = _Metadata.getAttributeAligned(attributes, null);
          var packed = _Metadata.getAttributePacked(attributes, false);
          _defineType(name, binaryType, align, packed);
        } else if (declaration is StructureDeclaration) {
          _declareStructure(declaration.type);
        } else if (declaration is EnumDeclaration) {
          _declareEnum(declaration.type);
        } else if (declaration is VariableDeclaration) {
          if (declaration.type is StructureTypeSpecification) {
            _declareStructure(declaration.type);
          } else if (declaration.type is EnumTypeSpecification) {
            _declareEnum(declaration.type);
          }
        }
      }
    } catch (e, s) {
      BinaryTypeError.declarationError(declaration, e.toString());
    }
  }

  void _checkTag(BinaryType type, String tag) {
    if (tag == null) {
      return;
    }

    var taggedType = types._tags[tag];
    if (taggedType == null) {
      return;
    }

    var name = type.name;
    if (taggedType.kind == type.kind) {
      BinaryTypeError.unableRedeclareType(name);
    } else {
      BinaryTypeError.unableRedeclareTypeWithTag(name, tag);
    }
  }

  BinaryType _declareArray(ArrayTypeSpecification type) {
    var binaryType = _declareType(type.type);
    for (var dimension in type.dimensions) {
      if (dimension == null) {
        dimension = 0;
      }

      binaryType = binaryType.array(dimension);
    }

    return binaryType;
  }

  BinaryType _declareEnum(EnumTypeSpecification type) {
    var taggedType = type.taggedType;
    var attributes = _Metadata.getAttributes(taggedType.metadata, null);
    attributes = _Metadata.getAttributes(type.metadata, attributes);
    var align = _Metadata.getAttributeAligned(attributes, null);
    var tag = taggedType.tag;
    var values = <String, int>{};
    for (var value in type.values) {
      values[value.name] = value.value;
    }

    var enumType = new EnumType(tag, values, _dataModel, align: align);
    if (tag != null) {
      _checkTag(enumType, tag);
      types._types[enumType.name] = enumType;
      types._tags[tag] = enumType;
    }

    return enumType;
  }

  BinaryType _declareStructure(StructureTypeSpecification type) {
    var taggedType = type.taggedType;
    var attributes = _Metadata.getAttributes(taggedType.metadata, null);
    attributes = _Metadata.getAttributes(type.metadata, attributes);
    var align = _Metadata.getAttributeAligned(attributes, null);
    var packed = _Metadata.getAttributePacked(attributes, false);
    var kind = taggedType.kind;
    var tag = taggedType.tag;
    StructureType structureType;
    if (tag != null) {
      var name = "$kind $tag";
      structureType = types._types[name];
      if (structureType != null) {
        BinaryTypeError.unableRedeclareType(name);
      }
    }

    if (structureType == null) {
      switch (taggedType.kind) {
        case TaggedTypeKinds.STRUCT:
          structureType = new StructType(tag, null, _dataModel, align: align, packed: packed);
          break;
        case TaggedTypeKinds.UNION:
          structureType = new UnionType(tag, null, _dataModel, align: align, packed: packed);
          break;
      }

      if (tag != null) {
        _checkTag(structureType, tag);
        types._types[structureType.name] = structureType;
        types._tags[tag] = structureType;
      }
    }

    var members = <StructureMember>[];
    for (var member in type.members) {
      var memberType = member.type;
      var name = member.name;
      var binaryType = _declareType(memberType);
      var attributes = _Metadata.getAttributes(memberType.metadata, null);
      attributes = _Metadata.getAttributes(member.metadata, attributes);
      var align = _Metadata.getAttributeAligned(attributes, null);
      // Querying new attributes, since we need ignoring an attribute "packed"
      // in the type.
      attributes = _Metadata.getAttributes(member.metadata, null);
      var packed = _Metadata.getAttributePacked(attributes, false);
      if (packed) {
        if (align == null) {
          align = 1;
        }
      }

      var newMember = new StructureMember(name, binaryType, align: align, width: member.width);
      members.add(newMember);
    }

    if (!members.isEmpty) {
      structureType.addMembers(members, align: align, packed: packed);
    }

    return structureType;
  }

  BinaryType _declareType(TypeSpecification type) {
    if (type is ArrayTypeSpecification) {
      return _declareArray(type);
    } else if (type is EnumTypeSpecification) {
      return _declareEnum(type);
    } else if (type is FloatTypeSpecification) {
      return types._types[type.name];
    } else if (type is IntegerTypeSpecification) {
      return types._types[type.name];
    } else if (type is PointerTypeSpecification) {
      return _declareType(type.type).ptr();
    } else if (type is StructureTypeSpecification) {
      return _declareStructure(type);
    } else if (type is SynonymTypeSpecification) {
      return types._types[type.name];
    } else if (type is TaggedTypeSpecification) {
      return types._types[type.name];
    } else if (type is VaListTypeSpecification) {
      return types._types["..."];
    } else if (type is VoidTypeSpecification) {
      return types._types["void"];
    } else {
      throw new ArgumentError("Unable declare type by the specification '${type.runtimeType}'");
    }
  }

  BinaryType _defineType(String synonym, BinaryType original, int align, bool packed) {
    var previous = types._types[synonym];
    if (previous != null && !previous.compatible(original, true)) {
      BinaryTypeError.unableRedeclareType(synonym);
    }

    var copy = original.clone(synonym, align: align, packed: packed);
    types._types[synonym] = copy;
    return copy;
  }

  Map<String, List<List<String>>> _getTypeAttributes(TypeSpecification type, [Map<String, List<List<String>>> attributes]) {
    if (type == null) {
      throw new ArgumentError.notNull("type");
    }

    if (attributes == null) {
      attributes = <String, List<List<String>>>{};
    }

    var types = <TypeSpecification>[];
    if (type is StructureTypeSpecification) {
      types.add(type.taggedType);
      types.add(type);
    } else if (type is EnumTypeSpecification) {
      types.add(type.taggedType);
      types.add(type);
    } else if (type is TypedefTypeSpecification) {
      types.add(type);
      types.add(type.type);
    } else {
      types.add(type);
    }

    for (var type in types) {
      var metadata = type.metadata;
      if (metadata != null) {
        _Metadata.getAttributes(metadata, attributes);
      }
    }

    return attributes;
  }
}
