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
  }

  final ApiRepository apiRepository;
  List<NotificationResponse> notifications = [];
  bool isLoading = false;

  FutureOr<void> _mapStartedEventToState(
    NotificationScreenStartedEvent event,
    Emitter<NotificationScreenState> emit,
  ) async {
    isLoading = true;
    emit(NotificationScreenInitialState());
    final res = await apiRepository.getNotifications();
    if (res.status == 1 && res.data != null) {
      notifications = res.data!;
    } else {}
    isLoading = false;
    emit(NotificationScreenInitialState());
  }
}
