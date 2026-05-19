import 'package:srik_cli/prompts/validators.dart';
import 'package:srik_cli/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
  group('StringUtils', () {
    test('toSnakeCase handles various inputs', () {
      expect(StringUtils.toSnakeCase('my_app'), 'my_app');
      expect(StringUtils.toSnakeCase('MyApp'), 'my_app');
      expect(StringUtils.toSnakeCase('my-app'), 'my_app');
      expect(StringUtils.toSnakeCase('my app'), 'my_app');
      expect(StringUtils.toSnakeCase('myApp'), 'my_app');
    });

    test('toPascalCase', () {
      expect(StringUtils.toPascalCase('my_app'), 'MyApp');
      expect(StringUtils.toPascalCase('my-app'), 'MyApp');
      expect(StringUtils.toPascalCase('my_awesome_app'), 'MyAwesomeApp');
    });

    test('toCamelCase', () {
      expect(StringUtils.toCamelCase('my_app'), 'myApp');
      expect(StringUtils.toCamelCase('my_awesome_app'), 'myAwesomeApp');
    });

    test('toTitleCase', () {
      expect(StringUtils.toTitleCase('my_app'), 'My App');
      expect(StringUtils.toTitleCase('my_awesome_app'), 'My Awesome App');
    });

    test('isValidPackageName accepts valid', () {
      expect(StringUtils.isValidPackageName('my_app'), isTrue);
      expect(StringUtils.isValidPackageName('app123'), isTrue);
      expect(StringUtils.isValidPackageName('my_app_v2'), isTrue);
    });

    test('isValidPackageName rejects invalid', () {
      expect(StringUtils.isValidPackageName(''), isFalse);
      expect(StringUtils.isValidPackageName('MyApp'), isFalse); // uppercase
      expect(StringUtils.isValidPackageName('1app'), isFalse); // starts digit
      expect(StringUtils.isValidPackageName('my-app'), isFalse); // hyphen
      expect(StringUtils.isValidPackageName('class'), isFalse); // reserved
    });
  });

  group('Validators', () {
    test('projectName', () {
      expect(Validators.projectName('my_app'), isNull);
      expect(Validators.projectName(''), isNotNull);
      expect(Validators.projectName('MyApp'), isNotNull);
    });

    test('hexColor', () {
      expect(Validators.hexColor('#6200EE'), isNull);
      expect(Validators.hexColor('#ABCDEF'), isNull);
      expect(Validators.hexColor('#abcdef'), isNull);
      expect(Validators.hexColor('#FF6200EE'), isNull); // 8-digit ARGB
      expect(Validators.hexColor('6200EE'), isNotNull); // no #
      expect(Validators.hexColor('#GGGGGG'), isNotNull); // invalid hex
      expect(Validators.hexColor(''), isNotNull);
    });

    test('organization', () {
      expect(Validators.organization('com.example'), isNull);
      expect(Validators.organization('com.acme.app'), isNull);
      expect(Validators.organization('Example'), isNotNull); // uppercase
      expect(Validators.organization('com'), isNotNull); // no dot
      expect(Validators.organization(''), isNotNull);
    });
  });
}
