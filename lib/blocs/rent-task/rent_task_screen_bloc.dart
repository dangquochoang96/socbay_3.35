import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_event.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/db/db_manager.dart';
import 'package:socbay/utils/logger_util.dart';

import 'package:socbay/utils/auth_http.dart' as http;

class RentTaskScreenSaleBloc
    extends Bloc<RentTaskScreenEvent, RentTaskScreenState> {
  RentTaskScreenSaleBloc({required this.apiRepository})
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
    on<StaffTaskScreenAssignTechnicianEvent>(_mapAssignTechnicianEventToState);
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
    Emitter<RentTaskScreenState> emit,
  ) async {}

  FutureOr<void> _mapGetTaskEventToState(
    TaskScreenGetTaskEvent event,
    Emitter<RentTaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    var userAccount = await DbManager.instance.getAccounts();
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.rentTasksByCustomer(userAccount.first.id),
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
    Emitter<RentTaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.rentTasks, {
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
    Emitter<RentTaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.rentTasksPending, {
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
    Emitter<RentTaskScreenState> emit,
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
      "time_start": DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(DateTime.parse(event.timeStart.toString())),
    };
    if (event.address != null) {
      params["address"] = event.address;
    }

    var url = AppConfig.instance.apiUri(
      ApiEndpoints.rentTaskEdit(event.taskId.toString()),
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
      } else {
        emit(BookingUpdateErrorState());
      }
    } else {
      emit(BookingUpdateErrorState());
    }
    isLoading = false;
    emit(MyTaskScreenInitialState());
  }

  Future<void> _mapUpdateTaskEventDayToState(
    StaffTaskScreenUpdateTaskDayDoneEvent event,
    Emitter<RentTaskScreenState> emit,
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
      "time_start": DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(DateTime.parse(event.timeStart.toString())),
    };
    var url = AppConfig.instance.apiUri(
      ApiEndpoints.rentTaskEdit(event.taskId.toString()),
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
      } else {
        emit(BookingUpdateTodayErrorState());
      }
    } else {
      emit(BookingUpdateTodayErrorState());
    }
    isLoading = false;
    emit(MyTaskScreenInitialState());
  }

  FutureOr<void> _mapGetTaskDoneEventToState(
    StaffTaskScreenGetTaskDoneEvent event,
    Emitter<RentTaskScreenState> emit,
  ) async {}

  FutureOr<void> _mapBookingDeleteTaskEventToState(
    BookingDeleteTaskEvent event,
    Emitter<RentTaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.rentTaskDelete, {
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
    Emitter<RentTaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.rentTaskDelete, {
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

  Future<void> _mapAssignTechnicianEventToState(
    StaffTaskScreenAssignTechnicianEvent event,
    Emitter<RentTaskScreenState> emit,
  ) async {
    isLoading = true;
    emit(MyTaskScreenInitialState());
    
    String timeStartFormatted = "";
    if (event.taskModel.timeStart != null) {
      try {
        timeStartFormatted = DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(event.taskModel.timeStart!));
      } catch (_) {
        timeStartFormatted = event.taskModel.timeStart!;
      }
    }

    Map<String, dynamic> params = {
      "time_start": timeStartFormatted,
      "time_end": event.taskModel.timeEnd ?? "",
      "type_task": event.taskModel.type ?? "1",
      "name": event.taskModel.name ?? "",
      "staff": event.staffId.toString(),
      "priority": event.taskModel.priority ?? "1",
      "status": "5",
      "des": event.taskModel.des ?? "",
      "user_create": event.taskModel.userCreate ?? App.instance.userApp!.id.toString(),
      "customer": event.taskModel.customer?.id ?? event.taskModel.userId,
      "images": event.taskModel.images ?? [],
    };

    var url = AppConfig.instance.apiUri(
      ApiEndpoints.rentTaskEdit(event.taskId.toString()),
    );
    var body = json.encode(params);
    try {
      var res = await http.post(
        url,
        body: body,
        headers: {'Content-type': 'application/json'},
      );
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        if (l["code"] == 1) {
          emit(BookingUpdateSuccessState());
        } else {
          emit(BookingUpdateErrorState());
        }
      } else {
        emit(BookingUpdateErrorState());
      }
    } catch (ex) {
      LoggerUtil.error(ex.toString());
      emit(BookingUpdateErrorState());
    }
    isLoading = false;
    emit(MyTaskScreenInitialState());
  }
}
