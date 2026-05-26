import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/user_info/gift/gift_screen_event.dart';
import 'package:socbay/blocs/user_info/gift/gift_screen_state.dart';
import 'package:socbay/data/model/gift_response.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

class GiftScreenBloc extends Bloc<GiftScreenEvent, GiftScreenState> {
  GiftScreenBloc({required this.apiRepository})
    : super(GiftScreenInitialState()) {
    on<GiftScreenStartedEvent>(_mapStartedEventToState);
    on<GiftScreenTabPressEvent>(_mapTabPressEventToState);
  }

  final ApiRepository apiRepository;
  List<GiftResponse> giftList = [];
  List<GiftResponse> giftReceiveList = [];
  bool isLoading = false;

  FutureOr<void> _mapStartedEventToState(
    GiftScreenStartedEvent event,
    Emitter<GiftScreenState> emit,
  ) async {
    isLoading = true;
    emit(GiftScreenInitialState());
    final resGift = await apiRepository.getGiftList();
    if (resGift.status == HttpStatus.ok && resGift.data != null) {
      giftList = resGift.data!;
    }
    final resGiftReceive = await apiRepository.getGiftList(isReceive: true);
    if (resGiftReceive.status == HttpStatus.ok && resGiftReceive.data != null) {
      giftReceiveList = resGiftReceive.data!;
    }
    isLoading = false;
    emit(GiftScreenInitialState());
  }

  FutureOr<void> _mapTabPressEventToState(
    GiftScreenTabPressEvent event,
    Emitter<GiftScreenState> emit,
  ) {
    emit(GiftScreenChangeTabState(event.index));
  }
}
