import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/home/search_staff/search_staff_screen_event.dart';
import 'package:socbay/blocs/home/search_staff/search_staff_screen_state.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/user_profile.dart';

import '../../../data/repository/auth/api_repository.dart';

class SearchStaffScreenBloc
    extends Bloc<SearchStaffScreenEvent, SearchStaffScreenState> {
  SearchStaffScreenBloc({required this.apiRepository, required this.args})
      : super(SearchStaffScreenInitialState()) {
    on<SearchStaffScreenGetStaffEvent>(_mapStartedEventToState);
    on<SearchStaffScreenGetTaskEvent>(_mapTaskEventToState);
  }

  final ApiRepository apiRepository;
  Map<String, dynamic> args;
  bool isLoading = false;
  List<UserProfile> staffsInfo = [];
  TaskModel? taskModel;

  FutureOr<void> _mapStartedEventToState(SearchStaffScreenGetStaffEvent event,
      Emitter<SearchStaffScreenState> emit) async {
    isLoading = true;
    emit(SearchStaffScreenInitialState());

    final res = await apiRepository
        .getListStaffByDistance(event.staffByDistanceRequest);
    if (res.data != null && res.status == HttpStatus.ok) {
      staffsInfo = res.data!;
      add(SearchStaffScreenGetTaskEvent());
    }
    isLoading = false;
    emit(SearchStaffScreenInitialState());
  }

  FutureOr<void> _mapTaskEventToState(
      SearchStaffScreenGetTaskEvent event, Emitter<SearchStaffScreenState> emit) async {
    isLoading = true;
    emit(SearchStaffScreenInitialState());
    final result = await apiRepository.getTask(args['id']);
    if (result.status == HttpStatus.ok && result.data != null) {
      taskModel = result.data;
    }
    isLoading = false;
    emit(SearchStaffScreenInitialState());
  }
}
