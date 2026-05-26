import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:http/http.dart' as http;

import 'historyid_screen_event.dart';
import 'historyid_screen_state.dart';

class HistoryidScreenBloc
    extends Bloc<HistoryidScreenEvent, HistoryidScreenState> {
  final ApiRepository apiRepository;
  List<TaskModel> lstBooking = [];
  List<OrderModel> lstMachine = [];
  bool isLoading = false;
  HistoryidScreenBloc({required this.apiRepository})
    : super(HistoryidScreenInitialState()) {
    on<HistoryidScreenTabPressEvent>(_mapTabPressEventToState);
    on<BookingDeleteidTaskEvent>(_mapBookingDeleteTaskEventToState);
  }

  Future<FutureOr<void>> _mapTabPressEventToState(
    HistoryidScreenTabPressEvent event,
    Emitter<HistoryidScreenState> emit,
  ) async {
    emit(HistoryidScreenInitialState());
    isLoading = true;
    if (event.index == 0) {
      //var userAccount = await DbManager.instance.getAccounts();
      try {
        var url = AppConfig.instance.apiUri(
          ApiEndpoints.tasksByCustomer(App.instance.userApp?.id.toString()),
          {'page': "1"},
        );
        print("X3");
        print(
          AppConfig.instance.apiUrl(
            ApiEndpoints.tasksByCustomer(App.instance.userApp?.id.toString()),
          ),
        );
        var res = await http.get(url);
        if (res.statusCode == HttpStatus.ok) {
          var l = Map<String, dynamic>.from(json.decode(res.body));
          lstBooking = List<TaskModel>.from(
            l["data"].map((model) => TaskModel.fromJson(model)),
          );
          print("X3");
          print(
            List<TaskModel>.from(
              l["data"].map((model) => TaskModel.fromJson(model)),
            ),
          );
        }
      } catch (exception) {
        LoggerUtil.log(exception.toString());
      }
    } else {
      try {
        var url = AppConfig.instance.apiUri(
          ApiEndpoints.userProducts(App.instance.userApp?.id.toString()),
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
    emit(HistoryidScreenInitialState());
  }

  Future<void> _mapBookingDeleteTaskEventToState(
    BookingDeleteidTaskEvent event,
    Emitter<HistoryidScreenState> emit,
  ) async {
    isLoading = true;
    // final result =
    // await apiRepository.deleteTask(event.taskId, event.name, event.des);
    var url = AppConfig.instance.apiUri(ApiEndpoints.taskDelete, {
      'txt-uid': event.taskId.toString(),
      'des': event.des,
    });
    var res1 = await http.post(url);
    if (res1.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res1.body));
      if (l['status'] == 1) {
        emit(BookingDeleteidSuccessState());
      } else {
        emit(BookingDeleteidErrorState());
      }
    }
    add(HistoryidScreenTabPressEvent(0));
    isLoading = false;
  }
}
