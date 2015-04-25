part of binary_types;

abstract class BinaryType {
  static bool typeChecking = true;

  int _align;

  DataModel _dataModel;

  String _name;

  BinaryType _original;

  String _typedefName = "";

  BinaryType(DataModel dataModel, {int align}) {
    if (dataModel == null) {
      throw new ArgumentError.notNull("dataModel");
    }

    if (align != null) {
      _Utils.checkPowerOfTwo(align, "align");
    }

    _align = align;
    _dataModel = dataModel;
    _original = this;
  }

  /**
   * Returns the alignment in bytes, required for any instance of the type.
   */
  int get align {
    if (_align == null) {
      BinaryTypeError.unableGetAlignmentIncompleteType(this);
    }

    return _align;
  }

  /**
   * Returns the model of binary data.
   */
  DataModel get dataModel => _dataModel;

  /**
   * Returns the defualt value of binary data.
   */
  dynamic get defaultValue;

  /**
   * Indicates that the type is the original type and is not a synonym.
   */
  bool get isOriginal => identical(this, original);

  /**
   * Returns the kind of binary type.
   */
  BinaryKind get kind;

  /**
   * Returns the name of binary type.
   */
  //String get name => _name;
  String get name;

  /**
   * Returns the binary object at NULL address.
   * Does not allocates the memory.
   *
   * Parameters:
   */
  BinaryObject get nullPtr {
    return new BinaryObject._internal(this, 0, 0);
  }

  /**
   * Returns the original binary type for the typedef types.
   */
  BinaryType get original => _original;

  /**
   * Returns the amount of storage, in bytes, required to store any instance of
   * the type.
   */
  int get size;

  /**
   * Returns the typedef name of binary type.
   */
  String get typedefName => _typedefName;

  bool operator ==(other) => _compatible(other, true);

  /**
   * Returns the member or value for tagged binary type (enum, struct, union).
   */
  dynamic operator [](String name) {
    return getTypeElement(name);
  }

  /**
   * Allocates the memory for the instance of type and returns the data holder.
   *
   * Parameters:
   *   [dynamic] value
   *   Initial value for the filling.
   */
  BinaryObject alloc([value]) {
    return new BinaryObject._alloc(this, value);
  }

  /**
   * Returns the binary array type with specified size.
   *
   * Parameters:
   *   [int] size
   *   Size of array type.
   */
  BinaryType array(int size) {
    return new ArrayType(this, size, _dataModel);
  }

  /**
   * Convert the value in the value of this type.
   *
   * Parameters:
   *   [dynamic] value
   *   Value to convert.
   */
  dynamic cast(value) {
    return _cast(value);
  }

  /**
   * Clones the type.
   *
   * Parameters:
   *   [String] name
   *   Name of the cloned type.
   *
   *   [int] align
   *   Data alignment for this type.
   *
   *   [bool] packed
   *   Indicates that data should be packed or not.
   */
  BinaryType clone(String name, {int align}) {
    if (name == null) {
      throw new ArgumentError.notNull("null");
    }

    if (align == null && size != 0) {
      align = this.align;
    }

    var copy = _clone(align: align);
    copy._name = name;
    copy._original = this._original;
    copy._typedefName = "typedef ${formatName(identifier: name)}";
    return copy;
  }

  /**
   * Compares the content of this type, at the specified base and offset, with
   * the given value.
   *
   * Parameters:
   *   [int] base
   *   Base part of the address.
   *
   *   [int] offset
   *   Offset part of the address.
   *
   *   [dynamic] value
   *   Value to compare.
   */
  bool compareContent(int base, int offset, value) {
    return _compareContent(base, offset, value);
  }

  /**
   * TODO: Undocumented
   */
  bool compatible(BinaryType other, bool strong) {
    if (other == null) {
      throw new ArgumentError.notNull("other");
    }

    if (strong == null) {
      throw new ArgumentError.notNull("strong");
    }

    return _compatible(other, strong);
  }

  /**
   * Creates the type.
   *
   * Parameters:
   *  [String] name
   *   Name of the copied type; otherwise null.
   *
   *   [int] align
   *   Data alignment for this type.
   *
   *   [bool] packed
   *   Indicates that data should be packed or not.
   */
  BinaryType copy([String name]) {
    var copy = _clone();
    if (name == null) {
      copy._name = this.name;
    } else {
      copy._name = name;
    }

    if (original == this) {
      copy._original = copy;
    } else {
      copy._original = original;
    }

    return copy;
  }

  /**
   * Creates and returns the binary data for this type at the specified memory
   * base and offset.
   * Does not allocates and does not frees memory.
   *
   * Parameters:
   *   [int] base
   *   Base part of the address.
   *
   *   [int] offset
   *   Offset part of the address.
   */
  BinaryData extern(int base, [int offset = 0]) {
    return new BinaryData._internal(this, base, offset);
  }

  /**
   * Returns the formed name of binary type.
   *
   * Parameters:
   *
   *   [String] identifiier
   *   Identifier.
   *
   *   [int] references
   *   Number of references.
   */
  String formatName({String identifier, int pointers: 0}) {
    if (pointers == null || pointers < 0) {
      throw new ArgumentError.value(pointers, "pointers");
    }

    String dimensions(ArrayType type) {
      String result;
      var length = type.length;
      String lengthAsString;
      if (length == 0) {
        lengthAsString = "";
      } else {
        lengthAsString = "$length";
      }

      var elementType = type.type;
      if (elementType is ArrayType) {
        ArrayType arrayType = elementType;
        result = "${dimensions(arrayType)}";
        result = "[$lengthAsString]$result";
      } else {
        result = "[$lengthAsString]";
      }

      return result;
    }

    var sb = new StringBuffer();
    if (!identical(this, original)) {
      sb.write(name);
      sb.write(" ");
      sb.write("".padRight(pointers, "*"));
      if (identifier != null) {
        sb.write(identifier);
      }
    } else {
      switch (kind) {
        case BinaryKind.ARRAY:
          ArrayType arrayType = this;
          var targetType = arrayType._targetType;
          var type = arrayType.type;
          if (pointers == 0) {
            sb.write(targetType);
            if (targetType.kind != BinaryKind.POINTER) {
              sb.write(" ");
            }

            if (identifier != null) {
              sb.write(identifier);
            }

            //sb.write(arrayType._dimensions);
            sb.write(dimensions(arrayType));
          } else {
            if (type is ArrayType) {
              var string = targetType.formatName();
              sb.write(string);
              sb.write("(");
              sb.write("".padRight(pointers, "*"));
              if (identifier != null) {
                sb.write(identifier);
              }

              sb.write(")");
              //sb.write(type._dimensions);
              sb.write(dimensions(type));
            } else {
              var string = targetType.formatName(pointers: pointers);
              sb.write(string);
              if (identifier != null) {
                sb.write(identifier);
              }
            }
          }

          break;
        case BinaryKind.FUNCTION:
          FunctionType functionType = this;
          sb.write(functionType.returnType);
          sb.write(" ");
          if (pointers != 0) {
            sb.write("(");
          }

          sb.write("".padRight(pointers, "*"));
          sb.write(functionType._identifier);
          if (pointers != 0) {
            sb.write(")");
          }

          sb.write("(");
          var parameters = functionType.parameters;
          if (!parameters.isEmpty) {
            var string = parameters.map((type) => type.name).join(", ");
            sb.write(string);
          }

          if (functionType.variadic) {
            if (!parameters.isEmpty) {
              sb.write(", ");
            }

            sb.write("...");
          }

          sb.write(")");
          break;
        case BinaryKind.POINTER:
          PointerType pointerType = this;
          var targetType = pointerType._targetType;
          var string = targetType.formatName(identifier: identifier, pointers: pointers + pointerType.level + 1);
          sb.write(string);
          break;
        default:
          sb.write(name);
          sb.write(" ");
          sb.write("".padRight(pointers, "*"));
          if (identifier != null) {
            sb.write(identifier);
          }

          break;
      }
    }

    return sb.toString();
  }

  /**
   * Returns the element of this type by the index, at the specified memory
   * base and offset.
   *
   * Parameters:
   *   [int] base
   *   Base part of the address.
   *
   *   [int] offset
   *   Offset part of the address.
   *
   *   [dynamic] index
   *   Index of the element.
   */
  BinaryData getElement(int base, int offset, index) {
    if (base == null) {
      throw new ArgumentError("base: $base");
    }

    if (offset == null) {
      throw new ArgumentError("offset: $offset");
    }

    return _getElement(base, offset, index);
  }

  /**
   * Returns the value of the element of this type, by index, at the specified
   * memory base and offset.
   *
   * Parameters:
   *   [int] base
   *   Base part of the address.
   *
   *   [int] offset
   *   Offset part of the address.
   *
   *   [dynamic] index
   *   Index of the element.
   */
  dynamic getElementValue(int base, int offset, index) {
    if (base == null) {
      throw new ArgumentError("base: $base");
    }

    if (offset == null) {
      throw new ArgumentError("offset: $offset");
    }

    return _getElementValue(base, offset, index);
  }

  /**
   * Returns the type element specific to a particular type.
   *
   * Parameters:
   *   [String] name
   *   Name of the member
   */
  dynamic getTypeElement(String name) {
    if (name == null) {
      throw new ArgumentError.notNull("name");
    }

    return _getTypeElement(name);
  }

  /**
   * Returns the value of this type, at the specified memory base and offset.
   *
   * Parameters:
   *   [int] base
   *   Base part of the address.
   *
   *   [int] offset
   *   Offset part of the address.
   */
  dynamic getValue(int base, int offset) {
    if (base == null) {
      throw new ArgumentError("base: $base");
    }

    if (offset == null) {
      throw new ArgumentError("offset: $offset");
    }

    return _getValue(base, offset);
  }

  /**
   * Creates and returns the bogus binary object at NULL address.
   * Does not allocates and does not frees memory.
   *
   * Parameters:
   */
  @deprecated
  BinaryObject nullObject() {
    return new BinaryObject._internal(this, 0, 0);
  }

  /**
   * Returns the offset of specified field in the structural type.
   *
   * Parameters:
   *   [String] member
   *   Name of the member.
   */
  int offsetOf(String member) {
    return _offsetOf(member);
  }

  /**
   * Returns the binary pointer type.
   *
   * Parameters:
   */
  BinaryType ptr() {
    return new PointerType(this, _dataModel);
  }

  /**
   * Sets the content of this type to specified value, at the specified memory
   * base and offset.
   *
   * Parameters:
   *   [int] base
   *   Base part of the address.
   *
   *   [int] offset
   *   Offset part of the address.
   *
   *   [dynamic] value
   *   Value to set.
   */
  void setContent(int base, int offset, value) {
    if (base == null) {
      throw new ArgumentError("base: $base");
    }

    if (offset == null) {
      throw new ArgumentError("offset: $offset");
    }

    _setContent(base, offset, value);
  }

  /**
   * Sets the element of this type, by index, to specified value, at the
   * specified memory base and offset.
   *
   * Parameters:
   *   [int] base
   *   Base part of the address.
   *
   *   [int] offset
   *   Offset part of the address.
   *
   *   [dynamic] index
   *   Index of the element.
   *
   *   [dynamic] value
   *   Value to set.
   */
  void setElement(int base, int offset, index, value) {
    if (base == null) {
      throw new ArgumentError("base: $base");
    }

    if (offset == null) {
      throw new ArgumentError("offset: $offset");
    }

    _setElement(base, offset, index, value);
  }

  /**
   * Sets the value of the element of this type, by index, to specified value,
   * at the specified memory base and offset.
   *
   * Parameters:
   *   [int] base
   *   Base part of the address.
   *
   *   [int] offset
   *   Offset part of the address.
   *
   *   [dynamic] index
   *   Index of the element.
   *
   *   [dynamic] value
   *   Value to set.
   */
  void setElementValue(int base, int offset, index, value) {
    if (base == null) {
      throw new ArgumentError("base: $base");
    }

    if (offset == null) {
      throw new ArgumentError("offset: $offset");
    }

    _setElementValue(base, offset, index, value);
  }

  /**
   * Sets the value of this type to specified value, at the specified memory
   * base and offset.
   *
   * Parameters:
   *   [int] base
   *   Base part of the address.
   *
   *   [int] offset
   *   Offset part of the address.
   *    *
   *   [dynamic] value
   *   Value to set.
   */
  void setValue(int base, int offset, value) {
    if (base == null) {
      throw new ArgumentError("base: $base");
    }

    if (offset == null) {
      throw new ArgumentError("offset: $offset");
    }

    _setValue(base, offset, value);
  }

  /**
   * Returns the string representation.
   */
  String toString() => name;

  dynamic _cast(value) {
    BinaryTypeError.unablePerformingOperation(this, "cast", {"value": value});
    return null;
  }

  BinaryType _clone({int align});

  bool _compareContent(int base, int offset, value) {
    BinaryTypeError.unablePerformingOperation(this, "compare content", {"value": value});
    return null;
  }

  bool _compatible(BinaryType other, bool strong);

  BinaryData _getElement(int base, int offset, index) {
    BinaryTypeError.unablePerformingOperation(this, "get element", {"index": index});
    return null;
  }

  dynamic _getElementValue(int base, int offset, index) {
    BinaryTypeError.unablePerformingOperation(this, "get element value", {"index": index});
    return null;
  }

  String _getKey();

  dynamic _getTypeElement(String name) {
    BinaryTypeError.typeElementNotFound(this, name);
    return null;
  }

  dynamic _getValue(int base, int offset) {
    BinaryTypeError.unablePerformingOperation(this, "get value");
    return null;
  }

  void _initialize(int base, int offset, value) {
    BinaryTypeError.unablePerformingOperation(this, "initialize", {"value": value});
  }

  int _offsetOf(String member) {
    BinaryTypeError.unablePerformingOperation(this, "offset of", {"member": member});

    return null;
  }

  void _setContent(int base, int offset, value) {
    BinaryTypeError.unablePerformingOperation(this, "set content", {"value": value});
  }

  void _setElement(int base, int offset, index, value) {
    BinaryTypeError.unablePerformingOperation(this, "set element", {"index": index, "value": value});
  }

  void _setElementValue(int base, int offset, index, value) {
    BinaryTypeError.unablePerformingOperation(this, "set element value", {"index": index, "value": value});
  }

  void _setValue(int base, int offset, value) {
    BinaryTypeError.unablePerformingOperation(this, "set value", {"value": value});
  }
}
