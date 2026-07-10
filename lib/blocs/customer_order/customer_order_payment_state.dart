abstract class CustomerOrderPaymentState {}

class CustomerOrderPaymentInitial extends CustomerOrderPaymentState {}

class CustomerOrderPaymentLoading extends CustomerOrderPaymentState {}

class CustomerOrderPaymentLoaded extends CustomerOrderPaymentState {
  final Map<String, dynamic> statistics;
  final List<dynamic> orders;
  final int currentPage;
  final int lastPage;
  final int filterStatus; // -1: All, 1: Paid, 0: Unpaid
  final bool hasMore;

  CustomerOrderPaymentLoaded({
    required this.statistics,
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.filterStatus,
    required this.hasMore,
  });

  CustomerOrderPaymentLoaded copyWith({
    Map<String, dynamic>? statistics,
    List<dynamic>? orders,
    int? currentPage,
    int? lastPage,
    int? filterStatus,
    bool? hasMore,
  }) {
    return CustomerOrderPaymentLoaded(
      statistics: statistics ?? this.statistics,
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      filterStatus: filterStatus ?? this.filterStatus,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CustomerOrderPaymentError extends CustomerOrderPaymentState {
  final String message;
  CustomerOrderPaymentError(this.message);
}
