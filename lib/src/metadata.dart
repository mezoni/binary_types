part of binary_types;

class _Metadata {
  static final _Metadata empty = new _Metadata(const <Metadata>[]);

  Map<String, List<List<String>>> _attributes;

  _Metadata(List<Metadata> metadataList) {
    if (metadataList == null) {
      throw new ArgumentError.notNull("metadataList");
    }

    _attributes = _joinMetadata(metadataList);
  }

  int get aligned {
    var values = _getLastValues(_attributes, "aligned");
    if (values == null) {
      return null;
    }

    if (values.isEmpty) {
      return 16;
    }

    var parameter = values.first.trim();
    var radix = 10;
    if (parameter.startsWith("0x")) {
      radix = 16;
    } else if (parameter.startsWith("0")) {
      radix = 8;
    }

    int value;
    try {
      value = int.parse(values.first, radix: radix);
      _Utils.checkPowerOfTwo(value, "aligned");
    } catch (e) {
      throw new StateError("Wrong parameter value '$parameter' of the attribute 'aligned'");
    }

    return value;
  }

  bool get packed {
    var values = _getLastValues(_attributes, "packed");
    if (values == null) {
      return false;
    }

    return true;
  }

  Map<String, List<List<String>>> _getAttributes(Metadata metadata, Map<String, List<List<String>>> attributes) {
    if (attributes == null) {
      attributes = <String, List<List<String>>>{};
    }

    if (metadata == null) {
      return attributes;
    }

    for (var attributeList in metadata.attributeList) {
      for (var value in attributeList.attributes) {
        var name = value.name;
        var list = attributes[name];
        if (list == null) {
          list = <List<String>>[];
          attributes[name] = list;
        }

        list.add(value.parameters);
      }
    }

    return attributes;
  }

  List<String> _getLastValues(Map<String, List<List<String>>> attributes, String name) {
    var values = attributes[name];
    if (values == null) {
      return null;
    }

    return values.last;
  }

  Map<String, List<List<String>>> _joinMetadata(List<Metadata> metadataList) {
    Map<String, List<List<String>>> result;
    for (var metadata in metadataList) {
      result = _getAttributes(metadata, result);
    }

    return result;
  }
}
