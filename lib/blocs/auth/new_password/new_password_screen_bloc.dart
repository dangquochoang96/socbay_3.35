import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/auth/new_password/new_password_screen_event.dart';
import 'package:socbay/blocs/auth/new_password/new_password_screen_state.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

class NewPasswordScreenBloc
    extends Bloc<NewPasswordScreenEvent, NewPasswordScreenState> {
  NewPasswordScreenBloc({required this.apiRepository, required this.args})
    : super(NewPasswordScreenInitialState()) {
    on<NewPasswordScreenSubmitEvent>(_mapSubmitNewPasswordToState);
  }

  final ApiRepository apiRepository;
  final Map<String, dynamic> args;
  bool isLoading = false;

  FutureOr<void> _mapSubmitNewPasswordToState(
    NewPasswordScreenSubmitEvent event,
    Emitter<NewPasswordScreenState> emit,
  ) async {
    isLoading = true;
    emit(NewPasswordScreenInitialState());
    final res = await apiRepository.forgotPassword(event.newPasswordRequest);
    isLoading = false;
    emit(NewPasswordScreenInitialState());
    if (res.data != null && res.status == HttpStatus.ok) {
      emit(const NewPasswordScreenSubmitDoneState());
    } else {
      emit(NewPasswordScreenSubmitDoneState(error: res.message));
    }
  }
}
