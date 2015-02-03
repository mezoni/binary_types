part of binary_types;

class _Metadata {
  static int getAttributeAligned(Map<String, List<List<String>>> attributes, int previousValue) {
    var values = _getLastValues(attributes, "aligned");
    if (values == null) {
      return previousValue;
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

  static bool getAttributePacked(Map<String, List<List<String>>> attributes, bool previousValue) {
    var values = _getLastValues(attributes, "packed");
    if (values == null) {
      return previousValue;
    }

    return true;
  }

  static Map<String, List<List<String>>> getAttributes(Metadata metadata, Map<String, List<List<String>>> map) {
    if (map == null) {
      map = <String, List<List<String>>>{};
    }

    if (metadata == null) {
      return map;
    }

    for (var attributeList in metadata.attributeList) {
      for (var value in attributeList.attributes) {
        var name = value.name;
        var list = map[name];
        if (list == null) {
          list = <List<String>>[];
          map[name] = list;
        }

        list.add(value.parameters);
      }
    }

    return map;
  }

  static List<String> _getLastValues(Map<String, List<List<String>>> attributes, String name) {
    var values = attributes[name];
    if (values == null) {
      return null;
    }

    return values.last;
  }
}
