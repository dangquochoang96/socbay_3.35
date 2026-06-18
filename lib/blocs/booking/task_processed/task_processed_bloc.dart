import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/booking/task_processed/task_processed_event.dart';
import 'package:socbay/blocs/booking/task_processed/task_processed_state.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/task_processed_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

class DetailTaskProcessedBloc
    extends Bloc<DetailTaskProcessedEvent, DetailTaskProcessedState> {
  final ApiRepository apiRepository;
  bool isLoading = false;
  Map<String, dynamic> args;
  TaskModel? taskModel;
  TaskProcessedModel? taskProcessedModel;
  int count = 0;
  double rating = 0;
  var des = "";
  DetailTaskProcessedBloc({required this.apiRepository, required this.args})
    : super(DetailTaskProcessedInitialState()) {
    on<DetailTaskProcessedStartEvent>(_startPage);
    on<FeedbackTaskProcessedEvent>(_createOrUpdateFeedbackTaskProcessed);
    //do something
  }
  FutureOr<void> _startPage(
    DetailTaskProcessedStartEvent event,
    Emitter<DetailTaskProcessedState> emit,
  ) async {
    isLoading = true;
    //emit(DetailTaskProcessedInitialState());
    count = 3;
    var result = await apiRepository.getTask(args['id']);
    if (result.status == HttpStatus.ok && result.data != null) {
      taskModel = result.data!;
      taskProcessedModel = TaskProcessedModel(
        id: taskModel!.id,
        staff: taskModel!.staff,
        createdAt: taskModel!.createdAt,
        //images:taskModel!.images,
      );
    }
    isLoading = false;
    emit(DetailTaskProcessedInitialState());
  }

  FutureOr<void> _createOrUpdateFeedbackTaskProcessed(
    FeedbackTaskProcessedEvent event,
    Emitter<DetailTaskProcessedState> emitter,
  ) async {
    //do something
    rating = event.rating;
    des = event.des;
    emitter(DetailTaskProcessedInitialState());
  }
}
