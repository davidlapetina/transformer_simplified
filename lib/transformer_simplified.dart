library transformer_simplified;

import 'package:transformer_simplified/src/mapping.dart';

class TransformerSimplified {
  static final TransformerSimplified _instance = TransformerSimplified._();

  final Map<String, MappingRegistry> mappingByDescriptionFileName = {};

  TransformerSimplified._();

  /// The instance is static.
  static TransformerSimplified get() {
    return _instance;
  }

  /// Registers a mapping definition associated with an alias
  /// The alias enable having different mappings in different files for clarity
  /// NB: all custom transformers must be registered before loading any mapping using them
  void load(String alias, dynamic jsonMappingData) {
    mappingByDescriptionFileName[alias] =
        MappingRegistry.build(jsonMappingData);
  }

  /// Execute a mapping of the [input] based on the mapping [id] defined in the [alias] of the mapping definition.
  dynamic execute(dynamic input, String id, String alias) {
    MappingRegistry? registry = mappingByDescriptionFileName[alias];
    if (registry == null) {
      throw Exception('No mapping defined for $alias');
    }
    return registry.execute(id, input);
  }
}
