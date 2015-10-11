part of binary_types;

class _Declarations {
  final BinaryTypes types;

  DataModel _dataModel;

  Map<String, Prototype> _prototypes;

  Map<String, Variable> _variables;

  _Scope _scope;

  _Declarations(this.types) {
    if (types == null) {
      throw new ArgumentError.notNull("types");
    }

    _dataModel = types["int"].dataModel;
  }

  Declarations declare(String filename, {Map<String, dynamic> environment}) {
    if (filename == null) {
      throw new ArgumentError.notNull("filename");
    }

    _prototypes = types._prototypes;
    _variables = types._variables;
    _scope = new _Scope(types);
    var env = <String, String>{};
    if (environment != null) {
      env.addAll(environment);
    }

    var definitions = types._definitions;
    var files = types._headers;
    var declarations = new Declarations(filename, files, definitions: definitions, environment: env);
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

  Map<String, int> _addEnumerators(Enumerators enumerators) {
    var result = <String, int>{};
    var prev = -1;
    for (var enumerator in enumerators.elements) {
      var name = enumerator.identifier.name;
      if (_scope.enumerators[_scope.current].containsKey(name)) {
        throw new StateError("Unable redeclare enumerator: $enumerator");
      }

      var expression = enumerator.value;
      int value;
      if (expression != null) {
        var result = _evaluateExpresssion(expression, identifier: _resolveEnumerator, sizeof: _sizeof);
        if (result is int) {
          value = result;
        } else {
          throw new ArgumentError.value(expression, "enumerator", "Expected integer expression");
        }
      }

      if (value is int) {
        prev = value;
      } else {
        value = ++prev;
      }

      result[name] = value;
      _scope.enumerators[_scope.current][name] = value;
    }

    return result;
  }

  void _addPrototype(Prototype prototype) {
    var name = prototype.type.identifier;
    var found = _prototypes[name];
    if (found == null) {
      _prototypes[name] = prototype;
      return;
    }

    var type1 = found.type;
    var type2 = prototype.type;
    if (type1.returnType.compatible(type2.returnType, true)) {
      var arity = type1.arity;
      if (arity == type2.arity) {
        if (type1.variadic == type2.variadic) {
          var compatible = true;
          var parameters1 = type1.parameters;
          var parameters2 = type2.parameters;
          for (var i = 0; i < arity; i++) {
            var parameter1 = parameters1[i];
            var parameter2 = parameters2[i];
            if (!parameter1.compatible(parameter2, true)) {
              compatible = false;
            }
          }

          if (compatible) {
            _checkUniqueness(name);
            _prototypes[name] = prototype;
            return;
          }
        }
      }
    }

    BinaryTypeError.conflictingPrototypes(name);
  }

  void _addVariable(Variable variable) {
    var name = variable.name;
    var found = _variables[name];
    if (found == null) {
      _variables[name] = variable;
      return;
    }

    var type1 = found.type;
    var type2 = variable.type;
    if (type1.compatible(type2, true)) {
      _checkUniqueness(name);
      _variables[name] = variable;
      return;
    }

    BinaryTypeError.conflictingVariables(name);
  }

  // TODO: _checkUniqueness()
  void _checkUniqueness(String name) {
    //
  }

  List<DeclarationSpecifiers> _combineMetadata(TypeQualifiers qualifiers, DeclarationSpecifiers specifiers) {
    var result = <DeclarationSpecifiers>[];
    if (qualifiers != null) {
      for (var qualifier in qualifiers.elements) {
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

  // TODO: Implement _checkUniqueness()
  void _declareEnum(EnumDeclaration declaration) {
    var type = declaration.type;
    _resolveEnum(type);
  }

  void _declareFunction(FunctionDeclaration declaration) {
    var declarator = declaration.declarator;
    var type = declaration.type;
    BinaryType binaryType;
    if (type == null) {
      binaryType = types["int"];
    } else {
      binaryType = _resolveType(declaration.type);
    }

    binaryType = _resolveDeclarator(declarator, binaryType);
    var parameters = <String>[];
    if (binaryType is FunctionType) {
      var arity = binaryType.arity;
      var elements = declaration.declarator.parameters.elements;
      for (var i = 0; i < arity; i++) {
        String name;
        var parameter = elements[i];
        if (parameter.declarator != null) {
          var identifier = parameter.declarator.identifier;
          if (identifier != null) {
            name = identifier.name;
          }
        }

        parameters.add(name);
      }
    } else {
      throw new StateError("Not a function type: ${binaryType.name}");
    }

    var alias = _getAliasAttribute([declarator.metadata, declaration.metadata]);
    parameters = new UnmodifiableListView<String>(parameters);
    var filename = declaration.filename;
    var prototype = new Prototype(alias: alias, filename: filename, parameters: parameters, type: binaryType);
    _addPrototype(prototype);
  }

  // TODO: Implement "convention", "library" for prototypes
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
    for (var declarator in declaration.declarators.elements) {
      var binaryType = _resolveDeclarator(declarator, originalType);
      var metadata = <DeclarationSpecifiers>[];
      switch (type.typeKind) {
        case TypeSpecificationKind.BASIC:
        case TypeSpecificationKind.BOOL:
        case TypeSpecificationKind.DEFINED:
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
    for (var declarator in declaration.declarators.elements) {
      var binaryType = _resolveDeclarator(declarator, baseType);
      if (binaryType.size == 0) {
        BinaryTypeError.declarationError(declaration, "Unable to determine the size of the type '$binaryType'");
      }

      var filename = declaration.filename;
      var name = declarator.identifier.name;
      var variable = new Variable(filename: filename, name: name, type: binaryType);
      _addVariable(variable);
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

  dynamic _evaluateExpresssion(Expression expression, {Function identifier, Function sizeof}) {
    var evaluator = new ExpressionEvaluator();
    return evaluator.evaluate(expression, identifier: identifier, sizeof: sizeof);
  }

  String _getAliasAttribute(List<DeclarationSpecifiers> specifiers) {
    var aliases = [];
    for (var specifier in specifiers) {
      if (specifier != null) {
        var reader = new AttributeReader([specifier]);
        var alias = reader.getArgument("alias", 0, null, minLength: 1, maxLength: 1);
        if (alias is Identifier) {
          aliases.add(alias.name);
        }
      }
    }

    if (aliases.length > 1) {
      throw new StateError("Multiple aliases are not allowed");
    }

    if (aliases.length == 0) {
      return null;
    }

    return aliases.first;
  }

  int _getAligned(AttributeReader reader) {
    var result =
        reader.getIntegerArgument("aligned", 0, new IntegerLiteral(text: "16", value: 16), maxLength: 1, minLength: 0);
    return result;
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
      var length = declarator.pointers.elements.length;
      while ((length--) > 0) {
        // TODO: Declaration specifiers
        binaryType = binaryType.ptr();
      }
    }

    if (declarator.isFunction) {
      var returnType = binaryType;
      var parameterTypes = <BinaryType>[];
      var variadic = declarator.parameters.ellipsis != null;
      _scope.enter();
      var elements = declarator.parameters.elements;
      var length = elements.length;
      if (length > 0) {
        var parameterType = _declareParameter(elements[0]);
        if (length == 1) {
          if (!variadic && parameterType.kind == BinaryKind.VOID) {
            // Nothing
          } else {
            parameterTypes.add(parameterType);
          }
        } else {
          parameterTypes.add(parameterType);
          for (var i = 1; i < length; i++) {
            parameterType = _declareParameter(elements[i]);
            parameterTypes.add(parameterType);
          }
        }
      }

      _scope.exit();
      binaryType = new FunctionType(declarator.identifier.name, returnType, parameterTypes, variadic, _dataModel);
      if (declarator.isFunctionPointer) {
        var length = declarator.functionPointers.elements.length;
        while ((length--) > 0) {
          binaryType = binaryType.ptr();
        }
      }
    }

    if (declarator.isArray) {
      var dimensions = declarator.dimensions.elements;
      var length = dimensions.length;
      for (var i = length - 1; i >= 0; i--) {
        int dimension;
        var expression = dimensions[i];
        if (expression != null) {
          var result = _evaluateExpresssion(expression, identifier: _resolveEnumerator, sizeof: _sizeof);
          if (result is int) {
            dimension = result;
          } else {
            throw new ArgumentError.value(expression, "dimension", "Expected integer expression");
          }
        }

        if (dimension == null) {
          dimension = 0;
        }

        binaryType = binaryType.array(dimension);
      }
    }

    return binaryType;
  }

  BinaryType _resolveElaboratedType(ElaboratedTypeSpecifier type, bool hasMembers) {
    if (type.tag == null) {
      return null;
    }

    var tag = type.tag.name;
    BinaryType binaryType;
    binaryType = _scope.findTag(tag, !hasMembers);
    if (binaryType == null) {
      return null;
    }

    var name = type.name;
    var completed = false;
    var compatible = false;
    switch (binaryType.kind) {
      case BinaryKind.ENUM:
        var enumType = binaryType as EnumType;
        completed = !enumType.enumerators.isEmpty;
        compatible = type.kind.name == "enum";
        break;
      case BinaryKind.STRUCT:
        var structureType = binaryType as StructureType;
        completed = structureType.size != 0;
        compatible = type.kind.name == "struct" || type.kind.name == "union";
        break;
      default:
        break;
    }

    if (!compatible) {
      BinaryTypeError.unableRedeclareTypeWithTag(name, tag);
    }

    if (hasMembers && completed) {
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
    var hasEmumerators = false;
    if (type.enumerators != null) {
      hasEmumerators = !type.enumerators.elements.isEmpty;
    }

    EnumType binaryType = _resolveElaboratedType(elaboratedType, hasEmumerators);
    if (binaryType == null) {
      binaryType = new EnumType(tag, _dataModel, align: align);
      _registerElaboratedType(elaboratedType, binaryType);
    }

    if (type.enumerators != null) {
      var enumerators = _addEnumerators(type.enumerators);
      if (!enumerators.isEmpty) {
        binaryType.addEnumerators(enumerators, align: align);
      }
    }

    return binaryType;
  }

  int _resolveEnumerator(Identifier identifier) {
    var value = _scope.enumerators[_scope.current][identifier.name];
    if (value == null) {
      throw new StateError("Undeclared identifier: $identifier");
    }

    return value;
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
    var hasMembers = false;
    if (type.members != null) {
      hasMembers = !type.members.elements.isEmpty;
    }

    StructureType binaryType = _resolveElaboratedType(elaboratedType, hasMembers);
    if (binaryType == null) {
      switch (kind.name) {
        case "struct":
          binaryType = new StructType(tag, _dataModel, align: align);
          break;
        case "union":
          binaryType = new UnionType(tag, _dataModel, align: align);
          break;
      }

      _registerElaboratedType(elaboratedType, binaryType);
    }

    if (type.members != null) {
      var members = <StructureMember>[];
      for (var member in type.members.elements) {
        members.add(_declareMember(member));
      }

      if (!members.isEmpty) {
        binaryType.addMembers(members, align: align, packed: packed);
      }
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
      case TypeSpecificationKind.BASIC:
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

  int _sizeof(TypeSpecification type) {
    _scope.enter();
    var binaryType = _resolveType(type);
    _scope.exit();
    return binaryType.size;
  }
}

class _Scope {
  List<Map<String, int>> enumerators;

  List<Map<String, BinaryType>> tags;

  List<Map<String, BinaryType>> types;

  int current = 0;

  int previous = 0;

  _Scope(BinaryTypes types) {
    enumerators = <Map<String, int>>[types._enumerators];
    tags = <Map<String, BinaryType>>[types._tags];
    this.types = <Map<String, BinaryType>>[types._types];
  }

  void enter() {
    enumerators.add(<String, int>{});
    tags.add(<String, BinaryType>{});
    types.add(<String, BinaryType>{});
    previous = current++;
  }

  void exit() {
    if (current <= 0) {
      throw new StateError("Cannot exit scope");
    }

    enumerators.removeLast();
    tags.removeLast();
    types.removeLast();
    current--;
    if (previous > 0) {
      previous--;
    }
  }

  int findEnumerator(String key, bool readOnly) {
    return _find(enumerators, key, readOnly);
  }

  BinaryType findTag(String key, bool readOnly) {
    return _find(tags, key, readOnly);
  }

  BinaryType findType(String key, bool readOnly) {
    return _find(types, key, readOnly);
  }

  dynamic _find(List<Map<String, dynamic>> scopes, String key, bool readOnly) {
    var type = scopes[current][key];
    if (type != null || !readOnly) {
      return type;
    }

    var index = current;
    while (--index >= 0) {
      type = scopes[index][key];
      if (type != null) {
        break;
      }
    }

    return type;
  }
}
