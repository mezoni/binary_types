part of binary_types;

class VoidType extends BinaryType {
  VoidType(DataModel dataModel) : super(dataModel);

  int get align {
    BinaryTypeError.unableGetAlignmentIncompleteType(this);
    return null;
  }

  dynamic get defaultValue {
    BinaryTypeError.unableGetDefaultValueForIncompleteType(this);
    return null;
  }

  BinaryKind get kind => BinaryKind.VOID;

  String get name {
    if (_name == null) {
      _name = "void";
    }

    return _name;
  }

  int get size => 0;

  VoidType _clone({int align}) {
    return new VoidType(_dataModel);
  }

  bool _compatible(BinaryType other, bool strong) {
    return other.kind == BinaryKind.VOID && other.dataModel == dataModel;
  }
}
