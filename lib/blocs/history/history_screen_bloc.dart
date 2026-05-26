import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/history/history_screen_event.dart';
import 'package:socbay/blocs/history/history_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:http/http.dart' as http;

class HistoryScreenBloc extends Bloc<HistoryScreenEvent, HistoryScreenState> {
  final ApiRepository apiRepository;
  List<TaskModel> lstBooking = [];
  List<OrderModel> lstMachine = [];
  bool isLoading = false;
  HistoryScreenBloc({required this.apiRepository})
    : super(HistoryScreenInitialState(initialIndex: 1)) {
    on<HistoryScreenTabPressEvent>(_mapTabPressEventToState);
    on<BookingDeleteTaskEvent>(_mapBookingDeleteTaskEventToState);
  }

  Future<FutureOr<void>> _mapTabPressEventToState(
    HistoryScreenTabPressEvent event,
    Emitter<HistoryScreenState> emit,
  ) async {
    emit(HistoryScreenInitialState(initialIndex: 1));
    emit(state.copyWith(initialIndex: event.index));
    isLoading = true;
    if (event.index == 0) {
      try {
        var url = AppConfig.instance.apiUri(
          ApiEndpoints.tasksByCustomer(App.instance.userApp?.id),
          {'page': "1"},
        );
        var res = await http.get(url);
        if (res.statusCode == HttpStatus.ok) {
          var l = Map<String, dynamic>.from(json.decode(res.body));
          lstBooking = List<TaskModel>.from(
            l["data"].map((model) => TaskModel.fromJson(model)),
          );
        }
      } catch (exception) {
        LoggerUtil.log(exception.toString());
      }
    } else {
      try {
        var url = AppConfig.instance.apiUri(
          ApiEndpoints.userProducts(App.instance.userApp?.id),
        );
        var res = await http.get(url);
        if (res.statusCode == HttpStatus.ok) {
          var l = Map<String, dynamic>.from(json.decode(res.body));
          var m = Map<String, dynamic>.from(l["data"]);
          lstMachine = List<OrderModel>.from(
            m["listProducts"].map((model) => OrderModel.fromJson(model)),
          );
        }
      } catch (exception) {
        LoggerUtil.log(exception.toString());
      }
    }
    isLoading = false;
    emit(HistoryScreenInitialState(initialIndex: 1));
  }

  Future<void> _mapBookingDeleteTaskEventToState(
    BookingDeleteTaskEvent event,
    Emitter<HistoryScreenState> emit,
  ) async {
    isLoading = true;
    var url = AppConfig.instance.apiUri(ApiEndpoints.taskDelete, {
      'txt-uid': event.taskId.toString(),
      'des': event.des,
    });
    var res1 = await http.post(url);
    if (res1.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res1.body));
      if (l['status'] == 1) {
        emit(BookingDeleteSuccessState(initialIndex: 1));
      } else {
        emit(BookingDeleteErrorState(initialIndex: 1));
      }
    }
    add(HistoryScreenTabPressEvent(0));
    isLoading = false;
  }
}
