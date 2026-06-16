import 'package:socbay/data/model/retail_order_model.dart';

abstract class RetailOrderState {
  const RetailOrderState();
}

class RetailOrderInitial extends RetailOrderState {}

class RetailOrderLoading extends RetailOrderState {}

class RetailOrderLoadSuccess extends RetailOrderState {
  final List<RetailOrder> orders;
  final bool hasReachedMax;
  final int page;
  final String search;
  final bool isFetchingMore;

  const RetailOrderLoadSuccess({
    required this.orders,
    required this.hasReachedMax,
    required this.page,
    required this.search,
    this.isFetchingMore = false,
  });

  RetailOrderLoadSuccess copyWith({
    List<RetailOrder>? orders,
    bool? hasReachedMax,
    int? page,
    String? search,
    bool? isFetchingMore,
  }) {
    return RetailOrderLoadSuccess(
      orders: orders ?? this.orders,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      search: search ?? this.search,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class RetailOrderLoadFailure extends RetailOrderState {
  final String error;
  const RetailOrderLoadFailure({required this.error});
}
