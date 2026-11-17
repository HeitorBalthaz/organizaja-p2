import 'package:flutter_test/flutter_test.dart';
import 'package:organizaja/utils/validators.dart';

void main() {
  group('Validação de formulários', () {
    test('rejeita e-mail inválido', () {
      expect(Validators.email('sem-arroba'), isNotNull);
      expect(Validators.email('aluno@faculdade.com'), isNull);
    });

    test('exige senha de oito caracteres', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });

    test('exige título com tamanho adequado', () {
      expect(Validators.taskTitle('ab'), isNotNull);
      expect(Validators.taskTitle('Estudar Flutter'), isNull);
    });
  });
}
