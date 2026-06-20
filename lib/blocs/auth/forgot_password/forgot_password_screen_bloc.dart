import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/auth/forgot_password/forgot_password_screen_event.dart';
import 'package:socbay/blocs/auth/forgot_password/forgot_password_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/utils/logger_util.dart';

class ForgotPasswordScreenBloc
    extends Bloc<ForgotPasswordScreenEvent, ForgotPasswordScreenState> {
  ForgotPasswordScreenBloc({required this.apiRepository})
    : super(ForgotPasswordScreenInitialState()) {
    on<CheckUserExistEvent>(_checkUserExist);
  }

  final ApiRepository apiRepository;
  Future<void> _checkUserExist(
    CheckUserExistEvent event,
    Emitter<ForgotPasswordScreenState> emitter,
  ) async {
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.userCheck, {
        'phone': event.phone,
      });
      var res = await http.post(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        emitter(CheckUserExistState(l["code"].toString()));
      }
    } catch (exception) {
      LoggerUtil.log(jsonEncode(exception));
      emitter(CheckUserExistState("2"));
    }
  }
}
