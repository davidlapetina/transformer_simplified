# Example of how to use a mapping

# Mapping
```json
[
  {
    "id": "formUserToJSonUser",
    "mappings": [
      {
        "type": "single",
        "input": {
          "path": "key1"
        },
        "output": {
          "path": "name1"
        },
        "transformer": "builtin://toUppercase"
      },
      {
        "type": "complex",
        "list": true,
        "input": {
          "path": "key2"
        },
        "output": {
          "path": "addresses",
          "comment": "the type of the list is either the one introspected from the first root type or a Map<String, dynamic> if the output is a map/list with no predefined type"
        },
        "transformer": "mapping://map2Address"
      }
    ]
  },
  {
    "id": "map2Address",
    "mappings": [
      {
        "type": "single",
        "input": {
          "path": "street"
        },
        "output": {
          "path": "street"
        },
        "transformer": "builtin://toLowercase"
      },
      {
        "type": "single",
        "input": {
          "path": "zipcode"
        },
        "output": {
          "path": "ZipCode"
        },
        "transformer": "builtin://toInteger"
      },
      {
        "type": "single",
        "input": {
          "path": "city"
        },
        "output": {
          "path": "city"
        }
      },
      {
        "type": "complex",
        "input": {
          "path": "alias"
        },
        "output": {
          "path": "alias"
        },
        "transformer": "mapping://mappingAlias"
      }
    ]
  },
  {
    "id": "mappingAlias",
    "mappings": [
      {
        "type": "single",
        "input": {
          "path": "otherZipCode"
        },
        "output": {
          "path": "newZipCode"
        },
        "transformer": "custom://revert"
      }
    ]
  }
]

```
# Dart code showing how to use the mapping
```dart
 dynamic jsonData =
        json.decode(await File('./example/mapping.json').readAsString());
    TransformerRegistry.get().setCustom('revert', Revert());

    TransformerSimplified.get().load('mapping', jsonData);

    String key1LowerCase = 'david lower case';
    String streetUpperCase = 'STREET IN UPPERCASE';
    String zipCodeAsString = '10000';
    String otherZipCode = 'other cedex in lowercase';
    Map<String, dynamic> input = {
      'key1': key1LowerCase,
      'key2': [
        {
          'street': streetUpperCase,
          'zipcode': zipCodeAsString,
          'city': 'myCity',
          'alias': {'otherZipCode': 'cedex in lowercase'}
        },
        {
          'street': 'STREET2 IN UPPERCASE2',
          'zipcode': '30000',
          'city': 'yourCity',
          'alias': {'otherZipCode': otherZipCode}
        }
      ],
    };

    dynamic output = TransformerSimplified.get()
        .execute(input, 'formUserToJSonUser', 'mapping');
```
