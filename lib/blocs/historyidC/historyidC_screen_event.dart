abstract class HistoryidCScreenEvent {
  const HistoryidCScreenEvent();
}

class HistoryidCScreenStartedEvent extends HistoryidCScreenEvent {}

class HistotyiDCScreenStartEvent extends HistoryidCScreenEvent {}

class HistoryidCScreenTabPressEvent extends HistoryidCScreenEvent {
  final int index;

  HistoryidCScreenTabPressEvent(this.index);
}

class BookingDeleteidCTaskEvent extends HistoryidCScreenEvent {
  final int taskId;
  final String name;
  final String des;
  BookingDeleteidCTaskEvent(this.taskId, this.name, this.des);
}
