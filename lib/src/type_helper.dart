part of binary_types;

class BinaryTypeHelper {
  final BinaryTypes types;

  BinaryType _char;

  DataModel _dataModel;

  BinaryTypeHelper(this.types) {
    if (types == null) {
      throw new ArgumentError.notNull("types");
    }

    _char = types["char"];
    _dataModel = types["int"].dataModel;
  }

  /**
   * Data model of binary types.
   */
  DataModel get dataModel => _dataModel;

  /**
   * Allocates the memory for null-terminated string and returns the binary
   * array object.
   *
   * Parameters:
   *   [String] string
   *   String to allocate.
   */
  BinaryObject allocString(String string) {
    if (string == null) {
      throw new ArgumentError.notNull("string");
    }

    var characters = string.codeUnits;
    var length = characters.length;
    var address = Unsafe.memoryAllocate(length + 1);
    return _char.array(characters.length + 1).alloc(characters);
  }

  /**
   * Declares the types specified in textual format.
   *
   * Parameters:
   *   [String] text
   *   Declarations in textual format.
   *
   *   [Map]<[String], [String]> environment
   *   Environment values for preprocessing declarations.
   *
   *   [Map]<[String], [FunctionType]> functions
   *   Symbol table for the declared functions.
   *
   *   [Map]<[String], [BinaryType]> variables
   *   Symbol table for the declared variables.
   */
  Declarations declare(String source, {Map<String, String> environment, Map<String, FunctionType> functions, Map<String, BinaryType> variables}) {
    var declaration = new _Declarations(types);
    return declaration.declare(source, environment: environment, functions: functions, variables: variables);
  }

  /**
   * Reads the null-terminated string from memory.
   *
   * Parameters:
   *   [BinaryData] data
   *   Reference to the null-terminated string.
   */
  String readString(BinaryData data) {
    if (data == null) {
      throw new ArgumentError.notNull("reference");
    }

    var type = data.type;
    if (type is ArrayType) {
      type = type.type;
    }

    if (type is! IntType) {
      throw new ArgumentError("Character type '$type' should be an integer type");
    }

    if (data.isNullPtr) {
      BinaryTypeError.nullPointerException(type);
    }

    var base = data.base;
    var offset = data.offset;
    var size = type.size;
    var characters = <int>[];
    var index = 0;
    while (true) {
      var value = type.getValue(base, offset);
      if (value == 0) {
        break;
      }

      characters.add(value);
      offset += size;
    }

    return new String.fromCharCodes(characters);
  }
}
