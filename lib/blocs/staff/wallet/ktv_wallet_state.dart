import 'package:socbay/data/model/wallet_model.dart';

abstract class KtvWalletState {
  const KtvWalletState();
}

class KtvWalletInitialState extends KtvWalletState {}

class KtvWalletLoadingState extends KtvWalletState {}

class KtvWalletSuccessState extends KtvWalletState {
  final WalletModel wallet;
  final List<WalletTransactionModel> transactions;

  const KtvWalletSuccessState({
    required this.wallet,
    required this.transactions,
  });
}

class KtvWalletFailureState extends KtvWalletState {
  final String message;
  const KtvWalletFailureState(this.message);
}

class KtvWalletSubmitLoadingState extends KtvWalletState {}

class KtvWalletSubmitSuccessState extends KtvWalletState {
  final String message;
  const KtvWalletSubmitSuccessState(this.message);
}

class KtvWalletSubmitFailureState extends KtvWalletState {
  final String message;
  const KtvWalletSubmitFailureState(this.message);
}
