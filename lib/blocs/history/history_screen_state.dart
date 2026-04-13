class HistoryScreenState {
  // const HistoryScreenState();
  final int initialIndex;
  HistoryScreenState({required this.initialIndex});

  HistoryScreenState copyWith({int? initialIndex}) {
    return HistoryScreenState(initialIndex: initialIndex ?? this.initialIndex);
  }
}

class HistoryScreenInitialState extends HistoryScreenState {
  HistoryScreenInitialState({required super.initialIndex});
}

class HistoryScreenChangeTabState extends HistoryScreenState {
  final int index;
  HistoryScreenChangeTabState(this.index, {required super.initialIndex});
}

class BookingInitialState {}

class MachineInitialState {}

class BookingDeleteSuccessState extends HistoryScreenState {
  BookingDeleteSuccessState({required super.initialIndex});
}

class BookingDeleteErrorState extends HistoryScreenState {
  BookingDeleteErrorState({required super.initialIndex});
}
