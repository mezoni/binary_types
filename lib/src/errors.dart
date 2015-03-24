part of binary_types;

class BinaryTypeError implements Exception {
  final String message;

  const BinaryTypeError([this.message]);

  String toString() => "BinaryType error: $message";

  static void arrayNotAllowed(BinaryType type) {
    throw new BinaryTypeError("Creation an array of the type '$type' is not allowed");
  }

  static void declarationError(Declaration declaration, String message) {
    throw new BinaryTypeError("Declaration '$declaration' has error: $message");
  }

  static void differentDataModel([String subject]) {
    if (subject == null) {
      throw new BinaryTypeError("Different data models not allowed");
    } else {
      throw new BinaryTypeError("Different data models not allowed: $subject");
    }
  }

  static void enumeratorOutOfRange(EnumType type, String name, int value, BinaryType intType) {
    throw new BinaryTypeError("Enumerator '$name' ($value) is out of  '$intType' range for the type '$type'");
  }

  static void flexibleArrayMemberNotAtEndOfStruct(StructType structureType, String memberName) {
    throw new BinaryTypeError("Flexible array member '$memberName' not at end of struct '$structureType'");
  }

  static void functionReturingArray(String name, String returnType) {
    throw new BinaryTypeError("Function '$name' declared as returning an array '$returnType'");
  }

  static void illegalMemberName(BinaryType type, String name) {
    throw new BinaryTypeError("Illegal member name '$name' for the type '$type'");
  }

  static void incompleteFunctionParameterType(String name, int index, BinaryType parameter) {
    throw new BinaryTypeError("Illegal use of incomplete type '$parameter' as the #$index parameter of function '$name'");
  }

  static void incompleteMemberType(StructType structureType, BinaryType memberType) {
    throw new BinaryTypeError("Illegal use of incomplete type '$memberType' as the member of the type '$structureType'");
  }

  static void indexOutOfArange(BinaryType type, int index, int range) {
    throw new BinaryTypeError("Index '$index' out of range '$range' for the type '$type'");
  }

  static void integerSizeNotSupported(int size) {
    throw new BinaryTypeError("Integer type with a size $size is not supported by the specified data model");
  }

  static void memberNotFound(BinaryType type, String member) {
    throw new BinaryTypeError("Member '$member' not found in the type '$type'");
  }

  static void nullPointerException(BinaryType type) {
    if (type == null) {
      throw new BinaryTypeError("Null pointer exception");
    } else {
      throw new BinaryTypeError("Null pointer exception: '$type' value is NULL");
    }
  }

  static void onlyFirstMemberOfUnionCanBeInitialized() {
    throw new BinaryTypeError("Only the first member of a union can be initialized");
  }

  static void onlyOneMemberOfUnionCanBeInitialized() {
    throw new BinaryTypeError("Only one member of a union can be initialized");
  }

  static void redefinitionOfMemberIsNotAllowed(StructureType structureType, String memberName) {
    throw new BinaryTypeError("Redefinition of member '$memberName' is not allowed for the type '$structureType'");
  }

  static void requiresAtLeastOneMember(StructureType type) {
    throw new BinaryTypeError("Requires at least one member for the type '$type'");
  }

  static void stringValueIsTooLarge(String str) {
    throw new BinaryTypeError("String value is too large '$str'");
  }

  // TODO: Remove
  static void typeElementNotFound(BinaryType type, String name) {
    throw new BinaryTypeError("Type element '$name' not found in the type '$type'");
  }

  static void typeNotDefined(String name) {
    throw new BinaryTypeError("Type '$name' not defined");
  }

  static void unableAllocateMemoryForIncompleteType(BinaryType type) {
    throw new BinaryTypeError("Unable to allocate memory for incomplete type '$type'");
  }

  static void unableCloneIncompleteType(BinaryType type) {
    throw new BinaryTypeError("Unable to clone an incomplete type '$type'");
  }

  static void unableGetAlignmentIncompleteType(BinaryType type) {
    throw new BinaryTypeError("Unable to 'get alignment' for the incomplete type '$type'");
  }

  static void unableGetDefaultValueForIncompleteType(BinaryType type) {
    throw new BinaryTypeError("Unable to 'get default value' for the incomplete type '$type'");
  }

  static void unableGetOffsetOfBitFieldMember(StructureType structureType, String memberName) {
    throw new BinaryTypeError("Unable to 'get offset' of the bit-field member '$memberName' for the type '$structureType'");
  }

  static void unableModifyTypeSynonym(BinaryType original, String synonym) {
    throw new BinaryTypeError("Unable to modify the '$synonym' for the type '$original'");
  }

  static void unablePerformingOperation(BinaryType type, String operation, [Map arguments]) {
    if (arguments != null && arguments.length > 0) {
      throw new BinaryTypeError("Unable to '$operation' for the type '$type', arguments: $arguments");
    } else {
      throw new BinaryTypeError("Unable to '$operation' for the type '$type'");
    }
  }

  static void unableRedeclareType(String name) {
    throw new BinaryTypeError("Unable to redeclare the type '$name'");
  }

  static void unableRedeclareTypeWithTag(String name, String tag) {
    throw new BinaryTypeError("Unable to redeclare the type '$name' with tag '$tag'");
  }

  static void valueLengthExceedsArrayLength(ArrayType array, int length) {
    throw new BinaryTypeError("Value length '$length' exceeds the length '${array.length}' of the array '$array'");
  }

  static void valueLengthExceedsNumberOfMembers(BinaryType type, int number, int length) {
    throw new BinaryTypeError("Value length '$length' exceeds the number of members '$number' of the type '$type'");
  }

  static void valueLengthMustBeEqualArrayLength(ArrayType array, int length) {
    throw new BinaryTypeError("Value length '$length' must be the same as the length '${array.length}' of the array '$array'");
  }

  static void valueLengthMustBeEqualNumberOfMembers(BinaryType type, int number, int length) {
    throw new BinaryTypeError("Value length '$length' must be the same as the number of members '$number' of the type '$type'");
  }

  static void variableParameterMustBeLastParameter(String name) {
    throw new BinaryTypeError("Variable parameter type must be the last parameter type in function '$name'");
  }

  static void variadicFunctionMustHaveAtLeastOneNamedParameter() {
    throw new BinaryTypeError("Variadic function must have at least one named parameter");
  }

  static void wrongOrderOfVariadicFunctionParameters(String name) {
    throw new BinaryTypeError("Wrong order of parameters in the variadic function '$name'");
  }
}
