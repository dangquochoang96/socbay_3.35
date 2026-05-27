import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/blocs/technique/technique_screen_event.dart';
import 'package:socbay/blocs/technique/technique_screen_state.dart';

import '../../application.dart';

class TechniqueScreenBloc
    extends Bloc<TechniqueScreenEvent, TechniqueScreenState> {
  TechniqueScreenBloc({required this.apiRepository, required this.args})
    : super(TechniqueScreenInitialState()) {
    on<TechniqueScreenStartedEvent>(_mapStartedEventToState);
    on<TechniqueScreenStartedFaEvent>(_mapStartedEventFaToState);
  }
  final ApiRepository apiRepository;
  List<UserProfile> users = [];
  List<UserProfile> favouriteStaffs = [];
  bool isLoading = false;
  Map<String, dynamic> args;

  FutureOr<void> _mapStartedEventToState(
    TechniqueScreenStartedEvent event,
    Emitter<TechniqueScreenState> emit,
  ) async {
    isLoading = true;
    emit(TechniqueScreenInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.userSupport);
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      users = List<UserProfile>.from(
        l["data"].map((model) => UserProfile.fromJson(model)),
      );
    }
    isLoading = false;
    emit(TechniqueScreenInitialState());
  }

  FutureOr<void> _mapStartedEventFaToState(
    TechniqueScreenEvent event,
    Emitter<TechniqueScreenState> emit,
  ) async {
    isLoading = true;
    emit(TechniqueScreenInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.userFavorites, {
      'user_id': App.instance.userApp?.id.toString(),
    });
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      favouriteStaffs = List<UserProfile>.from(
        l["data"].map((model) => UserProfile.fromJson(model)),
      );
    }
    isLoading = false;
    emit(TechniqueScreenInitialState());
  }
}
