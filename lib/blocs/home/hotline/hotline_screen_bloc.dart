import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/home/hotline/hotline_screen_event.dart';
import 'package:socbay/blocs/home/hotline/hotline_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class HotlineScreenBloc extends Bloc<HotlineScreenEvent, HotlineScreenState> {
  HotlineScreenBloc(this.apiRepository) : super(HotlineScreenInitialState()) {
    on<HotlineScreenStartedEvent>(_mapStartedEventToState);
  }

  final ApiRepository apiRepository;
  List<UserModel> users = [];
  bool isLoading = false;

  FutureOr<void> _mapStartedEventToState(
    HotlineScreenStartedEvent event,
    Emitter<HotlineScreenState> emit,
  ) async {
    isLoading = true;
    emit(HotlineScreenInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.userSupport);
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      users = List<UserModel>.from(
        l["data"].map((model) => UserModel.fromJson(model)),
      );
    }
    // final res = await apiRepository.getListSupporters();
    // if(res.data!=null){
    //   users = res.data!;
    // }
    isLoading = false;
    emit(HotlineScreenInitialState());
  }
}
