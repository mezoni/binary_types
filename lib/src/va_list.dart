part of binary_types;

class VaListType extends BinaryType {
  VaListType(DataModel dataModel, {String name}) : super(dataModel);

  int get align {
    BinaryTypeError.unableGetAlignmentIncompleteType(this);
    return null;
  }

  dynamic get defaultValue {
    BinaryTypeError.unableGetDefaultValueForIncompleteType(this);
    return null;
  }

  BinaryKinds get kind => BinaryKinds.VA_LIST;

  String get name {
    if (_name == null) {
      _name = "...";
    }

    return _name;
  }

  int get size => 0;

  VaListType _clone({int align}) {
    return new VaListType(_dataModel);
  }

  bool _compatible(BinaryType other, bool strong) {
    return other.kind == BinaryKinds.VA_LIST && other.dataModel == dataModel;
  }
}
