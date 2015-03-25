part of binary_types;

class NullPointerException implements Exception {
  final String message;

  NullPointerException([this.message]);

  String toSrting() {
    if (message != null) {
      return message;
    }

    return "";
  }
}
