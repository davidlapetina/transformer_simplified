import 'package:transformer_simplified/transformers.dart';

class ToUpperCase implements Transformer<String, String> {
  @override
  String? transform(String? input) {
    if (input == null || input.isEmpty) {
      return input;
    }
    return input.toUpperCase();
  }
}

class ToLowerCase implements Transformer<String, String> {
  @override
  String? transform(String? input) {
    if (input == null || input.isEmpty) {
      return input;
    }
    return input.toLowerCase();
  }
}

class ToInteger implements Transformer<String, int> {
  @override
  int? transform(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    return int.parse(input);
  }
}

class ToDouble implements Transformer<String, double> {
  @override
  double? transform(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    return double.parse(input);
  }
}

class ToBool implements Transformer<String, bool> {
  @override
  bool? transform(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    return input.toLowerCase() == 'true';
  }
}