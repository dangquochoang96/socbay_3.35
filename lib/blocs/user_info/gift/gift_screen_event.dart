abstract class GiftScreenEvent {
  const GiftScreenEvent();
}

class GiftScreenStartedEvent extends GiftScreenEvent {}

class GiftScreenTabPressEvent extends GiftScreenEvent {
  final int index;

  GiftScreenTabPressEvent(this.index);
}
