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
   * Returns the macro definitions.
   */
  Map<String, MacroDefinition> get definitions => new UnmodifiableMapView<String, MacroDefinition>(types._definitions);

  /**
   * Returns the enumerators.
   */
  Map<String, int> get enumerators => _enumerators;


  /**
   * Returns the function prototypes.
   */
  Map<String, Prototype> get prototypes => types._prototypes;

  /**
   * Adds the binary header to the list of available headers.
   *
   * Parameters:
   *   [String] name
   *   Header name.
   *
   *   [String] text
   *   Header text.
   */
  void addHeader(String name, String text) {
    if (name == null) {
      throw new ArgumentError.notNull("name");
    }

    if (name.isEmpty) {
      throw new ArgumentError("Header name cannot be empty");
    }

    if (text == null) {
      throw new ArgumentError.notNull("text");
    }

    var headers = types._headers;
    var found = headers[name];
    if (found == null) {
      headers[name] = text;
    } else if (text != found) {
      throw new ArgumentError("Header text '$name' does not match text of an existing header");
    }
  }

  /**
   * Adds the binary header to the list of available headers.
   *
   * Parameters:
   *   [String] name
   *   Header name.
   *
   *   [String] text
   *   Header text.
   */
  void addHeaders(Map<String, String> headers) {
    if (headers == null) {
      throw new ArgumentError.notNull("headers");
    }

    for (var name in headers.keys) {
      var text = headers[name];
      addHeader(name, text);
    }
  }

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
   *   [String] filename
   *   Name of the header file.
   *
   *   [Map]<[String], [String]> environment
   *   Environment values for preprocessing declarations.
   */
  Declarations declare(String filename, {Map<String, String> environment}) {
    var declaration = new _Declarations(types);
    return declaration.declare(filename, environment: environment);
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
