import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/retail_order_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/auth_http.dart' as http;

import 'retail_order_event.dart';
import 'retail_order_state.dart';

class RetailOrderBloc extends Bloc<RetailOrderEvent, RetailOrderState> {
  final ApiRepository apiRepository;

  RetailOrderBloc({required this.apiRepository}) : super(RetailOrderInitial()) {
    on<FetchRetailOrdersEvent>(_onFetchRetailOrders);
    on<CreateRetailOrderSubmitEvent>(_onCreateRetailOrderSubmit);
  }

  Future<void> _onFetchRetailOrders(
    FetchRetailOrdersEvent event,
    Emitter<RetailOrderState> emit,
  ) async {
    final currentState = state;

    // Check if we need to load the first page (refresh or query change)
    final bool isRefresh =
        event.isRefresh ||
        currentState is! RetailOrderLoadSuccess ||
        event.search != (currentState).search;

    int nextPage = 0;
    List<RetailOrder> currentOrders = [];

    if (!isRefresh) {
      if (currentState.hasReachedMax || currentState.isFetchingMore) {
        return; // Already reached the end or currently loading
      }
      nextPage = currentState.page + 1;
      currentOrders = currentState.orders;

      // Emit fetching more state to show the bottom spinner
      emit(currentState.copyWith(isFetchingMore: true));
    } else {
      emit(RetailOrderLoading());
    }

    try {
      final Map<String, dynamic> queryParams = {'page': nextPage.toString()};
      if (event.search.trim().isNotEmpty) {
        queryParams['search'] = event.search.trim();
      }

      var url = AppConfig.instance.apiUri(
        ApiEndpoints.retailOrder,
        queryParams,
      );
      LoggerUtil.log('Fetching retail orders from URL: $url');

      var response = await http.get(url);
      if (response.statusCode == HttpStatus.ok) {
        var jsonResponse = Map<String, dynamic>.from(
          json.decode(response.body),
        );
        if (jsonResponse['code'] == 1) {
          var newOrders = listRetailOrderFromJson(jsonResponse['data']);
          final bool hasReachedMax = newOrders.length < 20;

          emit(
            RetailOrderLoadSuccess(
              orders: isRefresh
                  ? newOrders
                  : (List<RetailOrder>.from(currentOrders)..addAll(newOrders)),
              hasReachedMax: hasReachedMax,
              page: nextPage,
              search: event.search,
              isFetchingMore: false,
            ),
          );
        } else {
          emit(
            RetailOrderLoadFailure(
              error:
                  jsonResponse['message'] ?? 'Đã xảy ra lỗi khi tải đơn hàng',
            ),
          );
        }
      } else {
        emit(
          RetailOrderLoadFailure(error: 'Lỗi máy chủ: ${response.statusCode}'),
        );
      }
    } catch (e) {
      LoggerUtil.log('Exception in RetailOrderBloc: ${e.toString()}');
      emit(RetailOrderLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onCreateRetailOrderSubmit(
    CreateRetailOrderSubmitEvent event,
    Emitter<RetailOrderState> emit,
  ) async {
    emit(CreateRetailOrderLoading());
    try {
      final url = AppConfig.instance.apiUri(ApiEndpoints.createRetailOrder);
      final response = await http.post(url, body: event.body);

      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        final resJson = jsonDecode(response.body);
        if (resJson['code'] == 1) {
          emit(CreateRetailOrderSuccess());
        } else {
          emit(CreateRetailOrderFailure(
            error: resJson['message'] ?? "Có lỗi xảy ra, vui lòng thử lại",
          ));
        }
      } else {
        emit(CreateRetailOrderFailure(
          error: "Lỗi máy chủ: ${response.statusCode}",
        ));
      }
    } catch (e) {
      emit(CreateRetailOrderFailure(error: "Đã xảy ra lỗi: $e"));
    }
  }
}
