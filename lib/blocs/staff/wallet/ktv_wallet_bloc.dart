import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/data/model/wallet_model.dart';
import 'ktv_wallet_event.dart';
import 'ktv_wallet_state.dart';

class KtvWalletBloc extends Bloc<KtvWalletEvent, KtvWalletState> {
  final ApiRepository apiRepository;

  WalletModel? currentWallet;
  List<WalletTransactionModel> currentTransactions = [];
  bool isLoading = false;

  KtvWalletBloc({required this.apiRepository}) : super(KtvWalletInitialState()) {
    on<KtvWalletStartedEvent>(_onStarted);
    on<KtvWalletRefreshEvent>(_onRefresh);
    on<KtvWalletAdvanceSubmitEvent>(_onAdvanceSubmit);
    on<KtvWalletDepositSubmitEvent>(_onDepositSubmit);
  }

  Future<void> _fetchWalletData(Emitter<KtvWalletState> emit) async {
    isLoading = true;
    emit(KtvWalletLoadingState());

    try {
      final results = await Future.wait([
        apiRepository.getWalletBalance(),
        apiRepository.getWalletTransactions(),
      ]);

      final walletRes = results[0];
      final txsRes = results[1];

      String? errorMsg;
      if (walletRes.status != 200 && walletRes.status != 1) {
        errorMsg = walletRes.message;
      }
      if (txsRes.status != 200 && txsRes.status != 1) {
        errorMsg = txsRes.message;
      }

      if (errorMsg != null) {
        emit(KtvWalletFailureState(errorMsg));
      } else {
        currentWallet = walletRes.data as WalletModel?;
        currentTransactions = (txsRes.data as List?)?.cast<WalletTransactionModel>() ?? [];

        emit(KtvWalletSuccessState(
          wallet: currentWallet ?? WalletModel(),
          transactions: currentTransactions,
        ));
      }
    } catch (e) {
      emit(KtvWalletFailureState(e.toString()));
    } finally {
      isLoading = false;
    }
  }

  FutureOr<void> _onStarted(KtvWalletStartedEvent event, Emitter<KtvWalletState> emit) async {
    await _fetchWalletData(emit);
  }

  FutureOr<void> _onRefresh(KtvWalletRefreshEvent event, Emitter<KtvWalletState> emit) async {
    await _fetchWalletData(emit);
  }

  FutureOr<void> _onAdvanceSubmit(KtvWalletAdvanceSubmitEvent event, Emitter<KtvWalletState> emit) async {
    emit(KtvWalletSubmitLoadingState());
    try {
      final res = await apiRepository.requestWalletAdvance(
        amount: event.amount,
        orderId: event.orderId,
        note: event.note,
        proofImages: event.proofImages,
      );

      if (res.status == 200 || res.status == 1) {
        emit(KtvWalletSubmitSuccessState(res.message ?? 'Yêu cầu ứng tiền thành công!'));
        // Refresh data to reflect the changes
        await _fetchWalletData(emit);
      } else {
        emit(KtvWalletSubmitFailureState(res.message ?? 'Yêu cầu ứng tiền thất bại!'));
      }
    } catch (e) {
      emit(KtvWalletSubmitFailureState(e.toString()));
    }
  }

  FutureOr<void> _onDepositSubmit(KtvWalletDepositSubmitEvent event, Emitter<KtvWalletState> emit) async {
    emit(KtvWalletSubmitLoadingState());
    try {
      final res = await apiRepository.requestWalletDeposit(
        amount: event.amount,
        note: event.note,
        proofImages: event.proofImages,
      );

      if (res.status == 200 || res.status == 1) {
        emit(KtvWalletSubmitSuccessState(res.message ?? 'Yêu cầu nộp tiền thành công!'));
        // Refresh data to reflect the changes
        await _fetchWalletData(emit);
      } else {
        emit(KtvWalletSubmitFailureState(res.message ?? 'Yêu cầu nộp tiền thất bại!'));
      }
    } catch (e) {
      emit(KtvWalletSubmitFailureState(e.toString()));
    }
  }
}
