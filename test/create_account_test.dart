//import 'package:flutter_test/flutter_test.dart';
import 'package:finddelivery/validators.dart';
import 'package:test/test.dart';

void main() {
  group('Username validity test:', () {
    test('empty name input return error message', () {
      var result = ValidateEntries().validateUsername('');
      expect(result, 'Enter valid Name');
    });

    test('name length less that 3 letters error message', () {
      var result = ValidateEntries().validateUsername('La');
      expect(result, 'Enter valid Name');
    });

    test('valid username return null', () {
      var result = ValidateEntries().validateUsername('Hans Thisanke');
      expect(result, 'null');
    });
  });

  group('Age validity test:', () {
    test('Unacceptable age gives error message', () {
      var result = ValidateEntries().validateUserAge('10');
      expect(result, 'Enter valid Age');
    });

    test('Acceptable age return null', () {
      var result = ValidateEntries().validateUserAge('30');
      expect(result, 'null');
    });
  });

  group('Contact number validity test:', () {
    test('Contain non numerics gives error message', () {
      var result = ValidateEntries().validateUserContact('07^3789891');
      expect(result, 'Enter valid Contact Number');
    });

    test('A 10 digit number start with 07 return null', () {
      var result = ValidateEntries().validateUserContact('0712345781');
      expect(result, 'null');
    });
  });

  group('City name validity test:', () {
    test('Unexpected length for city name gives error message', () {
      var result = ValidateEntries().validateCityName('ga');
      expect(result, 'Enter a valid City Name');
    });

    test('Not filling city name gives error message', () {
      var result = ValidateEntries().validateCityName('ga');
      expect(result, 'Enter a valid City Name');
    });

    test('Acceptable city name return null', () {
      var result = ValidateEntries().validateCityName('Galle');
      expect(result, 'null');
    });
  });
}
