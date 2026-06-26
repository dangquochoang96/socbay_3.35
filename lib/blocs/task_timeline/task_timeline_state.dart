import 'package:equatable/equatable.dart';
import 'package:socbay/data/model/technician_timeline_model.dart';

abstract class TaskTimelineState extends Equatable {
  const TaskTimelineState();

  @override
  List<Object?> get props => [];
}

class TaskTimelineInitial extends TaskTimelineState {}

class TaskTimelineLoading extends TaskTimelineState {}

class TaskTimelineLoaded extends TaskTimelineState {
  final List<TechnicianTimelineModel> technicians;
  final DateTime date;

  const TaskTimelineLoaded({required this.technicians, required this.date});

  @override
  List<Object?> get props => [technicians, date];
}

class TaskTimelineError extends TaskTimelineState {
  final String message;

  const TaskTimelineError({required this.message});

  @override
  List<Object?> get props => [message];
}
