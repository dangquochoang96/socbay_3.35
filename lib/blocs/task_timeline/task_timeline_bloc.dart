import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/task_timeline/task_timeline_event.dart';
import 'package:socbay/blocs/task_timeline/task_timeline_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/technician_timeline_model.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class TaskTimelineBloc extends Bloc<TaskTimelineEvent, TaskTimelineState> {
  TaskTimelineBloc() : super(TaskTimelineInitial()) {
    on<FetchTaskTimeline>(_onFetchTaskTimeline);
  }

  FutureOr<void> _onFetchTaskTimeline(
    FetchTaskTimeline event,
    Emitter<TaskTimelineState> emit,
  ) async {
    emit(TaskTimelineLoading());
    try {
      final dateStr = DateFormat("yyyy-MM-dd").format(event.date);
      // Gửi cả 3 tham số để tương thích hoàn toàn với API backend
      var url = AppConfig.instance.apiUri(ApiEndpoints.tasksTimeline, {
        'date': dateStr,
        'start': dateStr,
        'day': dateStr,
      });

      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var responseData = Map<String, dynamic>.from(json.decode(res.body));
        if (responseData["code"] == 1) {
          List<TechnicianTimelineModel> list = [];
          if (responseData["data"] != null) {
            list = List<TechnicianTimelineModel>.from(
              responseData["data"].map((model) => TechnicianTimelineModel.fromJson(model)),
            );
          }
          emit(TaskTimelineLoaded(technicians: list, date: event.date));
        } else {
          emit(TaskTimelineError(message: responseData["message"] ?? "Lấy dữ liệu timeline thất bại."));
        }
      } else {
        emit(const TaskTimelineError(message: "Không thể kết nối đến máy chủ."));
      }
    } catch (exception) {
      LoggerUtil.log(exception.toString());
      emit(TaskTimelineError(message: "Đã xảy ra lỗi: $exception"));
    }
  }
}
