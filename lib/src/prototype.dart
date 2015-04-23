part of binary_types;

class Prototype {
  final String alias;

  final String convention;

  final String filename;

  final String library;

  final List<String> parameters;

  final FunctionType type;

  Prototype({this.alias, this.convention, this.filename, this.library, this.parameters, this.type}) {
    if (filename == null) {
      throw new ArgumentError.notNull("filename");
    }

    if (parameters == null) {
      throw new ArgumentError.notNull("parameters");
    }

    if (type == null) {
      throw new ArgumentError.notNull("type");
    }
  }
}
