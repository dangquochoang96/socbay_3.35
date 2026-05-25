import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_event.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/utils/logger_util.dart';

import '../../../data/model/task_model.dart';
import '../../../data/repository/auth/api_repository.dart';
import 'package:http/http.dart' as http;

class DetailBookingBloc extends Bloc<DetailBookingEvent, DetailBookingState> {
  final ApiRepository apiRepository;
  bool isLoading = false;
  Map<String, dynamic> args;
  TaskModel? taskModel;

  DetailBookingBloc({required this.apiRepository, required this.args})
      : super(DetailBookingInitialState()) {
    on<DetailBookingStartedEvent>(_mapStartedEventToState);
  }

  FutureOr<void> _mapStartedEventToState(
      DetailBookingStartedEvent event, Emitter<DetailBookingState> emit) async {
    isLoading = true;
    //emit(DetailBookingInitialState());
    try{
      var url = Uri.http(AppConfig.instance.values.apiUrl,"/api/tasks/${args['id']}");
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String,dynamic>.from(json.decode(res.body));
        taskModel = TaskModel.fromJson(l["data"]);
        //print(blogs);
      }
    }catch(ex){
      LoggerUtil.error("---GET TASK ${args['id']} ERROR---\n$ex");
    }

    isLoading = false;
    emit(DetailBookingInitialState());
  }
}
