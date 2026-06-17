abstract class WarehouseEvent {
  const WarehouseEvent();
}

class FetchWarehouseDataEvent extends WarehouseEvent {
  final bool isRefresh;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const FetchWarehouseDataEvent({
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.isRefresh = false,
  });
}

class SearchCustomerEvent extends WarehouseEvent {
  final String query;

  const SearchCustomerEvent({required this.query});
}

class ExportWarehouseEvent extends WarehouseEvent {
  final String userId;
  final Map<String, dynamic> params;

  const ExportWarehouseEvent({required this.userId, required this.params});
}

class RefundWarehouseEvent extends WarehouseEvent {
  final String historyId;

  const RefundWarehouseEvent({required this.historyId});
}
