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

    var env = <String, String>{};
    if (environment != null) {
      env.addAll(environment);
    }

    var bitness = types["size_t"].size * 8;
    env["__OS__"] = Platform.operatingSystem;
    env["__BITNESS__"] = bitness.toString();
    var declarations = new Declarations(source, environment: env);
    Declaration declaration;
    try {
      for (declaration in declarations) {
        if (declaration is TypedefDeclaration) {
          _declareTypedef(declaration);
        } else if (declaration is StructureDeclaration) {
          _declareStructure(declaration);
        } else if (declaration is EnumDeclaration) {
          _declareEnum(declaration);
        } else if (declaration is VariableDeclaration) {
          _declareVariable(declaration);
        }
      }
    } catch (e, s) {
      BinaryTypeError.declarationError(declaration, "$e\n$s");
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

  void _declareEnum(EnumDeclaration declaration) {
    var type = declaration.type;
    var taggedType = type.taggedType;
    var binaryType = _resolveEnum(type);
    _registerTaggedType(taggedType, binaryType);
  }

  StructureMember _declareMember(ParameterDeclaration declaration) {
    var identifier = declaration.identifier;
    var type = declaration.type;
    var binaryType = _resolveType(type);
    var typeAlign = binaryType.align;
    var metadata = new _Metadata([identifier.metadata, type.metadata, declaration.metadata]);
    var align = metadata.aligned;
    var packed = metadata.packed;
    if (packed) {
      if (align == null) {
        align = 1;
      }
    } else {
      if (align != null) {
        if (align < typeAlign) {
          align = typeAlign;
        }
      }
    }

    return new StructureMember(identifier.name, binaryType, align: align, width: declaration.width);
  }

  void _declareStructure(StructureDeclaration declaration) {
    var type = declaration.type;
    var taggedType = type.taggedType;
    var binaryType = _resolveStructure(type);
    _registerTaggedType(taggedType, binaryType);
  }

  BinaryType _declareSynonym(TypeSpecification type, _Out<String> name, BinaryType binaryType) {
    switch (type.typeKind) {
      case TypeSpecificationKind.DEFINED:
        name.value = type.name;
        break;
      case TypeSpecificationKind.ARRAY:
        var arrayType = type as ArrayTypeSpecification;
        binaryType = _declareSynonym(arrayType.type, name, binaryType);
        var dimensions = arrayType.dimensions.dimensions;
        var length = dimensions.length;
        for (var i = length - 1; i >= 0; i--) {
          var dimension = dimensions[i];
          if (dimension == null) {
            dimension = 0;
          }

          binaryType = binaryType.array(dimension);
        }

        break;
      case TypeSpecificationKind.POINTER:
        var pointerType = type as PointerTypeSpecification;
        binaryType = _declareSynonym(pointerType.type, name, binaryType);
        binaryType = binaryType.ptr();
        break;
      default:
        throw new ArgumentError("Unable declare synonym '${type.typeKind}' $name");
    }

    return binaryType;
  }

  void _declareTypedef(TypedefDeclaration declaration) {
    var type = declaration.type;
    _registerTypeIfNecessary(type);
    var originalType = _resolveType(type);
    for (var synonym in declaration.synonyms) {
      var name = new _Out<String>();
      var binaryType = _declareSynonym(synonym, name, originalType);
      _Metadata metadata;
      switch (type.typeKind) {
        case TypeSpecificationKind.DEFINED:
        case TypeSpecificationKind.FLOAT:
        case TypeSpecificationKind.INTEGER:
          // Bug in gcc?
          metadata = new _Metadata([synonym.metadata, type.metadata]);
          break;
        default:
          metadata = new _Metadata([type.metadata, synonym.metadata]);
      }

      _defineType(name.value, binaryType, metadata);
    }
  }

  void _declareVariable(VariableDeclaration declaration) {
    _registerTypeIfNecessary(declaration.type);
  }

  BinaryType _defineType(String synonym, BinaryType binaryType, _Metadata metadata) {
    var previous = types._types[synonym];
    if (previous != null && !previous.compatible(binaryType, true)) {
      BinaryTypeError.unableRedeclareType(synonym);
    }

    var align = metadata.aligned;
    var packed = metadata.packed;
    var copy = binaryType.clone(synonym, align: align, packed: packed);
    types._types[synonym] = copy;
    return copy;
  }

  void _registerTaggedType(TaggedTypeSpecification type, BinaryType binaryType) {
    var tag = type.tag;
    _checkTag(binaryType, tag);
    if (tag != null) {
      types._tags[tag] = binaryType;
      types._types[type.name] = binaryType;
    }
  }

  void _registerTypeIfNecessary(TypeSpecification type) {
    BinaryType binaryType;
    TaggedTypeSpecification taggedType;
    switch (type.typeKind) {
      case TypeSpecificationKind.ENUM:
        taggedType = (type as EnumTypeSpecification).taggedType;
        binaryType = _resolveEnum(type);
        break;
      case TypeSpecificationKind.STRUCTURE:
        taggedType = (type as StructureTypeSpecification).taggedType;
        binaryType = _resolveStructure(type);
        break;
      default:
        return;
    }

    _registerTaggedType(taggedType, binaryType);
  }

  BinaryType _resolveArray(ArrayTypeSpecification type) {
    var binaryType = _resolveType(type.type);
    var dimensions = type.dimensions.dimensions;
    var length = dimensions.length;
    for (var i = length - 1; i >= 0; i--) {
      var dimension = dimensions[i];
      if (dimension == null) {
        dimension = 0;
      }

      binaryType = binaryType.array(dimension);
    }

    return binaryType;
  }

  BinaryType _resolveEnum(EnumTypeSpecification type) {
    var taggedType = type.taggedType;
    var metadata = new _Metadata([taggedType.metadata, type.metadata]);
    var align = metadata.aligned;
    var packed = metadata.packed;
    var tag = taggedType.tag;
    var values = <String, int>{};
    for (var value in type.values) {
      values[value.name] = value.value;
    }

    return new EnumType(tag, values, _dataModel, align: align);
  }

  BinaryType _resolvePointer(PointerTypeSpecification type) {
    var binaryType = _resolveType(type.type);
    return binaryType.ptr();
  }

  BinaryType _resolveStructure(StructureTypeSpecification type) {
    var taggedType = type.taggedType;
    var metadata = new _Metadata([taggedType.metadata, type.metadata]);
    var align = metadata.aligned;
    var packed = metadata.packed;
    var tagKind = taggedType.tagKind;
    var tag = taggedType.tag;
    StructureType structureType;
    switch (tagKind) {
      case TaggedTypeKinds.STRUCT:
        structureType = new StructType(tag, null, _dataModel, align: align, packed: packed);
        break;
      case TaggedTypeKinds.UNION:
        structureType = new UnionType(tag, null, _dataModel, align: align, packed: packed);
        break;
    }

    BinaryType replacedType;
    if (tag != null) {
      replacedType = types._types[taggedType.name];
      types._types[taggedType.name] = structureType;
    }

    var members = <StructureMember>[];
    for (var member in type.members) {
      members.add(_declareMember(member));
    }

    if (tag != null) {
      types._types[taggedType.name] = replacedType;
    }

    if (!members.isEmpty) {
      structureType.addMembers(members, align: align, packed: packed);
    }

    return structureType;
  }

  BinaryType _resolveType(TypeSpecification type) {
    BinaryType binaryType;
    switch (type.typeKind) {
      case TypeSpecificationKind.ARRAY:
        binaryType = _resolveArray(type);
        break;
      case TypeSpecificationKind.ENUM:
        binaryType = _resolveEnum(type);
        break;
      case TypeSpecificationKind.DEFINED:
      case TypeSpecificationKind.FLOAT:
      case TypeSpecificationKind.INTEGER:
      case TypeSpecificationKind.TAGGED:
      case TypeSpecificationKind.VA_LIST:
      case TypeSpecificationKind.VOID:
        binaryType = types[type.name];
        break;
      case TypeSpecificationKind.POINTER:
        binaryType = _resolvePointer(type);
        break;
      case TypeSpecificationKind.STRUCTURE:
        binaryType = _resolveStructure(type);
        break;
      default:
        throw new ArgumentError("Unable resolve type '${type.typeKind}'");
    }

    return binaryType;
  }
}

class _Out<T> {
  T value;

  _Out([this.value]);

  String toString() {
    return value.toString();
  }
}
