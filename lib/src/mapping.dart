import 'package:transformer_simplified/transformers.dart';

class MappingRegistry {

  final Map<String, Mapping> _byId = {};

  MappingRegistry._();

  Mapping? get(String id) {
    return _byId[id];
  }

  dynamic execute(String id, dynamic jsonData) {
    Mapping? mapping = _byId[id];
    if (mapping == null) {
      return jsonData;
    }
    return mapping.execute(jsonData);
  }

  static MappingRegistry build(dynamic jsonData) {
    MappingRegistry registry = MappingRegistry._();

    for (dynamic item in jsonData) {
      //MainMapping here
      MainMapping mapping = MainMapping.build(item, registry);
      registry._byId[mapping.id] = mapping;
    }

    return registry;
  }
}

abstract class Mapping {
  dynamic execute(dynamic input);

  String getOutputPath();
}

class MainMapping extends Mapping {
  String id;
  String? comment;
  final Map<String, Mapping> mappingByInput;

  MainMapping(this.id, this.comment, this.mappingByInput);

  @override
  String getOutputPath() {
    throw Exception('Should not be called');
  }

  @override
  dynamic execute(dynamic input) {
    //We always expect a Map<String, dynamic> as input and we give back same
    Map<String, dynamic> inputMap = input;
    Map<String, dynamic> outputMap = {};
    for (String inputPath in inputMap.keys) {
      Mapping? mapping = mappingByInput[inputPath];
      if (mapping == null) {
        continue;
      }
      outputMap[mapping.getOutputPath()] = mapping.execute(inputMap[inputPath]);
    }

    return outputMap;
  }

  static MainMapping build(dynamic jsonData, MappingRegistry registry) {
    String? id = jsonData['id'];
    if (id == null || id.isEmpty) {
      throw Exception('Field id cannot be null nor empty');
    }
    String? comment = jsonData['comment'];
    List<dynamic>? mappings = jsonData['mappings'];
    if (mappings == null || mappings.isEmpty) {
      return MainMapping(id, comment, {});
    }
    Map<String, Mapping> mappingByInput = {};
    for (dynamic mappingAsJson in mappings) {
      String? type = mappingAsJson['type'];
      switch (type) {
        case 'complex':
          ComplexMapping mapping = ComplexMapping.build(mappingAsJson, registry);
          mappingByInput[mapping.inputPath] = mapping;
          break;
        default:
          SingleMapping mapping = SingleMapping.build(mappingAsJson, registry);
          mappingByInput[mapping.inputPath] = mapping;
      }
    }

    return MainMapping(id, comment, mappingByInput);
  }
}

class ComplexMapping implements Mapping {
  final MappingRegistry registry;
  final String inputPath;
  final String outputPath;
  final Transformer? transformer;
  final String? subMappingId;
  final bool list;

  ComplexMapping(this.inputPath, this.outputPath, this.transformer,
      this.subMappingId, this.list, this.registry);

  @override
  String getOutputPath() {
    return outputPath;
  }

  @override
  dynamic execute(dynamic input) {
    if (subMappingId != null) {
      Mapping? mapping = registry.get(subMappingId!);
      if (mapping == null) {
        throw Exception('Mapping $subMappingId does not exist.');
      }
      if (list) {
        List<dynamic> result = [];
        for (dynamic item in input) {
          result.add(mapping.execute(item));
        }
        return result;
      }
      return mapping.execute(input);
    }
    if (transformer != null) {
      if (list) {
        List<dynamic> result = [];
        for (dynamic item in input) {
          result.add(transformer!.transform(item));
        }
        return result;
      }
      return transformer!.transform(input);
    }
    return input;
  }

  static ComplexMapping build(dynamic mappingAsJson, MappingRegistry registry) {
    dynamic input = mappingAsJson['input'];
    if (input == null) {
      throw Exception('input cannot be null');
    }
    String? inputPath = input['path'];
    if (inputPath == null) {
      throw Exception('input path cannot be null');
    }

    dynamic output = mappingAsJson['output'];
    if (output == null) {
      throw Exception('output cannot be null');
    }
    String? outputPath = output['path'];
    if (outputPath == null) {
      throw Exception('input path cannot be null');
    }

    String? transformerAsString = mappingAsJson['transformer'];
    if (transformerAsString == null) {
      throw Exception('You need a mapping or a transformer for lists');
    }

    String? subMappingId;
    Transformer? transformer;
    if (transformerAsString.startsWith(TransformerRegistry.mapping)) {
      subMappingId =
          transformerAsString.substring(TransformerRegistry.mapping.length);
    } else {
      transformer = MappingUtils.getTransformer(transformerAsString);
    }

    if (subMappingId == null && transformer == null) {
      throw Exception('You need a mapping or a transformer for lists');
    }

    bool? list = mappingAsJson['list'];

    return ComplexMapping(
        inputPath, outputPath, transformer, subMappingId, list ?? false, registry);
  }
}

class SingleMapping implements Mapping {
  final MappingRegistry registry;
  final String inputPath;
  final String outputPath;

  final Transformer? transformer;
  final String? subMappingId;
  final bool list;

  SingleMapping(this.inputPath, this.outputPath, this.transformer,
      this.subMappingId, this.list, this.registry);

  @override
  String getOutputPath() {
    return outputPath;
  }

  @override
  dynamic execute(dynamic input) {
    //Input here should be a a single value

    //We can have submapping for structure inside structure
    if (subMappingId != null) {
      Mapping? subMapping = registry.get(subMappingId!);
      if (subMapping == null) {
        throw Exception('Mapping $subMappingId Should not be null');
      }
      if (list) {
        List<dynamic> result = [];
        for (dynamic item in input) {
          result.add(subMapping.execute(item));
        }
        return result;
      }
      return subMapping.execute(input);
    } else if (transformer != null) {
      if (list) {
        List<dynamic> result = [];
        for (dynamic item in input) {
          result.add(transformer!.transform(item));
        }
        return result;
      }
      return transformer!.transform(input);
    }

    return input;
  }

  static SingleMapping build(dynamic mappingAsJson, MappingRegistry registry) {
    dynamic input = mappingAsJson['input'];
    if (input == null) {
      throw Exception('input cannot be null');
    }
    String? inputPath = input['path'];
    if (inputPath == null) {
      throw Exception('input path cannot be null');
    }
    dynamic output = mappingAsJson['output'];
    if (output == null) {
      throw Exception('output cannot be null');
    }
    String? outputPath = output['path'];
    if (outputPath == null) {
      throw Exception('input path cannot be null');
    }

    String? transformerAsString = mappingAsJson['transformer'];
    Transformer? transformer;
    String? mappingId;
    if (transformerAsString != null) {
      if (transformerAsString.startsWith(TransformerRegistry.mapping)) {
        mappingId =
            transformerAsString.substring(TransformerRegistry.mapping.length);
      } else {
        transformer = MappingUtils.getTransformer(transformerAsString);
      }
    }

    bool? list = mappingAsJson['list'];

    return SingleMapping(
        inputPath, outputPath, transformer, mappingId, list ?? false, registry);
  }
}

class MappingUtils {
  static String getKey(String input, String output) {
    return '$input>$output';
  }

  static Transformer? getTransformer(String? transformer) {
    if (transformer == null) {
      return null;
    }
    if (transformer.startsWith(TransformerRegistry.builtIn)) {
      return TransformerRegistry.registry.getBuiltIn(
          transformer.substring(TransformerRegistry.builtIn.length));
    }
    if (transformer.startsWith(TransformerRegistry.custom)) {
      return TransformerRegistry.registry
          .getCustom(transformer.substring(TransformerRegistry.custom.length));
    }
    //TODO another mapping !
    return null;
  }
}

/*

class ListMapping implements Mapping {
  String inputPath;
  String outputPath;
  Transformer? transformer;
  String? subMappingId;

  ListMapping(this.inputPath, this.outputPath, this.transformer,
      this.subMappingId);

  @override
  List<dynamic> execute(dynamic input) {
    if (subMappingId != null) {
      Mapping? mapping = MappingRegistry.registry.get(subMappingId!);
      if (mapping == null) {
        throw Exception('Mapping $subMappingId does not exist.');
      }
      List<dynamic> result = [];
      for (dynamic item in input) {
        result.add(mapping.execute(item));
      }
      return result;
    }

    //Here transformer should not be null
    List<dynamic> result = [];
    for (dynamic item in input) {
      result.add(transformer!.transform(item));
    }
    return result;
  }

  static ListMapping build(dynamic mappingAsJson) {
    dynamic? input = mappingAsJson['input'];
    if (input == null) {
      throw Exception('input cannot be null');
    }
    String? inputPath = input['path'];
    if (inputPath == null) {
      throw Exception('input path cannot be null');
    }

    dynamic? output = mappingAsJson['output'];
    if (output == null) {
      throw Exception('output cannot be null');
    }
    String? outputPath = output['path'];
    if (outputPath == null) {
      throw Exception('input path cannot be null');
    }

    String? transformerAsString = mappingAsJson['transformer'];
    if (transformerAsString == null) {
      throw Exception('You need a mapping or a transformer for lists');
    }

    String? subMappingId;
    Transformer? transformer;
    if (transformerAsString.startsWith(TransformerRegistry.mapping)) {
      subMappingId =
          transformerAsString.substring(TransformerRegistry.mapping.length);
    } else {
      transformer = MappingUtils.getTransformer(transformerAsString);
    }

    if (subMappingId == null && transformer == null) {
      throw Exception('You need a mapping or a transformer for lists');
    }
    return ListMapping(inputPath, outputPath, transformer, subMappingId);
  }
}*/
