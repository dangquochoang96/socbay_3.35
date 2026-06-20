import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/booking/booking_event.dart';
import 'package:socbay/blocs/booking/booking_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/utils/logger_util.dart';
import '../../data/model/task_model.dart';
import '../../data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final ApiRepository apiRepository;
  bool isLoading = false;
  List<TaskModel> listTaskModel = [];

  BookingBloc({required this.apiRepository}) : super(BookingInitialState()) {
    on<BookingStartedEvent>(_mapBookingStartedEventToState);
    on<BookingDeleteTaskEvent>(_mapBookingDeleteTaskEventToState);
  }

  FutureOr<void> _mapBookingStartedEventToState(
    BookingStartedEvent event,
    Emitter<BookingState> emit,
  ) async {
    isLoading = true;
    emit(BookingInitialState());
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.tasksByCustomer(App.instance.userApp?.id),
        {'page': "1"},
      );
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        listTaskModel = List<TaskModel>.from(
          l["data"].map((model) => TaskModel.fromJson(model)),
        );
      }
    } catch (exception) {
      LoggerUtil.log(exception.toString());
    }
    // final result = await apiRepository.getListTask();
    // if (result.status == HttpStatus.ok && result.data != null) {
    //   listTaskModel = result.data!;
    // }
    isLoading = false;
    emit(BookingInitialState());
  }

  Future<void> _mapBookingDeleteTaskEventToState(
    BookingDeleteTaskEvent event,
    Emitter<BookingState> emit,
  ) async {
    isLoading = true;
    emit(BookingInitialState());
    var url = AppConfig.instance.apiUri(ApiEndpoints.taskDelete, {
      'txt-uid': event.id.toString(),
      'des': event.des,
    });
    var res1 = await http.post(url);
    if (res1.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res1.body));
      if (l['status'] == 1) {
        add(BookingStartedEvent());
      }
    }
    // final result =
    //     await apiRepository.deleteTask(event.id, event.name, event.des);
    // if (result.status == HttpStatus.ok && result.data != null) {
    //   add(BookingStartedEvent());
    // }
    isLoading = false;
    emit(BookingInitialState());
  }
}
