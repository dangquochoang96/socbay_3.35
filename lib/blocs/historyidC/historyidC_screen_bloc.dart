import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/auth_http.dart' as http;

import 'historyidC_screen_event.dart';
import 'historyidC_screen_state.dart';

class HistoryidCScreenBloc
    extends Bloc<HistoryidCScreenEvent, HistoryidCScreenState> {
  final ApiRepository apiRepository;
  final Map<String, dynamic> args;

  List<TaskModel> lstBooking = [];
  List<OrderModel> lstMachine = [];
  List<UserModel> lsUserModel = [];

  int subSavePoint = 0;
  TaskModel? taskModel;

  bool isLoading = false;

  HistoryidCScreenBloc({required this.apiRepository, required this.args})
    : super(HistoryidCScreenInitialState()) {
    on<HistotyiDCScreenStartEvent>(_mapChangeTypeServiceEventToState);
    on<HistoryidCScreenTabPressEvent>(_mapTabPressEventToState);
    on<BookingDeleteidCTaskEvent>(_mapBookingDeleteTaskEventToState);
  }

  Future<FutureOr<void>> _mapChangeTypeServiceEventToState(
    HistotyiDCScreenStartEvent event,
    Emitter<HistoryidCScreenState> emit,
  ) async {
    emit(HistoryiDCScreenInitialState());
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.taskById(args['id']));

      print("x2");
      print(AppConfig.instance.apiUrl(ApiEndpoints.taskById(args['id'])));

      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        taskModel = TaskModel.fromJson(l["data"]);

        print("x6");
        print(taskModel);
        add(HistoryidCScreenTabPressEvent(0));
      }
      emit(HistoryiDCScreenInitialState());
    } catch (ex) {
      LoggerUtil.log(ex.toString());
    }
  }

  Future<FutureOr<void>> _mapTabPressEventToState(
    HistoryidCScreenTabPressEvent event,
    Emitter<HistoryidCScreenState> emit,
  ) async {
    emit(HistoryidCScreenInitialState());
    if (event.index == 0) {
      try {
        var url = AppConfig.instance.apiUri(
          ApiEndpoints.tasksByCustomer(args['id']),
          {'page': "1"},
        );

        print("x3");
        print(
          AppConfig.instance.apiUrl(ApiEndpoints.tasksByCustomer(args['id'])),
        );

        var res = await http.get(url);
        if (res.statusCode == HttpStatus.ok) {
          var l = Map<String, dynamic>.from(json.decode(res.body));
          lstBooking = List<TaskModel>.from(
            l["data"].map((model) => TaskModel.fromJson(model)),
          ).toList();
          print("dữ liệu đặt lịch: $l");
        }
      } catch (exception) {
        LoggerUtil.log(exception.toString());
      }
    } else {
      try {
        var url = AppConfig.instance.apiUri(
          ApiEndpoints.userProducts(args['id']),
        );
        print(AppConfig.instance.apiUrl(ApiEndpoints.userProducts(args['id'])));

        var res = await http.get(url);
        if (res.statusCode == HttpStatus.ok) {
          var l = Map<String, dynamic>.from(json.decode(res.body));
          var m = Map<String, dynamic>.from(l["data"]);
          lstMachine = List<OrderModel>.from(
            m["listProducts"].map((model) => OrderModel.fromJson(model)),
          );
          print("dữ liệu nhật ký thay lõi: $m");
        }
      } catch (exception) {
        LoggerUtil.log(exception.toString());
      }
    }

    isLoading = false;
    emit(HistoryidCScreenInitialState());
  }

  Future<void> _mapBookingDeleteTaskEventToState(
    BookingDeleteidCTaskEvent event,
    Emitter<HistoryidCScreenState> emit,
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
        emit(BookingDeleteidCSuccessState());
      } else {
        emit(BookingDeleteidCErrorState());
      }
    }
    add(HistoryidCScreenTabPressEvent(0));
    isLoading = false;
  }
}
