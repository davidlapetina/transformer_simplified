library transformer_simplified;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:transformer_simplified/src/mapping.dart';

class TransformerSimplified {

  static final TransformerSimplified _instance = TransformerSimplified._();

  final Map<String, MappingRegistry> mappingByDescriptionFileName = {};

  TransformerSimplified._();

  static TransformerSimplified get() {
    return _instance;
  }

  /// Registers a mapping definition associated with an alias
  /// The alias allows use to have different mappings in different files for clarity
  void load(String alias, dynamic jsonMappingData)  {
    mappingByDescriptionFileName[alias] =
        MappingRegistry.build(jsonMappingData);
  }

  dynamic execute(dynamic input, String id, String alias) {
    MappingRegistry? registry =
        mappingByDescriptionFileName[alias];
    if (registry == null) {
      throw Exception('No mapping defined for $alias');
    }
    return registry.execute(id, input);
  }
}
