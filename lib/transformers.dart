import 'package:transformer_simplified/src/builtin_transformers.dart';

/// Class to extend in order to define custom transformers
abstract class Transformer<Input, Output> {
  Output? transform(Input? input);
}

/// Registry for the transformers.
/// It contains a few builtin transformers
class TransformerRegistry {
  static const String builtIn = "builtin://";
  static const String mapping = "mapping://";
  static const String custom = "custom://";

  static final TransformerRegistry _registry = TransformerRegistry._();

  final Map<String, Transformer> _builtinRegistry = {};
  final Map<String, Transformer> _customRegistry = {};

  TransformerRegistry._() {
    _builtinRegistry[BuiltInTransformer.toUppercase] = ToUpperCase();
    _builtinRegistry[BuiltInTransformer.toLowercase] = ToLowerCase();
    _builtinRegistry[BuiltInTransformer.toInteger] = ToInteger();
    _builtinRegistry[BuiltInTransformer.toDouble] = ToDouble();
    _builtinRegistry[BuiltInTransformer.toBool] = ToBool();
  }

  static TransformerRegistry get() {
    return _registry;
  }

  Transformer? getBuiltIn(String key) {
    return _builtinRegistry[key];
  }

  void setCustom(String key, Transformer transformer) {
    _customRegistry[key] = transformer;
  }

  Transformer? getCustom(String key) {
    return _customRegistry[key];
  }
}

/// List of the default builtin transformers
class BuiltInTransformer {
  static const String toUppercase = 'toUppercase';
  static const String toLowercase = 'toLowercase';
  static const String toInteger = 'toInteger';
  static const String toDouble = 'toDouble';
  static const String toBool = 'toBool';
}
