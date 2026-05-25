import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:socbay/application.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/db/database.dart';
import 'package:socbay/db/object_mapper/object_mapper.dart';
import 'package:socbay/services/push_notification_service.dart';
import 'package:socbay/utils/logger_util.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginScreenBloc extends Bloc<LoginScreenEvent, LoginScreenState> {
  final ApiRepository apiRepository;
  bool isLoading = false;

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
      var dio = Dio();
      final Response resJson = await dio.post(
        "$protocol${AppConfig.instance.values.apiUrl}/api/user/login",
        data: {"phone": event.phone, "pass": event.password},
      );
      var map = Map<String, dynamic>.from(json.decode(resJson.toString()));
      if (map['code'] == 1) {
        UserProfile userProfile = UserProfile.fromJson(map['data']);
        App.instance.userApp = userProfile;
        await PushNotificationService.instance.setAuthenticatedUser(
          userProfile.id.toString(),
        );

        if (kDebugMode) {
          print("thông tin tài khoản: ${map['data']}");
        }
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          final database = await $FloorAppDatabase
              .databaseBuilder('socbay.db')
              .build();
          final userGetMapper = UserProfileToUser();
          final user = userGetMapper(userProfile);
          await database.userDao.insertUser(user);
          await database.close();
        }
        await Future.delayed(const Duration(milliseconds: 500));
        emit(LogInSuccessState());
      } else {
        emit(LogInFailureState(map['message'] ?? "Error"));
      }
    } on DioException catch (e) {
      print("------LoginError------");
      print(e);
      LoggerUtil.error(jsonEncode(e));
    }
    isLoading = false;
    emit(LoginInitialState());
  }
}
