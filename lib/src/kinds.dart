part of binary_types;

class BinaryKinds {
  static const BinaryKinds ARRAY = const BinaryKinds("ARRAY");

  static const BinaryKinds BOOL = const BinaryKinds("BOOL");

  static const BinaryKinds DOUBLE = const BinaryKinds("DOUBLE");

  static const BinaryKinds ENUM = const BinaryKinds("ENUM");

  static const BinaryKinds FLOAT = const BinaryKinds("FLOAT");

  static const BinaryKinds FUNCTION = const BinaryKinds("FUNCTION");

  static const BinaryKinds POINTER = const BinaryKinds("POINTER");

  static const BinaryKinds SINT16 = const BinaryKinds("SINT16");

  static const BinaryKinds SINT32 = const BinaryKinds("SINT32");

  static const BinaryKinds SINT64 = const BinaryKinds("SINT64");

  static const BinaryKinds SINT8 = const BinaryKinds("SINT8");

  static const BinaryKinds STRUCT = const BinaryKinds("STRUCT");

  static const BinaryKinds UINT16 = const BinaryKinds("UINT16");

  static const BinaryKinds UINT32 = const BinaryKinds("UINT32");

  static const BinaryKinds UINT64 = const BinaryKinds("UINT64");

  static const BinaryKinds UINT8 = const BinaryKinds("UINT8");

  static const BinaryKinds VOID = const BinaryKinds("VOID");

  final String _name;

  const BinaryKinds(this._name);

  String toString() {
    return _name;
  }
}
