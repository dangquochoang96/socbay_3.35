import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/user_info/notification/notification_screen_state.dart';
import 'package:socbay/data/model/notification_response.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

import 'notification_screen_event.dart';

class NotificationScreenBloc
    extends Bloc<NotificationScreenEvent, NotificationScreenState> {
  NotificationScreenBloc({required this.apiRepository})
      : super(NotificationScreenInitialState()) {
    on<NotificationScreenStartedEvent>(_mapStartedEventToState);
    on<NotificationScreenLoadMoreEvent>(_mapLoadMoreEventToState);
  }

  final ApiRepository apiRepository;
  List<NotificationResponse> notifications = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMore = true;

  FutureOr<void> _mapStartedEventToState(
    NotificationScreenStartedEvent event,
    Emitter<NotificationScreenState> emit,
  ) async {
    currentPage = 1;
    hasMore = true;
    isLoading = true;
    emit(NotificationScreenInitialState());
    final res = await apiRepository.getNotifications(page: 1);
    if ((res.status == 1 || res.status == 200) && res.data != null) {
      notifications = res.data!;
      if (res.data!.isEmpty || res.data!.length < 20) {
        hasMore = false;
      }
    } else {
      hasMore = false;
    }
    isLoading = false;
    emit(NotificationScreenInitialState());
  }

  FutureOr<void> _mapLoadMoreEventToState(
    NotificationScreenLoadMoreEvent event,
    Emitter<NotificationScreenState> emit,
  ) async {
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    emit(NotificationScreenInitialState());

    final nextPage = currentPage + 1;
    final res = await apiRepository.getNotifications(page: nextPage);
    if ((res.status == 1 || res.status == 200) &&
        res.data != null &&
        res.data!.isNotEmpty) {
      currentPage = nextPage;
      notifications.addAll(res.data!);
      if (res.data!.length < 20) {
        hasMore = false;
      }
    } else {
      hasMore = false;
    }

    isLoadingMore = false;
    emit(NotificationScreenInitialState());
  }
}
