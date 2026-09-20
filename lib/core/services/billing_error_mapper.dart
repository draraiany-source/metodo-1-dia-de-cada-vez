import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'premium_service.dart';

/// Mensagens amigáveis para erros de loja / RevenueCat.
class BillingErrorMapper {
  BillingErrorMapper._();

  static String toUserMessage(
    Object error, {
    String fallback =
        'Não foi possível concluir a compra agora. Tente de novo em instantes.',
  }) {
    if (error is PurchaseCancelledException) {
      return 'Compra cancelada. Nenhuma cobrança foi feita.';
    }
    if (error is BillingNotConfiguredException) return error.message;
    if (error is PlatformException) {
      try {
        final mapped = _fromPurchasesCode(
          PurchasesErrorHelper.getErrorCode(error),
        );
        if (mapped != null) return mapped;
      } catch (_) {}
      final raw = '${error.code} ${error.message ?? ''}'.toLowerCase();
      if (raw.contains('cancel')) {
        return 'Compra cancelada. Nenhuma cobrança foi feita.';
      }
      if (raw.contains('network') || raw.contains('offline')) {
        return 'Sem conexão com a internet. Conecte-se e tente novamente.';
      }
    }
    final raw = error.toString().toLowerCase();
    if (raw.contains('socket') ||
        raw.contains('network') ||
        raw.contains('failed host lookup')) {
      return 'Sem conexão com a internet. Conecte-se e tente novamente.';
    }
    if (raw.contains('timeout')) {
      return 'A loja demorou demais para responder. Tente novamente.';
    }
    return fallback;
  }

  static String restoreMessage({required bool foundPremium}) {
    return foundPremium
        ? 'Assinatura restaurada nesta conta.'
        : 'Nenhuma compra foi encontrada nesta loja para esta conta.';
  }

  static String? _fromPurchasesCode(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Compra cancelada. Nenhuma cobrança foi feita.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Esta conta da loja não pode comprar agora. No Android, use um testador autorizado da Play Console.';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'O pagamento não foi aprovado. No sandbox, tente outro método de teste.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Este plano ainda não está disponível nesta loja.';
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return 'Esta conta já tem este plano. Use Restaurar compras.';
      case PurchasesErrorCode.networkError:
        return 'Sem conexão com a internet. Conecte-se e tente novamente.';
      case PurchasesErrorCode.storeProblemError:
        return 'A loja está indisponível no momento. Tente novamente em instantes.';
      case PurchasesErrorCode.operationAlreadyInProgressError:
        return 'Já existe uma compra em andamento.';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'Esta compra já está ligada a outra conta.';
      case PurchasesErrorCode.invalidCredentialsError:
        return 'As chaves do RevenueCat deste build estão incorretas.';
      case PurchasesErrorCode.invalidAppUserIdError:
        return 'Não foi possível identificar sua conta na loja. Entre novamente.';
      case PurchasesErrorCode.configurationError:
        return 'A oferta deste plano ainda não está configurada no RevenueCat.';
      case PurchasesErrorCode.unexpectedBackendResponseError:
        return 'O RevenueCat não respondeu como esperado. Tente novamente.';
      default:
        return null;
    }
  }
}
