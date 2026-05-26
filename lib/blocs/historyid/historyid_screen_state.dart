abstract class HistoryidScreenState {
  const HistoryidScreenState();
}

class HistoryidScreenInitialState extends HistoryidScreenState {}

class HistoryidScreenChangeTabState extends HistoryidScreenState {
  final int index;

  const HistoryidScreenChangeTabState(this.index);
}

class BookingidInitialState {}

class MachineidInitialState {}

class BookingDeleteidSuccessState extends HistoryidScreenState {}

class BookingDeleteidErrorState extends HistoryidScreenState {}
