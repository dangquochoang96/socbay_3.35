abstract class GiftScreenState {
  const GiftScreenState();
}

class GiftScreenInitialState extends GiftScreenState {}

class GiftScreenChangeTabState extends GiftScreenState {
  final int index;

  const GiftScreenChangeTabState(this.index);
}
