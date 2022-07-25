import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:transformer_simplified/transformer_simplified.dart';
import 'package:transformer_simplified/transformers.dart';

void main() {
  test('test writers & readers', () async {
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
    expect(key1LowerCase.toUpperCase(), output['name1']);
    expect(streetUpperCase.toLowerCase(),
        output['addresses'].elementAt(0)['street']);
    expect('esacrewol ni xedec rehto',
        output['addresses'].elementAt(1)['alias']['newZipCode']);
    print(output);
  });
}

class Revert extends Transformer<String, String> {
  @override
  String? transform(String? input) {
    if (input == null) {
      return null;
    }
    //Except a string
    String result = '';
    for (int i = input.length - 1; i >= 0; i--) {
      result += input.substring(i, i + 1);
    }
    return result;
  }
}
