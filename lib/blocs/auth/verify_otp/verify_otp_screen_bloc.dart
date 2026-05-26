import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/auth/verify_otp/verify_otp_screen_event.dart';
import 'package:socbay/blocs/auth/verify_otp/verify_otp_screen_state.dart';
import 'package:socbay/data/model/login_response.dart';
import 'package:socbay/data/model/request/register_request_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/data/response/api_response.dart';
import 'package:socbay/utils/parse_util.dart';
import 'package:socbay/utils/secure_storage_utils.dart';

enum VerifyOtpType { forgotPassword, register }

class VerifyOtpScreenBloc
    extends Bloc<VerifyOtpScreenEvent, VerifyOtpScreenState> {
  VerifyOtpScreenBloc({required this.apiRepository, required this.args})
    : super(VerifyOtpScreenInitialState()) {
    on<VerifyOtpScreenStartedEvent>(_mapStartedEventToState);
    on<VerifyOtpScreenRegisterEvent>(_mapRegisterEventToState);
    on<VerifyOtpScreenLoginEvent>(_mapLoginEventToState);
  }

  final ApiRepository apiRepository;
  final Map<String, dynamic> args;
  bool isLoading = false;
  String otp = "";

  FutureOr<void> _mapStartedEventToState(
    VerifyOtpScreenStartedEvent event,
    Emitter<VerifyOtpScreenState> emit,
  ) async {
    isLoading = true;
    emit(VerifyOtpScreenInitialState());
    final res = await apiRepository.setOTP(args['phone']);
    if (res.data != null) {
      otp = res.data["otp"].toString();
      emit(VerifyOtpScreenSetOtpState());
    }
    isLoading = false;
    emit(VerifyOtpScreenInitialState());
  }

  FutureOr<void> _mapRegisterEventToState(
    VerifyOtpScreenRegisterEvent event,
    Emitter<VerifyOtpScreenState> emit,
  ) async {
    isLoading = true;
    emit(VerifyOtpScreenInitialState());
    RegisterRequestModel registerRequestModel = RegisterRequestModel(
      username: args['phone'],
      password: args['password'],
      phone: args['phone'],
      otp: Parse.toIntValue(event.otp),
    );
    final res = await apiRepository.register(registerRequestModel);
    if (res.data != null && res.status == HttpStatus.ok) {
      emit(const VerifyOtpScreenRegisterSuccessState());
    } else {
      emit(VerifyOtpScreenRegisterSuccessState(error: res.message));
    }

    isLoading = false;
    emit(VerifyOtpScreenInitialState());
  }

  Future _mapLoginEventToState(
    VerifyOtpScreenLoginEvent event,
    Emitter<VerifyOtpScreenState> emit,
  ) async {
    isLoading = true;
    emit(VerifyOtpScreenInitialState());
    final DefaultResponse result = await apiRepository.loginAccount(
      args['phone'],
      args['password'],
    );
    if (result.status == 200) {
      LoginResponse loginResponse = result.data;
      if (loginResponse.accessToken != "") {
        await SecureStorageUtil.shared.writeData(
          SecureStorageUtil.tokenStorageKey,
          loginResponse.accessToken!,
        );
      }
      if (args['isStaff'] == true) {
        await SecureStorageUtil.shared.writeData(
          SecureStorageUtil.registerStaffKey,
          args['isStaff'].toString(),
        );
      }
      await Future.delayed(const Duration(milliseconds: 500));
      emit(VerifyOtpScreenLoginSuccessState());
    } else {
      emit(VerifyOtpScreenLogInFailureState(result.message ?? "Error"));
    }
    isLoading = false;
    emit(VerifyOtpScreenInitialState());
  }
}
