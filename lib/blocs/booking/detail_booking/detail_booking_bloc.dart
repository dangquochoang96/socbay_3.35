import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_event.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/utils/logger_util.dart';

import '../../../data/model/task_model.dart';
import '../../../data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class DetailBookingBloc extends Bloc<DetailBookingEvent, DetailBookingState> {
  final ApiRepository apiRepository;
  bool isLoading = false;
  Map<String, dynamic> args;
  TaskModel? taskModel;

  DetailBookingBloc({required this.apiRepository, required this.args})
    : isLoading = args['id'] != null,
      super(
        args['id'] != null
            ? DetailBookingLoadingState()
            : DetailBookingInitialState(),
      ) {
    on<DetailBookingStartedEvent>(_mapStartedEventToState);
  }

  FutureOr<void> _mapStartedEventToState(
    DetailBookingStartedEvent event,
    Emitter<DetailBookingState> emit,
  ) async {
    isLoading = true;
    emit(DetailBookingLoadingState());
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.taskById(args['id']));
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        taskModel = TaskModel.fromJson(l["data"]);
      } else {
        LoggerUtil.error(
          "---GET TASK ${args['id']} FAILED (status: ${res.statusCode})---",
        );
      }
    } catch (ex) {
      LoggerUtil.error("---GET TASK ${args['id']} ERROR---\n$ex");
    }

    isLoading = false;
    emit(DetailBookingInitialState());
  }
}
