abstract class HistoryidCScreenState {
  const HistoryidCScreenState();
}

class HistoryidCScreenInitialState extends HistoryidCScreenState {}
class HistoryiDCScreenInitialState extends HistoryidCScreenState {}
class HistoryidCScreenChangeTabState extends HistoryidCScreenState {
  final int index;

  const HistoryidCScreenChangeTabState(this.index);

}

class BookingidCInitialState{}
class MachineidCInitialState{}
class BookingDeleteidCSuccessState extends HistoryidCScreenState{}
class BookingDeleteidCErrorState extends HistoryidCScreenState{}