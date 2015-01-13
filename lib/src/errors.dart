part of binary_types;

class BinaryTypeError implements Exception {
  final String message;

  const BinaryTypeError([this.message]);

  String toString() => "BinaryType error: $message";

  static void arrayNotAllowed(BinaryType type) {
    throw new BinaryTypeError("Creation an array of the type '$type' is not allowed");
  }

  static void differentDataModel(String subject) {
    throw new BinaryTypeError("Different data models not allowed: $subject");
  }

  static void enumerationValueOutOfRange(EnumType type, String name, int value, BinaryType intType) {
    throw new BinaryTypeError("Enumeration value '$name' ($value) is out of  '$intType' range for the type '$type'");
  }

  static void illegalMemberName(BinaryType type, String name) {
    throw new BinaryTypeError("Illegal member name '$name' for the type '$type'");
  }

  static void incompleteFunctionParameterType(String name, int index, BinaryType parameter) {
    throw new BinaryTypeError("Illegal use of incomplete type '$parameter' as the parameter #'$index' of function '$name'");
  }

  static void incompleteMemberType(BinaryType type, String name, BinaryType member) {
    throw new BinaryTypeError("Illegal use of incomplete type '$member' as the member '$name' for the type '$type'");
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

  static void onlyFirstMemberOfUnionCanBeInitialized() {
    throw new BinaryTypeError("Only the first member of a union can be initialized");
  }

  static void onlyOneMemberOfUnionCanBeInitialized() {
    throw new BinaryTypeError("Only one member of a union can be initialized");
  }

  static void redefinitionOfMembersIsNotAllowed(BinaryType type) {
    throw new BinaryTypeError("Redefinition of members is not allowed for the type '$type'");
  }

  static void requiresAtLeastOneMember(BinaryType type) {
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
    throw new BinaryTypeError("Unable to 'get default' for the incomplete type '$type'");
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
