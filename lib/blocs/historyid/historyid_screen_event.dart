abstract class HistoryidScreenEvent {
  const HistoryidScreenEvent();
}

class HistoryidScreenStartedEvent extends HistoryidScreenEvent {}

class HistoryidScreenTabPressEvent extends HistoryidScreenEvent {
  final int index;

  HistoryidScreenTabPressEvent(this.index);
}

class BookingDeleteidTaskEvent extends HistoryidScreenEvent {
  final int taskId;
  final String name;
  final String des;
  BookingDeleteidTaskEvent(this.taskId, this.name, this.des);
}
