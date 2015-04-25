part of binary_types;

/**
 * Function binary type.
 */
class FunctionType extends BinaryType {
  static final Map<String, Object> _ids = <String, Object>{};

  Object _id;

  String _key;

  /**
   * Type of the return value.
   */
  final BinaryType returnType;

  /**
   * Indicates when the function is VARIADIC function.
   */
  final bool variadic;

  int _arity = 0;

  String _identifier;

  List<BinaryType> _parameters;

  FunctionType(String name, this.returnType, List<BinaryType> parameters, this.variadic, DataModel dataModel,
      {int align})
      : super(dataModel, align: align) {
    if (name == null) {
      throw new ArgumentError.notNull("name");
    }

    if (returnType == null) {
      throw new ArgumentError.notNull("returnType");
    }

    if (parameters == null) {
      throw new ArgumentError.notNull("parameters");
    }

    if (returnType.dataModel != dataModel) {
      BinaryTypeError.differentDataModel("return type '$returnType'");
    }

    switch (returnType.kind) {
      case BinaryKind.ARRAY:
        BinaryTypeError.wrongReturnType(name, "an array '$returnType'");
        break;
      case BinaryKind.FUNCTION:
        BinaryTypeError.wrongReturnType(name, "a function '$returnType'");
        break;
      default:
        break;
    }

    if (returnType.size == 0 && returnType.kind != BinaryKind.VOID) {
      BinaryTypeError.wrongReturnType(name, "an incomplete type '$returnType'");
    }

    var length = parameters.length;
    _arity = length;
    _parameters = new List<BinaryType>(length);
    for (var i = 0; i < length; i++) {
      var parameter = parameters[i];
      if (parameter is! BinaryType) {
        throw new ArgumentError("List of parameters contains illegal elements");
      }

      if (parameter.dataModel != dataModel) {
        BinaryTypeError.differentDataModel("parameter $i");
      }

      if (parameter is ArrayType) {
        parameter = new PointerType(parameter.type, dataModel);
      }

      _parameters[i] = parameter;
      if (parameter.size == 0) {
        BinaryTypeError.incompleteFunctionParameterType(name, i, parameter);
      }
    }

    if (variadic && _arity == 0) {
      BinaryTypeError.variadicFunctionMustHaveAtLeastOneNamedParameter();
    }

    if (align == null) {
      _align = _dataModel.alignOfPointer;
    }

    _identifier = name;
  }

  /**
   * Function arity (number of fixed arguments).
   */
  int get arity => _arity;

  dynamic get defaultValue {
    BinaryTypeError.unableGetDefaultValueForIncompleteType(this);
    return null;
  }

  /**
   * Returns the identifier.
   */
  String get identifier => _identifier;

  BinaryKind get kind => BinaryKind.FUNCTION;

  String get name {
    if (_name == null) {
      _name = formatName();
    }

    return _name;
  }

  List<BinaryType> get parameters => new UnmodifiableListView(_parameters);

  int get size => 1;

  FunctionType _clone({int align}) {
    var clone = new FunctionType(name, returnType, _parameters, variadic, _dataModel, align: align);
    clone._id = _getId();
    clone._key = _getKey();
    return clone;
  }

  bool _compatible(BinaryType other, bool strong) {
    if (other is FunctionType) {
      if (_getId() == other._getId()) {
        return true;
      }
    }

    return false;
  }

  Object _getId() {
    if (_id == null) {
      var key = _getKey();
      _id = _ids[key];
      if (_id == null) {
        _id = new Object();
        _ids[key] = _id;
      }
    }

    return _id;
  }

  String _getKey() {
    if (_key == null) {
      var sb = new StringBuffer();
      sb.write(returnType._getKey());
      sb.write("(");
      var list = new List(_arity);
      for (var i = 0; i < _arity; i++) {
        list[i] = _parameters[i]._getKey();
      }

      sb.writeAll(list, " ");
      if (variadic) {
        sb.write(" ...");
      }

      sb.write(")");
      _key = sb.toString();
    }

    return _key;
  }
}
