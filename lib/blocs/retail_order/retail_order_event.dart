abstract class RetailOrderEvent {
  const RetailOrderEvent();
}

class FetchRetailOrdersEvent extends RetailOrderEvent {
  final bool isRefresh;
  final String search;
  const FetchRetailOrdersEvent({this.isRefresh = false, this.search = ""});
}
