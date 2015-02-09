part of binary_types;

class _Metadata {
  static final _Metadata empty = new _Metadata(const <Metadata>[]);

  Map<String, List<List<dynamic>>> _attributes;

  _Metadata(List<Metadata> metadataList) {
    if (metadataList == null) {
      throw new ArgumentError.notNull("metadataList");
    }

    _attributes = _joinMetadata(metadataList);
  }

  int get aligned {
    var values = getLastValues(_attributes, "aligned");
    if (values == null) {
      return null;
    }

    if (values.isEmpty) {
      return 16;
    }

    if (values.length != 1) {
      _wrongNumberOfArguments("aligned");
    }

    var parameter = values.first;
    if (parameter is! int) {
      _wrongArgumentType("aligned", "integer");
    }

    return parameter;
  }

  bool get packed {
    var values = getLastValues(_attributes, "packed");
    if (values == null) {
      return false;
    }

    if (!values.isEmpty) {
      _wrongNumberOfArguments("packed");
    }

    return true;
  }

  List<String> getLastValues(Map<String, List<List<String>>> attributes, String name) {
    var values = attributes[name];
    if (values == null) {
      return null;
    }

    return values.last;
  }

  Map<String, List<List<dynamic>>> _getAttributes(Metadata metadata, Map<String, List<List<String>>> attributes) {
    if (attributes == null) {
      attributes = <String, List<List<dynamic>>>{};
    }

    if (metadata == null) {
      return attributes;
    }

    for (var attributeList in metadata.attributeList) {
      for (var value in attributeList.attributes) {
        var name = value.name;
        var list = attributes[name];
        if (list == null) {
          list = <List<dynamic>>[];
          attributes[name] = list;
        }

        list.add(value.parameters);
      }
    }

    return attributes;
  }

  Map<String, List<List<dynamic>>> _joinMetadata(List<Metadata> metadataList) {
    Map<String, List<List<dynamic>>> result;
    for (var metadata in metadataList) {
      result = _getAttributes(metadata, result);
    }

    return result;
  }

  void _wrongArgumentType(String name, String type) {
    throw new StateError("Attribute '$name' argument not a $type");
  }

  void _wrongNumberOfArguments(String name) {
    throw new StateError("Wrong number of arguments specified for '$name' attribute");
  }
}
