part of binary_types;

class VaListType extends BinaryType {
  VaListType(DataModel dataModel, {String name}) : super(dataModel, name: name) {
    if (name == null) {
      _name = "...";
      _namePrefix = "... ";
    }
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

  VaListType _clone(String name, {int align}) {
    return new VaListType(_dataModel, name: name);
  }
}
