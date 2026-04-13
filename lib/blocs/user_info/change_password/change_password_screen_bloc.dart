import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/user_info/change_password/change_password_screen_event.dart';
import 'package:socbay/blocs/user_info/change_password/change_password_screen_state.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/db/database.dart';
import 'package:socbay/db/object_mapper/object_mapper.dart';

class ChangePasswordScreenBloc
    extends Bloc<ChangePasswordScreenEvent, ChangePasswordScreenState> {
  ChangePasswordScreenBloc({required this.apiRepository})
      : super(ChangePasswordScreenInitialState()) {
    on<ChangePasswordScreenSubmitChangeEvent>(_mapChangePasswordEventToState);
  }

  final ApiRepository apiRepository;
  bool isLoading = false;

  FutureOr<void> _mapChangePasswordEventToState(
      ChangePasswordScreenSubmitChangeEvent event,
      Emitter<ChangePasswordScreenState> emit) async {
    isLoading = true;
    emit(ChangePasswordScreenInitialState());
    final res = await apiRepository.changePassword(event.changePasswordRequest);
    isLoading = false;
    if (res.data != null && res.status == 1) {
      var db = await $FloorAppDatabase.databaseBuilder('socbay.db').build();
      await db.userDao.deleteAllUser();
      final userGetMapper = UserProfileToUser();
      final usr = userGetMapper(res.data!);
      // await DbManager.instance.insertAccount(
      //     username: App.instance.userApp?.phone ?? '',
      //     id: App.instance.userApp?.id?.toString() ?? '',
      //     password: event.changePasswordRequest.password);
      App.instance.userApp = res.data;
      await db.userDao.insertUser(usr);
      emit(const ChangePasswordScreenDoneState());
    } else {
      emit(ChangePasswordScreenDoneState(error: res.message));
    }
  }
}
