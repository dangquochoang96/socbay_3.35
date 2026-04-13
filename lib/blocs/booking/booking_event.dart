abstract class BookingEvent {
  const BookingEvent();
}

class BookingStartedEvent extends BookingEvent {}

class BookingDeleteTaskEvent extends BookingEvent {
  final int id;
  final String name;
  final String des;

  const BookingDeleteTaskEvent(this.id, this.name, this.des);
}