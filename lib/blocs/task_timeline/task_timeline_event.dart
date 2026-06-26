import 'package:equatable/equatable.dart';

abstract class TaskTimelineEvent extends Equatable {
  const TaskTimelineEvent();

  @override
  List<Object?> get props => [];
}

class FetchTaskTimeline extends TaskTimelineEvent {
  final DateTime date;
  final bool isRefresh;

  const FetchTaskTimeline({required this.date, this.isRefresh = false});

  @override
  List<Object?> get props => [date, isRefresh];
}
