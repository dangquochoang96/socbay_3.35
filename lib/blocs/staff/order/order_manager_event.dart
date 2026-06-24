abstract class OrderManagerEvent {
  const OrderManagerEvent();
}

class OrderManagerListEvent extends OrderManagerEvent {
  final bool isRefresh;
  final String start;
  final String end;
  final int page;
  const OrderManagerListEvent({
    this.isRefresh = false,
    this.start = '',
    this.end = '',
    this.page = 1,
  });
}
