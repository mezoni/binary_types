part of binary_types;

class VaListType extends BinaryType {
  VaListType(DataModel dataModel) : super(dataModel) {
    _name = "...";
  }

  int get align {
    BinaryTypeError.unableGetAlignmentIncompleteType(this);
    return null;
  }

  dynamic get defaultValue {
    BinaryTypeError.unableGetDefaultValueForIncompleteType(this);
    return null;
  }

  BinaryKinds get kind => BinaryKinds.VA_LIST;

  int get size => 0;

  bool operator ==(other) => other is VaListType;

  VaListType _clone({int align}) {
    return new VaListType(_dataModel);
  }
}
