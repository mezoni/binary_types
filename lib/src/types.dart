part of binary_types;

/**
 * Binary types.
 */
class BinaryTypes {
  /**
   * Data model of binary types.
   */
  DataModel _dataModel;

  Map<String, BinaryType> _types = new Map<String, BinaryType>();

  BinaryTypes({DataModel dataModel}) {
    if (dataModel == null) {
      dataModel = new DataModel();
    }

    _dataModel = dataModel;
    _init();
  }

  BinaryType operator [](String name) {
    if (name == null) {
      throw new ArgumentError("name: $name");
    }

    var type = _types[name];
    if (type != null) {
      return type;
    }

    var charCodes = name.codeUnits;
    var length = charCodes.length;
    if (length > 2) {
      var c = charCodes[length - 1];
      // Pointers
      if (c == 42) {
        var name = new String.fromCharCodes(charCodes.sublist(0, length - 1));
        return this[name].ptr();
      }

      // Arrays
      if (c == 93) {
        for (var i = length - 2; i > 0; i--) {
          var c = charCodes[i];
          if (!(c >= 48 && c <= 57)) {
            if (i > 0 && c == 91) {
              var size = int.parse(new String.fromCharCodes(charCodes.sublist(i + 1, length - 1)), onError: (s) {});
              if (size != null && size >= 0) {
                var name = new String.fromCharCodes(charCodes.sublist(0, i));
                return this[name].array(size);
              }
            }

            break;
          }
        }
      }
    }

    BinaryTypeError.typeNotDefined(name);
    return null;
  }

  /**
   * DEPRECATED! Use "binary declarations" instead
   *
   * Clones the binary type and register it under a different name (typedef).
   */
  @deprecated
  void operator []=(String name, type) {
    BinaryType binaryType;
    if (type is String) {
      binaryType = this[type];
    } else if (type is BinaryType) {
      binaryType = type;
      _checkDataModel(binaryType, "type $type");
    } else {
      throw new ArgumentError("name: $type");
    }

    _typeDef(name, binaryType);
  }

  /**
   * Declares the types specified in textual format.
   *
   * Parameters:
   *   [String] text
   *   Declarations in textual format.
   *
   *   [Map]<[String], [String]> environment
   *   Environment values for preprocessing declarations.
   */
  void declare(String text, {Map<String, String> environment}) {
    if (text == null) {
      throw new ArgumentError.notNull("text");
    }

    var helper = new BinaryTypeHelper(this);
    var declarations = new BinaryDeclarations(text);
    for (var declaration in declarations) {
      if (declaration is TypedefDeclaration) {
        var attributes = _getAttributes(declaration.attributes);
        var align = _getAttributeAligned(attributes);
        var name = declaration.name;
        var type = declaration.type;
        BinaryType binaryType;
        if (type is StructureTypeSpecification) {
          binaryType = _declareStructure(type);
        } else {
          binaryType = this[type.toString()];
        }

        typeDef(name, binaryType, align: align);
      } else if (declaration is StructureDeclaration) {
        _declareStructure(declaration.type);
      } else if (declaration is VariableDeclaration) {
        if (declaration.type is StructureTypeSpecification) {
          _declareStructure(declaration.type);
        }
      }
    }
  }

  /**
   * DEPRECATED! Use "binary declarations" instead
   *
   * Registers the binary type in the type system.
   *
   * Parameters:
   *   [BinaryType] type
   *   Type to register
   */
  @deprecated
  BinaryType registerType(BinaryType type) {
    if (type == null) {
      throw new ArgumentError.notNull("type");
    }

    _checkDataModel(type, "type $type");
    var name = type.name;
    if (_types.containsKey(name)) {
      BinaryTypeError.unableRedeclareType(name);
    }

    _types[name] = type;
    return type;
  }

  /**
   * DEPRECATED! Use "binary declarations" instead
   *
   * Clones the binary type and register it under a different name (typedef).
   *
   * Parameters:
   *   [String] name
   *   New name for cloned type.
   *
   *   [BinaryType|String] type
   *   Type (or name) to clone.
   *
   *   [int] align
   *   Data alignment for this type.
   */
  @deprecated
  BinaryType typeDef(String name, type, {int align}) {
    if (type == null) {
      throw new ArgumentError.notNull("type");
    }

    return _typeDef(name, type, align: align);
  }

  void _checkDataModel(BinaryType type, String subject) {
    if (type.dataModel != _dataModel) {
      BinaryTypeError.differentDataModel(subject);
    }
  }

  // TODO: Improve _checkTypeName()
  void _checkTypeName(String name) {
    if (name == null || name.isEmpty || name.trim() != name) {
      throw new ArgumentError("name: $name");
    }

    if (name == "struct" || name == "union") {
      throw new ArgumentError("name: $name");
    }
  }

  void _cloneInt(int size, bool signed, List<String> names, String name) {
    var type = IntType.create(size, signed, _dataModel);
    for (var fullname in names) {
      var copy = type.clone(name);
      copy._namePrefix = "$name ";
      copy._typedefName = "";
      _types[fullname] = copy;
    }
  }

  BinaryType _declareStructure(StructureTypeSpecification type) {
    // TODO: Use attributes
    var align = null;
    var taggedType = type.taggedType;
    var kind = taggedType.kind;
    var pack = null;
    var tag = taggedType.tag;

    StructureType structureType;
    var key = "$kind $tag";
    if (tag != null) {
      structureType = _types[key];
      if (structureType != null) {
        BinaryTypeError.unableRedeclareType(key);
      }
    }

    if (structureType == null) {
      switch (taggedType.kind) {
        case TaggedTypeKinds.STRUCT:
          structureType = new StructType(tag, null, _dataModel, align: align, pack: pack);
          break;
        case TaggedTypeKinds.UNION:
          structureType = new UnionType(tag, null, _dataModel, align: align, pack: pack);
          break;
      }

      if (tag != null) {
        _types[key] = structureType;
      }
    }

    var members = {};
    for (var member in type.members) {
      var memberType = member.type;
      var name = member.name;
      BinaryType binaryType;
      if (memberType is StructureTypeSpecification) {
        binaryType = _declareStructure(memberType);
      } else {
        binaryType = this[memberType.toString()];
      }

      members[name] = binaryType;
    }

    if (!members.isEmpty) {
      structureType.addMembers(members, pack: pack);
    }

    return structureType;
  }

  int _getAttributeAligned(Map attributes) {
    var value = attributes["aligned"];
    if (value == null) {
      return null;
    }

    return int.parse(value, onError: (e) => null);
  }

  Map<String, String> _getAttributes(BinaryAttributes attributes) {
    var result = {};
    if (attributes == null) {
      return result;
    }

    for (var value in attributes.values) {
      result[value.name] = value.parameters;
    }

    return result;
  }

  BinaryType _getType(type, [BinaryType defaultType]) {
    if (type is String) {
      return this[type];
    } else if (type is BinaryType) {
      return type;
    }

    if (defaultType != null) {
      return defaultType;
    }

    throw new ArgumentError("type: $type");
  }

  void _init() {
    // char
    _cloneInt(_dataModel.sizeOfChar, _dataModel.isCharSigned, const ["char"], "char");

    // Signed integers
    _cloneInt(_dataModel.sizeOfChar, true, const ["signed char"], "signed char");
    _cloneInt(_dataModel.sizeOfShort, true, const ["short", "short int", "signed short", "signed short int"], "short");
    _cloneInt(_dataModel.sizeOfInt, true, const ["int", "signed", "signed int"], "int");
    _cloneInt(_dataModel.sizeOfLong, true, const ["long", "long int", "signed long", "signed long int"], "long");
    _cloneInt(_dataModel.sizeOfLongLong, true, const ["long long", "long long int", "signed long long", "signed long long int"], "long long");

    // Unsigned integers
    _cloneInt(_dataModel.sizeOfChar, false, const ["unsigned char"], "unsigned char");
    _cloneInt(_dataModel.sizeOfShort, false, const ["unsigned short", "unsigned short int"], "unsigned short");
    _cloneInt(_dataModel.sizeOfInt, false, const ["unsigned", "unsigned int"], "unsigned int");
    _cloneInt(_dataModel.sizeOfLong, false, const ["unsigned long", "unsigned long int"], "unsigned long");
    _cloneInt(_dataModel.sizeOfLongLong, false, const ["unsigned long long", "unsigned long long int"], "unsigned long long");

    // Fixed size integers
    // TODO: See in Visual Studio how they displayed in hints
    _cloneInt(1, true, const ["int8_t"], "int8_t");
    _cloneInt(2, true, const ["int16_t"], "int16_t");
    _cloneInt(4, true, const ["int32_t"], "int32_t");
    _cloneInt(8, true, const ["int64_t"], "int64_t");
    _cloneInt(1, false, const ["uint8_t"], "uint8_t");
    _cloneInt(2, false, const ["uint16_t"], "uint16_t");
    _cloneInt(4, false, const ["uint32_t"], "uint32_t");
    _cloneInt(8, false, const ["uint64_t"], "uint64_t");

    // Pointer size
    // TODO: See in Visual Studio how they displayed in hints
    _cloneInt(_dataModel.sizeOfPointer, true, const ["intptr_t"], "intptr_t");

    // Array size
    // TODO: See in Visual Studio how they displayed in hints
    _cloneInt(_dataModel.sizeOfPointer, false, const ["size_t"], "size_t");

    // Floating points
    _types["float"] = new FloatType(_dataModel);
    _types["double"] = new DoubleType(_dataModel);

    // Void
    _types["void"] = new VoidType(_dataModel);

    // Variable arguments
    _types["..."] = new VaListType(_dataModel);
  }


  BinaryType _typeDef(String name, type, {int align}) {
    _checkTypeName(name);
    BinaryType binaryType;
    if (type is String) {
      binaryType = this[type];
    } else if (type is BinaryType) {
      binaryType = type;
      _checkDataModel(binaryType, "type $type");
    } else {
      throw new ArgumentError("name: $type");
    }

    var previous = _types[name];
    if (previous != null && previous != type) {
      BinaryTypeError.unableRedeclareType(name);
    }

    var copy = binaryType.clone(name, align: align);
    _types[name] = copy;
    return copy;
  }
}
