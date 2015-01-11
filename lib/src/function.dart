part of binary_types;

/**
 * Function binary type.
 */
class FunctionType extends BinaryType {
  /**
   * Type of the return value.
   */
  final BinaryType returnType;

  int _arity = 0;

  List<BinaryType> _parameters;

  bool _variadic = false;

  FunctionType(this.returnType, List<BinaryType> parameters, DataModel dataModel, {String name}) : super(dataModel, name: name) {
    if (returnType == null) {
      throw new ArgumentError.notNull("returnType");
    }

    if (parameters == null) {
      throw new ArgumentError.notNull("parameters");
    }

    if (returnType.dataModel != dataModel) {
      BinaryTypeError.differentDataModel("return type '$returnType'");
    }

    var length = parameters.length;
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

      // TODO: Implement
      /*
      if (parameter.size == 0) {
        BinaryTypeError.incompleteFunctionParameterType(i, parameter);
      }
      */

      _parameters[i] = parameter;
      if (parameter is VaListType) {
        if (_variadic) {
          BinaryTypeError.variableParameterMustBeLastParameter();
        }

        _variadic = true;
      } else {
        _arity++;
      }
    }

    if (_variadic && _arity == 0) {
      BinaryTypeError.variadicFunctionMustHaveAtLeastOneNamedParameter();
    }

    _namePrefix = "$returnType (";
    _nameSuffix = ")(${parameters.map((e) => e.name).join(", ")})";
    if (name == null) {
      _name = "$_namePrefix$_nameSuffix";
    }
  }

  int get align {
    BinaryTypeError.unableGetAlignmentIncompleteType(this);
    return null;
  }

  /**
   * Function arity (number of fixed arguments).
   */
  int get arity => _arity;

  dynamic get defaultValue {
    BinaryTypeError.unableGetDefaultValueForIncompleteType(this);
    return null;
  }

  BinaryKinds get kind => BinaryKinds.FUNCTION;

  List<BinaryType> get parameters => new UnmodifiableListView(_parameters);

  int get size => 0;

  /**
   * Indicates when the function is VARIADIC function.
   */
  bool get variadic => _variadic;

  bool operator ==(other) {
    if (other is FunctionType) {
      return _compatible(other, true);
    }

    return false;
  }

  FunctionType _clone(String name, {int align}) {
    return new FunctionType(returnType, _parameters, _dataModel, name: name);
  }

  bool _compatible(BinaryType other, bool strong) {
    if (other is FunctionType) {
      if (returnType._compatible(other.returnType, strong)) {
        if (arity == other.arity) {
          if (variadic == other.variadic) {
            var otherParameters = other.parameters;
            var length = parameters.length;
            for (var i = 0; i < length; i++) {
              if (!parameters[i]._compatible(otherParameters[i], strong)) {
                return false;
              }
            }

            return true;
          }
        }
      }
    }

    return false;
  }

  // TODO:
  String _refString(int level, [String identifier]) {
    var sb = new StringBuffer();
    sb.write(_namePrefix);
    sb.write("".padRight(level + 1, "*"));
    if (identifier != null) {
      sb.write(identifier);
    }

    sb.write(_nameSuffix);
    return sb.toString();
  }
}
