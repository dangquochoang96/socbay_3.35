import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;

import 'evaluate_event.dart';
import 'evaluate_state.dart';

class EvaluateScreenBloc
    extends Bloc<EvaluateScreenEvent, EvaluateScreenState> {
  EvaluateScreenBloc({required this.apiRepository, required this.args})
    : super(EvaluateScreenInitialState()) {
    on<EvaluateScreenStartedEvent>(_mapStartedEventToState);
  }
  final ApiRepository apiRepository;
  List<UserModel> users = [];
  bool isLoading = false;
  Map<String, dynamic> args;

  FutureOr<void> _mapStartedEventToState(
    EvaluateScreenStartedEvent event,
    Emitter<EvaluateScreenState> emit,
  ) async {
    isLoading = true;
    emit(EvaluateScreenInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.userSupport);
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      users = List<UserModel>.from(
        l["data"].map((model) => UserModel.fromJson(model)),
      );
    }
    isLoading = false;
    emit(EvaluateScreenInitialState());
  }
}
