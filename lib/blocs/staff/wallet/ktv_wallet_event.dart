import 'dart:io';

abstract class KtvWalletEvent {
  const KtvWalletEvent();
}

class KtvWalletStartedEvent extends KtvWalletEvent {}

class KtvWalletRefreshEvent extends KtvWalletEvent {}

class KtvWalletAdvanceSubmitEvent extends KtvWalletEvent {
  final double amount;
  final int? orderId;
  final String? note;
  final List<File>? proofImages;

  const KtvWalletAdvanceSubmitEvent({
    required this.amount,
    this.orderId,
    this.note,
    this.proofImages,
  });
}

class KtvWalletDepositSubmitEvent extends KtvWalletEvent {
  final double amount;
  final String? note;
  final List<File>? proofImages;

  const KtvWalletDepositSubmitEvent({
    required this.amount,
    this.note,
    this.proofImages,
  });
}
