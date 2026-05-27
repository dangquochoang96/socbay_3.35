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
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/secure_storage_utils.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  bool _isShowingExpiredTokenAlert = false;
  final String tag = 'RootBloc';
  RootBloc() : super(Uninitialized()) {
    on<AppStarted>(_mapAppStartedToState);
    on<LoggedIn>(_mapLoggedInToState);
    on<AccessTokenExpired>(_mapShowTokenExpiredEventToState);
    on<DismissAccessTokenExpiredAlert>(
      _mapDismissDialogTokenExpiredEventToState,
    );
    on<NoInternet>((event, emit) {
      emit(NoInternetConnection());
    });
  }

  bool _isApiSuccess(Map<String, dynamic> map) {
    final status = map['status'] ?? map['code'];
    return status == 1 || status == '1';
  }

  FutureOr<void> _mapAppStartedToState(
    AppStarted event,
    Emitter<RootState> emit,
  ) async {
    LoggerUtil.info('AppStarted received', tag: tag);
    // var currentUser = await SecureStorageUtil.shared.getCurrentUserLogin();
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      var database = await ($FloorAppDatabase
          .databaseBuilder('socbay.db')
          .build());
      var currentUser = await database.userDao.findAllUsers();
      if (currentUser.isEmpty || currentUser.first.id <= 0) {
        LoggerUtil.warning('AppStarted -> no valid local user', tag: tag);
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
          LoggerUtil.info(
            'AppStarted userById response=${resJson.data}',
            tag: tag,
          );
          var map = Map<String, dynamic>.from(json.decode(resJson.toString()));
          if (_isApiSuccess(map)) {
            UserProfile userProfile = UserProfile.fromJson(map['data']);
            if ((userProfile.id ?? 0) <= 0) {
              LoggerUtil.warning(
                'AppStarted -> invalid user id from API',
                tag: tag,
              );
              await PushNotificationService.instance.clearAuthenticatedUser();
              await database.userDao.deleteAllUser();
              emit(Unauthenticated());
              return;
            }
            App.instance.userApp = userProfile;
            await PushNotificationService.instance.setAuthenticatedUser(
              userProfile.id.toString(),
            );
            final userGetMapper = UserProfileToUser();
            final user = userGetMapper(userProfile);
            await database.userDao.deleteAllUser();
            await database.userDao.insertUser(user);
            await Future.delayed(const Duration(milliseconds: 500));
            LoggerUtil.info('AppStarted -> emit Authenticated', tag: tag);
            emit(Authenticated());
          } else {
            LoggerUtil.warning(
              'AppStarted -> API not success map=$map',
              tag: tag,
            );
            await PushNotificationService.instance.clearAuthenticatedUser();
            await database.userDao.deleteAllUser();
            emit(Unauthenticated());
          }
        } on DioException catch (e) {
          LoggerUtil.error('AppStarted DioException=$e', tag: tag);
          await PushNotificationService.instance.clearAuthenticatedUser();
          emit(Unauthenticated());
        } finally {
          await database.close();
        }
      }
    } else {
      var currentUser = App.instance.userApp;
      if (currentUser == null || (currentUser.id ?? 0) <= 0) {
        LoggerUtil.warning('AppStarted web/other -> no current user', tag: tag);
        await PushNotificationService.instance.clearAuthenticatedUser();
        emit(Unauthenticated());
      } else {
        try {
          var dio = Dio();
          final Response resJson = await dio.get(
            AppConfig.instance.apiUrl(ApiEndpoints.userById(currentUser.id)),
          );
          LoggerUtil.info(
            'AppStarted web/other userById response=${resJson.data}',
            tag: tag,
          );
          var map = Map<String, dynamic>.from(json.decode(resJson.toString()));
          if (_isApiSuccess(map)) {
            UserProfile userProfile = UserProfile.fromJson(map['data']);
            if ((userProfile.id ?? 0) <= 0) {
              LoggerUtil.warning(
                'AppStarted web/other -> invalid user id from API',
                tag: tag,
              );
              await PushNotificationService.instance.clearAuthenticatedUser();
              App.instance.onLogout();
              emit(Unauthenticated());
              return;
            }
            App.instance.userApp = userProfile;
            await PushNotificationService.instance.setAuthenticatedUser(
              userProfile.id.toString(),
            );
            await Future.delayed(const Duration(milliseconds: 500));
            LoggerUtil.info(
              'AppStarted web/other -> emit Authenticated',
              tag: tag,
            );
            emit(Authenticated());
          } else {
            // SecureStorageUtil.shared.logoutCurrentUser();
            LoggerUtil.warning(
              'AppStarted web/other -> API not success map=$map',
              tag: tag,
            );
            App.instance.onLogout();
            emit(Unauthenticated());
          }
        } on DioException catch (e) {
          // SecureStorageUtil.shared.logoutCurrentUser();
          LoggerUtil.error('AppStarted web/other DioException=$e', tag: tag);
          App.instance.onLogout();
          emit(Unauthenticated());
        }
      }
    }
  }

  FutureOr<void> _mapLoggedInToState(
    LoggedIn event,
    Emitter<RootState> emit,
  ) async {
    LoggerUtil.info('LoggedIn received', tag: tag);
    if ((App.instance.userApp?.id ?? 0) > 0) {
      emit(Authenticated());
      return;
    }
    emit(Unauthenticated());
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
