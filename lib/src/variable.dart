part of binary_types;

class Variable {
  final String filename;

  final String name;

  final BinaryType type;

  Variable({this.filename, this.name, this.type}) {
    if (filename == null) {
      throw new ArgumentError.notNull("filename");
    }

    if (name == null) {
      throw new ArgumentError.notNull("name");
    }

    if (type == null) {
      throw new ArgumentError.notNull("type");
    }
  }
}
