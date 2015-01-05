part of binary_types;

class VoidType extends BinaryType {
  VoidType(DataModel dataModel) : super(dataModel) {
    _name = "void";
  }

  int get align {
    BinaryTypeError.unableGetAlignmentIncompleteType(this);
    return null;
  }

  dynamic get defaultValue {
    BinaryTypeError.unableGetDefaultValueForIncompleteType(this);
    return null;
  }

  BinaryKinds get kind => BinaryKinds.VOID;

  int get size => 0;

  bool operator ==(other) => other is VoidType;

  VoidType _clone({int align}) {
    return new VoidType(_dataModel);
  }
}
