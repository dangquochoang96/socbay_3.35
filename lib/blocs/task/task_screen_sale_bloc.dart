import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/task/task_screen_event.dart';
import 'package:socbay/blocs/task/task_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/db/db_manager.dart';
import 'package:socbay/utils/logger_util.dart';

import 'package:socbay/utils/auth_http.dart' as http;

class TaskScreenSaleBloc extends Bloc<TaskScreenEvent, TaskScreenState> {
  TaskScreenSaleBloc({required this.apiRepository})
    : super(MyTaskScreenInitialState()) {
    on<TaskScreenGetTaskAvailableEvent>(_mapGetTaskAvailableEventToState);
    on<TaskScreenGetTaskEvent>(_mapGetTaskEventToState);
    on<StaffTaskScreenGetTaskByDayEvent>(_mapGetTaskByDayEventToState);
    on<StaffTaskScreenGetTaskAssigedEvent>(_mapGetTaskAssigedEventToState);
    on<StaffTaskScreenUpdateTaskDoneEvent>(_mapUpdateTaskEventToState);
    on<StaffTaskScreenUpdateTaskDayDoneEvent>(_mapUpdateTaskEventDayToState);
    on<StaffTaskScreenGetTaskDoneEvent>(_mapGetTaskDoneEventToState);
    on<BookingDeleteTaskEvent>(_mapBookingDeleteTaskEventToState);
    on<BookingDeleteTaskToDayEvent>(_mapBookingDeleteTaskToDayEventToState);
  }

  final ApiRepository apiRepository;
  List<TaskModel> listTaskModel = [];
  List<TaskModel> staffListTaskBydayModel = [];
  List<TaskModel> staffListTaskAssigedModel = [];
  TaskModel? taskModel;
  bool isLoading = true;
  int page = 1;
  int total = 1;
  int pageTaskByday = 0;

  FutureOr<void> _mapGetTaskAvailableEventToState(
    TaskScreenGetTaskAvailableEvent event,
    Emitter<TaskScreenState> emit,
  ) async {}

  FutureOr<void> _mapGetTaskEventToState(
    TaskScreenGetTaskEvent event,
    Emitter<TaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    var userAccount = await DbManager.instance.getAccounts();
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.tasksByCustomer(userAccount.first.id),
        {'page': event.isRefresh ? 0 : page},
      );
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        List<TaskModel> newlistTaskModel = List<TaskModel>.from(
          l["data"].map((model) => TaskModel.fromJson(model)),
        );
        if (event.isRefresh) {
          listTaskModel.clear();
          page = 0;
        }
        page++;
        listTaskModel.addAll(newlistTaskModel);
      }
    } catch (exception) {
      LoggerUtil.log(jsonEncode(exception));
    }
    isLoading = false;
    emit(MyTaskScreenInitialState());
  }

  FutureOr<void> _mapGetTaskByDayEventToState(
    StaffTaskScreenGetTaskByDayEvent event,
    Emitter<TaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.tasks, {
        'page': event.isRefresh ? "0" : pageTaskByday.toString(),
        'sale_id': App.instance.userApp?.id.toString(),
        'start': DateFormat("yyyy-MM-dd").format(DateTime.now()),
      });
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        List<TaskModel> newlistTaskModel = List<TaskModel>.from(
          l["data"].map((model) => TaskModel.fromJson(model)),
        );
        if (event.isRefresh) {
          staffListTaskBydayModel.clear();
          pageTaskByday = 0;
        }
        if (newlistTaskModel.isNotEmpty) {
          pageTaskByday++;
        }
        staffListTaskBydayModel.addAll(newlistTaskModel);
      }
    } catch (exception) {
      LoggerUtil.log(jsonEncode(exception));
    }
    isLoading = false;
    emit(MyTaskScreenInitialState());
  }

  FutureOr<void> _mapGetTaskAssigedEventToState(
    StaffTaskScreenGetTaskAssigedEvent event,
    Emitter<TaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.tasksPending, {
        'sale_id': App.instance.userApp?.id.toString(),
      });
      // Fetch data from the new API endpoint
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var responseMap = Map<String, dynamic>.from(json.decode(res.body));
        List<TaskModel> newTaskModelList = List<TaskModel>.from(
          responseMap["data"].map((model) => TaskModel.fromJson(model)),
        );

        // Clear the list before adding new data, as we're fetching all data at once
        staffListTaskAssigedModel.clear();
        staffListTaskAssigedModel.addAll(newTaskModelList);
      }
    } catch (exception) {
      LoggerUtil.log(jsonEncode(exception));
    }
    isLoading = false;
    emit(MyTaskScreenInitialState());
  }

  Future<void> _mapUpdateTaskEventToState(
    StaffTaskScreenUpdateTaskDoneEvent event,
    Emitter<TaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    Map<String, dynamic> params = {
      "type": event.taskId.toString(),
      "name": event.name.toString(),
      "status": event.status.toString(),
      "noti": event.noti.toString(),
      "des": event.des.toString(),
      "priority": event.priority.toString(),
      "customer": event.status == '1' || event.status == '2'
          ? null
          : App.instance.userApp!.id.toString(),
      "user_id": event.status == '1' || event.status == '2'
          ? null
          : App.instance.userApp!.id.toString(),
      "time_star": DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(DateTime.parse(event.timeStart.toString())),
    };

    var url = AppConfig.instance.apiUri(
      ApiEndpoints.taskEditDone(event.taskId.toString()),
    );
    var body = json.encode(params);
    var res = await http.post(
      url,
      body: body,
      headers: {'Content-type': 'application/json'},
    );
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      if (l["code"] == 1) {
        emit(BookingUpdateSuccessState());
      }
      emit(BookingUpdateSuccessState());
    } else {
      emit(BookingUpdateErrorState());
    }
    isLoading = false;
    emit(MyTaskScreenInitialState());
  }

  Future<void> _mapUpdateTaskEventDayToState(
    StaffTaskScreenUpdateTaskDayDoneEvent event,
    Emitter<TaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());

    Map<String, dynamic> params = {
      "name": event.name.toString(),
      "status": event.status.toString(),
      "noti": event.noti.toString(),
      "des": event.des.toString(),
      "priority": event.priority.toString(),
      "customer": event.status == '1' || event.status == '2'
          ? null
          : App.instance.userApp!.id.toString(),
      "user_id": event.status == '1' || event.status == '2'
          ? null
          : App.instance.userApp!.id.toString(),
      "time_star": DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(DateTime.parse(event.timeStart.toString())),
    };
    var url = AppConfig.instance.apiUri(
      ApiEndpoints.taskEdit(event.taskId.toString()),
    );
    var body = json.encode(params);
    var res = await http.post(
      url,
      body: body,
      headers: {'Content-type': 'application/json'},
    );
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      if (l["code"] == 1) {
        emit(BookingUpdateTodaySuccessState());
      }
      emit(BookingUpdateTodaySuccessState());
    } else {
      emit(BookingUpdateTodayErrorState());
    }
    isLoading = false;
    emit(MyTaskScreenInitialState());
  }

  FutureOr<void> _mapGetTaskDoneEventToState(
    StaffTaskScreenGetTaskDoneEvent event,
    Emitter<TaskScreenState> emit,
  ) async {}

  FutureOr<void> _mapBookingDeleteTaskEventToState(
    BookingDeleteTaskEvent event,
    Emitter<TaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.taskDelete, {
      'txt-uid': event.taskId.toString(),
      'des': event.des,
    });
    var res1 = await http.post(url);
    if (res1.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res1.body));
      if (l['status'] == 1) {
        emit(BookingDeleteSuccessState());
      } else {
        emit(BookingDeleteErrorState());
      }
    }
    emit(MyTaskScreenInitialState());
    isLoading = false;
  }

  FutureOr<void> _mapBookingDeleteTaskToDayEventToState(
    BookingDeleteTaskToDayEvent event,
    Emitter<TaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.taskDelete, {
      'txt-uid': event.taskId.toString(),
      'des': event.des,
    });
    var res1 = await http.post(url);
    if (res1.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res1.body));
      if (l['status'] == 1) {
        emit(BookingDeleteTodaySuccessState());
      } else {
        emit(BookingDeleteTodayErrorState());
      }
    }
    emit(MyTaskScreenInitialState());
    isLoading = false;
  }
}
