import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_crossplatform_app/features/example/domain/example_usecase.dart';

void main() {
  group('ExampleUseCase', () {
    late ExampleUseCase useCase;

    setUp(() {
      useCase = ExampleUseCase();
    });

    test('execute returns non-empty string', () async {
      final result = await useCase.execute();
      expect(result, isNotEmpty);
    });
  });
}
