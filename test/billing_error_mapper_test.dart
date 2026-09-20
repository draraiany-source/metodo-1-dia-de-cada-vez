import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/services/billing_error_mapper.dart';
import 'package:metodo_1_dia/core/services/premium_service.dart';

void main() {
  test('compra cancelada não assusta a usuária', () {
    expect(
      BillingErrorMapper.toUserMessage(const PurchaseCancelledException()),
      contains('Nenhuma cobrança'),
    );
  });

  test('loja não configurada', () {
    expect(
      BillingErrorMapper.toUserMessage(const BillingNotConfiguredException()),
      isNot(contains('Exception')),
    );
  });

  test('restore sem compra', () {
    expect(
      BillingErrorMapper.restoreMessage(foundPremium: false),
      contains('Nenhuma compra'),
    );
    expect(
      BillingErrorMapper.restoreMessage(foundPremium: true),
      contains('restaurada'),
    );
  });

  test('queda de rede', () {
    expect(
      BillingErrorMapper.toUserMessage(Exception('SocketException: failed host lookup')),
      contains('internet'),
    );
  });
}
