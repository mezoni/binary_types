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

  static void illegalMemberName(BinaryType type, String name) {
    throw new BinaryTypeError("Illegal member name '$name' for the type '$type'");
  }

  static void incompleteMemberType(BinaryType type, String name, value) {
    throw new BinaryTypeError("Illegal use of incomplete type '$value' as the member '$name' for the type '$type'");
  }

  static void indexOutOfArange(BinaryType type, int index, int range) {
    throw new BinaryTypeError("Index '$index' out of range '$range' for the type '$type'");
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

  // TODO: Remove
  static void stringValueIsTooLarge(String str) {
    throw new BinaryTypeError("String value is too large '$str'");
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

  static void variableParameterMustBeLastParameter() {
    throw new BinaryTypeError("Variable arguments parameter type must be the last parameter type");
  }

  static void variadicFunctionMustHaveAtLeastOneNamedParameter() {
    throw new BinaryTypeError("Variadic function must have at least one named parameter");
  }
}
