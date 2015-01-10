part of binary_types;

class VoidType extends BinaryType {
  VoidType(DataModel dataModel, {String name}) : super(dataModel, name: name) {
    if (name == null) {
      _name = "void";
      _namePrefix = "void ";
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

  BinaryKinds get kind => BinaryKinds.VOID;

  int get size => 0;

  bool operator ==(other) => other is VoidType;

  VoidType _clone(String name, {int align}) {
    return new VoidType(_dataModel, name: name);
  }
}
