import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:socbay/application.dart';
import 'package:socbay/data/model/login_response.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/db/database.dart';
import 'package:socbay/db/object_mapper/object_mapper.dart';
import 'package:socbay/services/push_notification_service.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/secure_storage_utils.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginScreenBloc extends Bloc<LoginScreenEvent, LoginScreenState> {
  final ApiRepository apiRepository;
  bool isLoading = false;
  final String tag = 'LoginScreenBloc';

  LoginScreenBloc({required this.apiRepository}) : super(LoginInitialState()) {
    on<LoginEvent>(_mapLoginEventToState);
  }

  Future _mapLoginEventToState(
    LoginEvent event,
    Emitter<LoginScreenState> emit,
  ) async {
    isLoading = true;
    emit(LoginInitialState());
    try {
      LoggerUtil.info('login started phone=${event.phone}', tag: tag);
      final fcmToken = await PushNotificationService.instance.getToken();
      final result = await apiRepository.loginAccount(
        event.phone,
        event.password,
        fcmToken,
      );
      LoggerUtil.info(
        'login result status=${result.status} message=${result.message} hasData=${result.data != null}',
        tag: tag,
      );

      if (result.data != null && result.status == 200) {
        final loginResponse = result.data as LoginResponse;
        final UserProfile? userProfile = loginResponse.user;
        LoggerUtil.info(
          'login response parsed tokenPresent=${(loginResponse.accessToken ?? '').isNotEmpty} userId=${userProfile?.id}',
          tag: tag,
        );

        if ((loginResponse.accessToken ?? '').isNotEmpty) {
          await SecureStorageUtil.shared.writeData(
            SecureStorageUtil.tokenStorageKey,
            loginResponse.accessToken!,
          );
          LoggerUtil.info('saved token to secure storage', tag: tag);
        } else {
          LoggerUtil.warning('access token is empty', tag: tag);
        }

        if (userProfile == null) {
          LoggerUtil.error(
            'Login succeeded but user payload is missing',
            tag: tag,
          );
          emit(LogInFailureState(result.message ?? 'Du lieu user khong hop le'));
          return;
        }

        if ((userProfile.id ?? 0) <= 0) {
          LoggerUtil.error(
            'Login succeeded but user id is invalid: ${userProfile.id}',
            tag: tag,
          );
          emit(
            LogInFailureState(
              result.message ?? 'Khong the dang nhap: user id khong hop le',
            ),
          );
          return;
        }

        App.instance.userApp = userProfile;
        await PushNotificationService.instance.setAuthenticatedUser(
          userProfile.id.toString(),
        );

        if (kDebugMode) {
          print('Thong tin tai khoan: ${loginResponse.user?.toJson()}');
        }

        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          final database = await $FloorAppDatabase
              .databaseBuilder('socbay.db')
              .build();
          final userGetMapper = UserProfileToUser();
          final user = userGetMapper(userProfile);
          await database.userDao.deleteAllUser();
          await database.userDao.insertUser(user);
          await database.close();
          LoggerUtil.info('saved user to local db id=${user.id}', tag: tag);
        }

        await Future.delayed(const Duration(milliseconds: 500));
        LoggerUtil.info('emit LogInSuccessState', tag: tag);
        emit(LogInSuccessState());
      } else {
        LoggerUtil.warning(
          'emit LogInFailureState status=${result.status} message=${result.message}',
          tag: tag,
        );
        emit(LogInFailureState(result.message ?? 'Error'));
      }
    } catch (e) {
      LoggerUtil.error('Login error: $e', tag: tag);
      emit(LogInFailureState('Error'));
    }
    isLoading = false;
    LoggerUtil.info('emit LoginInitialState after login flow', tag: tag);
    emit(LoginInitialState());
  }
}
