abstract class CustomerOrderPaymentEvent {
  const CustomerOrderPaymentEvent();
}

class CustomerOrderPaymentStartEvent extends CustomerOrderPaymentEvent {
  final bool isRefresh;
  const CustomerOrderPaymentStartEvent({this.isRefresh = false});
}

class CustomerOrderPaymentLoadMoreEvent extends CustomerOrderPaymentEvent {}

class CustomerOrderPaymentFilterChangedEvent extends CustomerOrderPaymentEvent {
  final int filterStatus; // -1: All, 1: Paid, 0: Unpaid (or debt > 0)
  const CustomerOrderPaymentFilterChangedEvent(this.filterStatus);
}
