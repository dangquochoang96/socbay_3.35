import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/root/root_event.dart';
import 'package:socbay/blocs/root/root_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/db/database.dart';
import 'package:socbay/db/object_mapper/object_mapper.dart';
import 'package:socbay/services/push_notification_service.dart';
import 'package:socbay/utils/secure_storage_utils.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  bool _isShowingExpiredTokenAlert = false;
  RootBloc() : super(Uninitialized()) {
    on<AppStarted>(_mapAppStartedToState);
    on<AccessTokenExpired>(_mapShowTokenExpiredEventToState);
    on<DismissAccessTokenExpiredAlert>(
      _mapDismissDialogTokenExpiredEventToState,
    );
    on<NoInternet>((event, emit) {
      emit(NoInternetConnection());
    });
  }

  FutureOr<void> _mapAppStartedToState(
    AppStarted event,
    Emitter<RootState> emit,
  ) async {
    // var currentUser = await SecureStorageUtil.shared.getCurrentUserLogin();
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      var database = await ($FloorAppDatabase
          .databaseBuilder('socbay.db')
          .build());
      var currentUser = await database.userDao.findAllUsers();
      if (currentUser.isEmpty || currentUser.first.id == 0) {
        await PushNotificationService.instance.clearAuthenticatedUser();
        await database.close();
        emit(Unauthenticated());
      } else {
        //App.instance.userApp = currentUser;
        try {
          var dio = Dio();
          final Response resJson = await dio.get(
            AppConfig.instance.apiUrl(
              ApiEndpoints.userById(currentUser.first.id),
            ),
          );
          var map = Map<String, dynamic>.from(json.decode(resJson.toString()));
          if (map['code'] == 1) {
            UserProfile userProfile = UserProfile.fromJson(map['data']);
            App.instance.userApp = userProfile;
            await PushNotificationService.instance.setAuthenticatedUser(
              userProfile.id.toString(),
            );
            final userGetMapper = UserProfileToUser();
            final user = userGetMapper(userProfile);
            await database.userDao.deleteAllUser();
            await database.userDao.insertUser(user);
            await Future.delayed(const Duration(milliseconds: 500));
            emit(Authenticated());
          } else {
            await PushNotificationService.instance.clearAuthenticatedUser();
            await database.userDao.deleteAllUser();
            emit(Unauthenticated());
          }
        } on DioException catch (_) {
          await PushNotificationService.instance.clearAuthenticatedUser();
          emit(Unauthenticated());
        } finally {
          await database.close();
        }
      }
    } else {
      var currentUser = App.instance.userApp;
      if (currentUser == null || currentUser.id == 0) {
        await PushNotificationService.instance.clearAuthenticatedUser();
        emit(Unauthenticated());
      } else {
        try {
          var dio = Dio();
          final Response resJson = await dio.get(
            AppConfig.instance.apiUrl(ApiEndpoints.userById(currentUser.id)),
          );
          var map = Map<String, dynamic>.from(json.decode(resJson.toString()));
          if (map['code'] == 1) {
            UserProfile userProfile = UserProfile.fromJson(map['data']);
            App.instance.userApp = userProfile;
            await PushNotificationService.instance.setAuthenticatedUser(
              userProfile.id.toString(),
            );
            await Future.delayed(const Duration(milliseconds: 500));
            emit(Authenticated());
          } else {
            // SecureStorageUtil.shared.logoutCurrentUser();
            App.instance.onLogout();
            emit(Unauthenticated());
          }
        } on DioException catch (_) {
          // SecureStorageUtil.shared.logoutCurrentUser();
          App.instance.onLogout();
          emit(Unauthenticated());
        }
      }
    }
  }

  FutureOr<void> _mapShowTokenExpiredEventToState(
    AccessTokenExpired event,
    Emitter<RootState> emit,
  ) async {
    if (!_isShowingExpiredTokenAlert) {
      _isShowingExpiredTokenAlert = true;
      await SecureStorageUtil.shared.deleteKey(
        SecureStorageUtil.tokenStorageKey,
      );
      await PushNotificationService.instance.clearAuthenticatedUser();
      emit(ShowAccessTokenExpiredAlert());
      emit(Unauthenticated());
    }
  }

  Future<FutureOr<void>> _mapDismissDialogTokenExpiredEventToState(
    DismissAccessTokenExpiredAlert event,
    Emitter<RootState> emit,
  ) async {
    _isShowingExpiredTokenAlert = false;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      var database = await ($FloorAppDatabase
          .databaseBuilder('socbay.db')
          .build());
      await database.userDao.deleteAllUser();
    }
  }
}
