abstract class RetailOrderEvent {
  const RetailOrderEvent();
}

class FetchRetailOrdersEvent extends RetailOrderEvent {
  final bool isRefresh;
  final String search;
  const FetchRetailOrdersEvent({this.isRefresh = false, this.search = ""});
}

class CreateRetailOrderSubmitEvent extends RetailOrderEvent {
  final Map<String, dynamic> body;
  const CreateRetailOrderSubmitEvent({required this.body});
}
