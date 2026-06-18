abstract class HistoryScreenEvent {
  const HistoryScreenEvent();
}

class HistoryScreenStartedEvent extends HistoryScreenEvent {}

class HistoryScreenTabPressEvent extends HistoryScreenEvent {
  final int index;
  HistoryScreenTabPressEvent(this.index);
}

class BookingDeleteTaskEvent extends HistoryScreenEvent {
  final int taskId;
  final String name;
  final String des;
  BookingDeleteTaskEvent(this.taskId, this.name, this.des);
}
