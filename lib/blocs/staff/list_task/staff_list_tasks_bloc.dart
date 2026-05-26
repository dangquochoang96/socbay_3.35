import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/staff/list_task/staff_list_tasks_event.dart';
import 'package:socbay/blocs/staff/list_task/staff_list_tasks_state.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';

class StaffListTasksBloc
    extends Bloc<StaffListTasksEvent, StaffListTasksState> {
  final ApiRepository apiRepository;
  final Map<String, dynamic> args;
  List<TaskModel> listTaskModel = [];
  bool isLoading = true;
  int page = 1;
  int total = 1;

  bool isHasMore() => listTaskModel.length < total;
  StaffListTasksBloc({required this.apiRepository, required this.args})
    : super(StaffListTasksInitState()) {
    on<StaffListTasksCurrentDayEvent>(_mapGetCurrentTaskByDayEventToState);
  }
  FutureOr<void> _mapGetCurrentTaskByDayEventToState(
    StaffListTasksCurrentDayEvent event,
    Emitter<StaffListTasksState> emit,
  ) {
    try {
      emit(StaffListTasksInitState());
    } catch (ex) {
      LoggerUtil.log(jsonEncode(ex));
    }
  }
}
