import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/user_info/user_screen_event.dart';
import 'package:socbay/blocs/user_info/user_screen_state.dart';
import 'package:socbay/data/model/local/account_db.dart';
import 'package:socbay/data/model/request/user_info_request.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/data/response/api_response.dart';
import 'package:socbay/db/database.dart';

class UserScreenBloc extends Bloc<UserScreenEvent, UserScreenState> {
  late ApiRepository apiRepository;
  bool isLoading = false;
  UserProfile? user = App.instance.userApp;
  List<AccountDb> accounts = [];

  UserScreenBloc({required this.apiRepository})
    : super(UserScreenInitialState()) {
    on<UserScreenStartedEvent>(_mapStartedEventToState);
    on<UserScreenLogoutEvent>(_mapLogoutEventToState);
    on<UserScreenChangeAvatarEvent>(_mapChangeAvatarEventToState);
  }

  FutureOr<void> _mapStartedEventToState(
    UserScreenStartedEvent event,
    Emitter<UserScreenState> emit,
  ) async {
    // accounts = await DbManager.instance.getAccounts();

    final DefaultResponse res = await apiRepository.getUserInfo();
    if (res.status == HttpStatus.ok) {
      App.instance.userApp = res.data;
      user = res.data;
    }
    emit(UserScreenInitialState());
  }

  FutureOr<void> _mapLogoutEventToState(
    UserScreenLogoutEvent event,
    Emitter<UserScreenState> emit,
  ) async {
    isLoading = true;
    emit(UserScreenInitialState());
    try {
      await apiRepository.logout();
    } catch (_) {
      // Local logout must still complete if the server logout request fails.
    } finally {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        final database = await $FloorAppDatabase
            .databaseBuilder('socbay.db')
            .build();
        await database.userDao.deleteAllUser();
        await database.close();
      }
      await App.instance.onLogout();
    }
    isLoading = false;
    emit(UserScreenLogoutState());
  }

  FutureOr<void> _mapChangeAvatarEventToState(
    UserScreenChangeAvatarEvent event,
    Emitter<UserScreenState> emit,
  ) async {
    isLoading = true;
    emit(UserScreenInitialState());

    final res = await apiRepository.uploadFile(file: event.file);
    isLoading = false;
    emit(UserScreenInitialState());
    if (res.status == HttpStatus.ok) {
      String url = res.data["url"] ?? "";
      if (url.isNotEmpty) {
        final resUpdateUserInfo = await apiRepository.updateUserInfo(
          UserInfoRequest(avatar: url),
        );
        user = resUpdateUserInfo.data;
      }
    }
    emit(UserScreenInitialState());
  }
}
