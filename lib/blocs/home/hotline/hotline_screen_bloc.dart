import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/home/hotline/hotline_screen_event.dart';
import 'package:socbay/blocs/home/hotline/hotline_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:http/http.dart' as http;



class HotlineScreenBloc extends Bloc<HotlineScreenEvent, HotlineScreenState> {
  HotlineScreenBloc(this.apiRepository) : super(HotlineScreenInitialState()) {
    on<HotlineScreenStartedEvent>(_mapStartedEventToState);
  }

  final ApiRepository apiRepository;
  List<UserProfile> users = [];
  bool isLoading = false;

  FutureOr<void> _mapStartedEventToState(
      HotlineScreenStartedEvent event, Emitter<HotlineScreenState> emit) async {
    isLoading = true;
    emit(HotlineScreenInitialState());
    var url = Uri.http(AppConfig.instance.values.apiUrl,"/api/user/support");
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String,dynamic>.from(json.decode(res.body));
      users = List<UserProfile>.from(l["data"].map((model)=> UserProfile.fromJson(model)));
    }
    // final res = await apiRepository.getListSupporters();
    // if(res.data!=null){
    //   users = res.data!;
    // }
    isLoading = false;
    emit(HotlineScreenInitialState());
  }
}
