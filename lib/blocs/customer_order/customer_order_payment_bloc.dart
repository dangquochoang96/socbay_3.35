import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'customer_order_payment_event.dart';
import 'customer_order_payment_state.dart';

class CustomerOrderPaymentBloc
    extends Bloc<CustomerOrderPaymentEvent, CustomerOrderPaymentState> {
  final ApiRepository apiRepository;

  Map<String, dynamic> statistics = {
    "total_orders": 0,
    "total_orders_price": 0,
    "total_paid_amount": 0,
    "total_debt": 0
  };
  List<dynamic> allOrders = [];
  int currentPage = 1;
  int lastPage = 1;
  int filterStatus = -1; // -1: All, 1: Paid, 0: Unpaid
  bool isLoading = false;

  CustomerOrderPaymentBloc({required this.apiRepository})
    : super(CustomerOrderPaymentInitial()) {
    on<CustomerOrderPaymentStartEvent>(_onStart);
    on<CustomerOrderPaymentLoadMoreEvent>(_onLoadMore);
    on<CustomerOrderPaymentFilterChangedEvent>(_onFilterChanged);
  }

  Future<void> _onStart(
    CustomerOrderPaymentStartEvent event,
    Emitter<CustomerOrderPaymentState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(CustomerOrderPaymentLoading());
    }
    currentPage = 1;
    allOrders.clear();
    isLoading = true;
    try {
      final success = await _fetchData();
      if (success) {
        emit(
          CustomerOrderPaymentLoaded(
            statistics: statistics,
            orders: List.from(allOrders),
            currentPage: currentPage,
            lastPage: lastPage,
            filterStatus: filterStatus,
            hasMore: currentPage < lastPage,
          ),
        );
      } else {
        emit(
          CustomerOrderPaymentError(
            "Không thể tải danh sách đơn hàng thanh toán",
          ),
        );
      }
    } catch (e) {
      LoggerUtil.error(e.toString());
      emit(CustomerOrderPaymentError(e.toString()));
    } finally {
      isLoading = false;
    }
  }

  Future<void> _onLoadMore(
    CustomerOrderPaymentLoadMoreEvent event,
    Emitter<CustomerOrderPaymentState> emit,
  ) async {
    if (isLoading || currentPage >= lastPage) return;
    isLoading = true;
    currentPage++;
    try {
      final success = await _fetchData();
      if (success) {
        emit(
          CustomerOrderPaymentLoaded(
            statistics: statistics,
            orders: List.from(allOrders),
            currentPage: currentPage,
            lastPage: lastPage,
            filterStatus: filterStatus,
            hasMore: currentPage < lastPage,
          ),
        );
      }
    } catch (e) {
      LoggerUtil.error(e.toString());
    } finally {
      isLoading = false;
    }
  }

  Future<void> _onFilterChanged(
    CustomerOrderPaymentFilterChangedEvent event,
    Emitter<CustomerOrderPaymentState> emit,
  ) async {
    filterStatus = event.filterStatus;
    if (state is CustomerOrderPaymentLoaded) {
      emit(
        (state as CustomerOrderPaymentLoaded).copyWith(
          filterStatus: filterStatus,
        ),
      );
    }
  }

  Future<bool> _fetchData() async {
    final url = AppConfig.instance.apiUri(ApiEndpoints.listOrderPayments, {
      'page': currentPage.toString(),
    });
    final response = await http.get(url);
    if (response.statusCode == HttpStatus.ok) {
      final body = json.decode(response.body);
      if (body['code'] == 200 && body['data'] != null) {
        final data = body['data'];
        if (data['statistics'] != null) {
          statistics = Map<String, dynamic>.from(data['statistics']);
        }
        if (data['orders'] != null) {
          final ordersData = data['orders'];
          lastPage = ordersData['last_page'] ?? 1;
          currentPage = ordersData['current_page'] ?? 1;
          final List<dynamic> list = ordersData['data'] ?? [];
          allOrders.addAll(list);
        }
        return true;
      }
    }
    return false;
  }
}
