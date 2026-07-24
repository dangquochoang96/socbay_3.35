abstract class NotificationScreenEvent {
  const NotificationScreenEvent();
}

class NotificationScreenStartedEvent extends NotificationScreenEvent {}

class NotificationScreenLoadMoreEvent extends NotificationScreenEvent {}
