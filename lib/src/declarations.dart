part of binary_types;

class _Declarations {
  final BinaryTypes types;

  DataModel _dataModel;

  Map<String, FunctionType> _functions;

  _Scope _scope;

  Map<String, BinaryType> _variables;

  _Declarations(this.types) {
    if (types == null) {
      throw new ArgumentError.notNull("types");
    }

    _dataModel = types["int"].dataModel;
  }

  Declarations declare(String source, {Map<String, String> environment, Map<String, FunctionType> functions, Map<String, BinaryType> variables}) {
    if (source == null) {
      throw new ArgumentError.notNull("source");
    }

    if (functions == null) {
      functions = <String, FunctionType>{};
    }

    if (variables == null) {
      variables = <String, BinaryType>{};
    }

    _functions = functions;
    _variables = variables;
    _scope = new _Scope(types);
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
        } else if (declaration is FunctionDeclaration) {
          _declareFunction(declaration);
        }
      }
    } catch (e, s) {
      BinaryTypeError.declarationError(declaration, "$e\n$s");
    }

    return declarations;
  }

  List<DeclarationSpecifiers> _combineMetadata(TypeQualifiers qualifiers, DeclarationSpecifiers specifiers) {
    var result = <DeclarationSpecifiers>[];
    if (qualifiers != null) {
      for (var qualifier in qualifiers.qualifiers) {
        if (qualifier.metadata != null) {
          result.add(qualifier.metadata);
        }
      }
    }

    if (specifiers != null) {
      result.add(specifiers);
    }

    return result;
  }

  void _declareEnum(EnumDeclaration declaration) {
    var type = declaration.type;
    _resolveEnum(type);
  }

  void _declareFunction(FunctionDeclaration declaration) {
    var declarator = declaration.declarator;
    var binaryType = _resolveType(declaration.type);
    binaryType = _resolveDeclarator(declarator, binaryType);
    _functions[declarator.identifier.name] = binaryType;
  }

  StructureMember _declareMember(ParameterDeclaration declaration) {
    var declarator = declaration.declarator;
    String name;
    var width = _literalToInt(declarator.width);
    if (declarator.identifier != null) {
      name = declarator.identifier.name;
    }

    var type = declaration.type;
    var binaryType = _resolveType(type);
    binaryType = _resolveDeclarator(declarator, binaryType);
    if (width != null) {
      if (!(binaryType is IntType || binaryType is EnumType)) {
        BinaryTypeError.declarationError(declaration, "Invalid type of the bit-field member");
      }
    }

    var metadata = [declarator.metadata];
    metadata.addAll(_getTypeMetadata(type));
    metadata.addAll(_getDeclarationMetadata(declaration));
    var reader = new AttributeReader(metadata);
    var align = _getAligned(reader);
    var packed = _getPacked(reader);
    if (packed) {
      if (align == null) {
        align = 1;
      }
    } else {
      if (align != null && binaryType.size != 0) {
        var typeAlign = binaryType.align;
        if (align < typeAlign) {
          align = typeAlign;
        }
      }
    }

    return new StructureMember(name, binaryType, align: align, width: width);
  }

  BinaryType _declareParameter(ParameterDeclaration declaration) {
    var binaryType = _resolveType(declaration.type);
    var declarator = declaration.declarator;
    if (declarator != null) {
      binaryType = _resolveDeclarator(declarator, binaryType);
    }

    return binaryType;
  }

  void _declareStructure(StructureDeclaration declaration) {
    var type = declaration.type;
    _resolveStructure(type);
  }

  void _declareTypedef(TypedefDeclaration declaration) {
    var type = declaration.type;
    var originalType = _resolveType(type);
    for (var declarator in declaration.declarators) {
      var binaryType = _resolveDeclarator(declarator, originalType);
      var metadata = <DeclarationSpecifiers>[];
      switch (type.typeKind) {
        case TypeSpecificationKind.DEFINED:
        case TypeSpecificationKind.FLOAT:
        case TypeSpecificationKind.INTEGER:
        case TypeSpecificationKind.VOID:
          // Bug in gcc?
          metadata.add(declarator.metadata);
          metadata.addAll(_getTypeMetadata(type));
          break;
        default:
          metadata.addAll(_getTypeMetadata(type));
          metadata.add(declarator.metadata);
      }

      var reader = new AttributeReader(metadata);
      _defineType(declarator.identifier.name, binaryType, reader);
    }
  }

  void _declareVariable(VariableDeclaration declaration) {
    var baseType = _resolveType(declaration.type);
    for (var declarator in declaration.declarators) {
      var binaryType = _resolveDeclarator(declarator, baseType);
      if (binaryType.size == 0) {
        BinaryTypeError.declarationError(declaration, "Unable to determine the size of the type '$binaryType'");
      }

      _variables[declarator.identifier.name] = binaryType;
    }
  }

  BinaryType _defineType(String synonym, BinaryType binaryType, AttributeReader reader) {
    _scope.types[_scope.current][synonym];
    var previous = _scope.types[_scope.current][synonym];
    if (previous != null && !previous.compatible(binaryType, true)) {
      BinaryTypeError.unableRedeclareType(synonym);
    }

    var align = _getAligned(reader);
    var copy = binaryType.clone(synonym, align: align);
    _scope.types[_scope.current][synonym] = copy;
    return copy;
  }

  int _getAligned(AttributeReader reader) {
    var literal = reader.getIntegerArgument("aligned", 0, new IntegerLiteral(text: "16", value: 16), maxLength: 1, minLength: 0);
    return _literalToInt(literal);
  }

  List<DeclarationSpecifiers> _getDeclarationMetadata(Declaration declaration) {
    return _combineMetadata(declaration.qualifiers, declaration.metadata);
  }

  bool _getPacked(AttributeReader reader) {
    return reader.defined("packed", maxLength: 0, minLength: 0);
  }

  List<DeclarationSpecifiers> _getTypeMetadata(TypeSpecification type) {
    return _combineMetadata(type.qualifiers, type.metadata);
  }

  int _literalToInt(IntegerLiteral literal) {
    if (literal == null) {
      return null;
    }

    return literal.value;
  }

  void _registerElaboratedType(ElaboratedTypeSpecifier elaboratedType, BinaryType binaryType) {
    String tag = elaboratedType.tag != null ? elaboratedType.tag.name : null;
    if (tag != null) {
      _scope.tags[_scope.current][tag] = binaryType;
      _scope.types[_scope.current][elaboratedType.name] = binaryType;
    }
  }

  BinaryType _resolveDeclarator(Declarator declarator, BinaryType binaryType) {
    if (declarator == null) {
      return binaryType;
    }

    if (declarator.isPointers) {
      for (var pointer in declarator.pointers.specifiers) {
        // TODO: Declaration specifiers
        binaryType = binaryType.ptr();
      }
    }

    if (declarator.isFunction) {
      var returnType = binaryType;
      var parameters = <BinaryType>[];
      _scope.enter();
      for (var declaration in declarator.parameters.declarations) {
        var parameter = _declareParameter(declaration);
        parameters.add(parameter);
      }

      _scope.exit();
      binaryType = new FunctionType(declarator.identifier.name, returnType, parameters, _dataModel);
      if (declarator.isFunctionPointer) {
        var pointers = declarator.pointers;
        for (var pointer in declarator.functionPointers.specifiers) {
          binaryType = binaryType.ptr();
        }
      }
    }

    if (declarator.isArray) {
      var dimensions = declarator.dimensions.dimensions;
      var length = dimensions.length;
      for (var i = length - 1; i >= 0; i--) {
        var dimension = _literalToInt(dimensions[i]);
        if (dimension == null) {
          dimension = 0;
        }

        binaryType = binaryType.array(dimension);
      }
    }

    return binaryType;
  }

  BinaryType _resolveElaboratedType(ElaboratedTypeSpecifier type, bool checkCompleteness) {
    if (type.tag == null) {
      return null;
    }

    var tag = type.tag.name;
    var binaryType = _scope.tags[_scope.current][tag];
    if (binaryType == null) {
      return null;
    }

    var name = type.name;
    var complete = false;
    var compatible = false;
    switch (binaryType.kind) {
      case BinaryKinds.ENUM:
        var enumType = binaryType as EnumType;
        complete = !enumType.enumerators.isEmpty;
        compatible = type.kind == "enum";
        break;
      case BinaryKinds.STRUCT:
        var structureType = binaryType as StructureType;
        complete = structureType.size != 0;
        compatible = type.kind == "struct" || type.kind == "union";
        break;
    }

    if (!compatible) {
      BinaryTypeError.unableRedeclareTypeWithTag(name, tag);
    }

    if (checkCompleteness && complete) {
      BinaryTypeError.unableRedeclareType(name);
    }

    return binaryType;
  }

  BinaryType _resolveEnum(EnumTypeSpecification type) {
    var elaboratedType = type.elaboratedType;
    var metadata = [elaboratedType.metadata];
    metadata.addAll(_getTypeMetadata(type));
    var reader = new AttributeReader(metadata);
    var align = _getAligned(reader);
    String tag = elaboratedType.tag != null ? elaboratedType.tag.name : null;
    var hasEmumerators = !type.enumerators.isEmpty;
    EnumType binaryType = _resolveElaboratedType(elaboratedType, hasEmumerators);
    if (binaryType == null) {
      binaryType = new EnumType(tag, _dataModel, align: align);
      _registerElaboratedType(elaboratedType, binaryType);
    }

    var enumerators = <String, dynamic>{};
    for (var enumerator in type.enumerators) {
      var expression = enumerator.value;
      Object value;
      if (expression is IntegerLiteral) {
        value = expression.value;
      } else if (expression is Identifier) {
        value = expression.name;
      } else if (expression == null) {
      } else {
        throw new StateError("Invaild emumerator value '$enumerator'");
      }

      enumerators[enumerator.identifier.name] = value;
    }

    if (!enumerators.isEmpty) {
      binaryType.addEnumerators(enumerators, align: align);
    }

    return binaryType;
  }

  BinaryType _resolveStructure(StructureTypeSpecification type) {
    var elaboratedType = type.elaboratedType;
    var metadata = [elaboratedType.metadata];
    metadata.addAll(_getTypeMetadata(type));
    var reader = new AttributeReader(metadata);
    var align = _getAligned(reader);
    var packed = _getPacked(reader);
    var kind = elaboratedType.kind;
    String tag = elaboratedType.tag != null ? elaboratedType.tag.name : null;
    var hasMembers = !type.members.isEmpty;
    StructureType binaryType = _resolveElaboratedType(elaboratedType, hasMembers);
    if (binaryType == null) {
      switch (kind) {
        case "struct":
          binaryType = new StructType(tag, _dataModel, align: align);
          break;
        case "union":
          binaryType = new UnionType(tag, _dataModel, align: align);
          break;
      }

      _registerElaboratedType(elaboratedType, binaryType);
    }

    var members = <StructureMember>[];
    for (var member in type.members) {
      members.add(_declareMember(member));
    }

    if (!members.isEmpty) {
      binaryType.addMembers(members, align: align, packed: packed);
    }

    return binaryType;
  }

  BinaryType _resolveType(TypeSpecification type) {
    BinaryType binaryType;
    switch (type.typeKind) {
      case TypeSpecificationKind.ENUM:
        binaryType = _resolveEnum(type);
        break;
      case TypeSpecificationKind.BOOL:
      case TypeSpecificationKind.DEFINED:
      case TypeSpecificationKind.FLOAT:
      case TypeSpecificationKind.INTEGER:
      case TypeSpecificationKind.VA_LIST:
      case TypeSpecificationKind.VOID:
        binaryType = types[type.name];
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

class _Scope {
  List<Map<String, BinaryType>> tags;

  List<Map<String, BinaryType>> types;

  int current = 0;

  int previous = 0;

  _Scope(BinaryTypes types) {
    tags = <Map<String, BinaryType>>[types._tags];
    this.types = <Map<String, BinaryType>>[types._types];
  }

  void enter() {
    tags.add(<String, BinaryType>{});
    types.add(<String, BinaryType>{});
    previous = current++;
  }

  void exit() {
    if (current <= 0) {
      throw new StateError("Cannot exit scope");
    }

    tags.removeLast();
    types.removeLast();
    current--;
    if (previous > 0) {
      previous--;
    }
  }
}
