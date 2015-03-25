part of binary_types;

class BinaryTypeHelper {
  final BinaryTypes types;

  BinaryType _char;

  DataModel _dataModel;

  Map<String, int> _enumerators;

  BinaryTypeHelper(this.types) {
    if (types == null) {
      throw new ArgumentError.notNull("types");
    }

    _char = types["char"];
    _dataModel = types["int"].dataModel;
    _enumerators = new UnmodifiableMapView<String, int>(types._enumerators);
  }

  /**
   * Data model of binary types.
   */
  DataModel get dataModel => _dataModel;

  /**
   * Returns the enumerators.
   */
  Map<String, int> get enumerators => _enumerators;

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
    return _char.array(length + 1).alloc(characters);
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
  Declarations declare(String source,
      {Map<String, String> environment, Map<String, FunctionType> functions, Map<String, BinaryType> variables}) {
    var declaration = new _Declarations(types);
    return declaration.declare(source, environment: environment, functions: functions, variables: variables);
  }

  /**
   * Reads the null-terminated string from memory.
   *
   * Parameters:
   *   [Reference] data
   *   Reference to the null-terminated string.
   */
  String readString(BinaryData data) {
    if (data == null) {
      throw new ArgumentError.notNull("data");
    }

    if (data.isNullPtr) {
      throw new NullPointerException("$data");
    }

    var type = data.type;
    if (type is ArrayType) {
      type = type.type;
    }

    if (type is! IntType) {
      throw new ArgumentError("Referenced type '$type' should be integer type");
    }

    var base = data.base;
    var offset = data.offset;
    var size = type.size;
    var characters = <int>[];
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
