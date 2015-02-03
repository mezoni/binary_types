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

  String _identifier;

  List<BinaryType> _parameters;

  bool _variadic = false;

  FunctionType(String name, this.returnType, List<BinaryType> parameters, DataModel dataModel, {int align}) : super(dataModel, align: align) {
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

      _parameters[i] = parameter;
      if (parameter is VaListType) {
        if (i != length - 1) {
          BinaryTypeError.variableParameterMustBeLastParameter(name);
        }

        _variadic = true;
      } else {
        if (parameter.size == 0) {
          BinaryTypeError.incompleteFunctionParameterType(name, i, parameter);
        }

        if (_variadic) {
          BinaryTypeError.wrongOrderOfVariadicFunctionParameters(name);
        }

        _arity++;
      }
    }

    if (_variadic && _arity == 0) {
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

  BinaryKinds get kind => BinaryKinds.FUNCTION;

  String get name {
    if (_name == null) {
      _name = formatName();
    }

    return _name;
  }

  List<BinaryType> get parameters => new UnmodifiableListView(_parameters);

  int get size => _dataModel.sizeOfPointer;

  /**
   * Indicates when the function is VARIADIC function.
   */
  bool get variadic => _variadic;

  FunctionType _clone({int align, bool packed}) {
    return new FunctionType(name, returnType, _parameters, _dataModel);
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

            return other.dataModel == dataModel;
          }
        }
      }
    }

    return false;
  }
}
