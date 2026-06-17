import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/warehouse_model.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/utils/auth_http.dart' as http;

import 'warehouse_event.dart';
import 'warehouse_state.dart';

class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  WarehouseBloc() : super(WarehouseInitial()) {
    on<FetchWarehouseDataEvent>(_onFetchWarehouseData);
    on<SearchCustomerEvent>(_onSearchCustomer);
    on<ExportWarehouseEvent>(_onExportWarehouse);
    on<RefundWarehouseEvent>(_onRefundWarehouse);
  }

  Future<void> _onFetchWarehouseData(
    FetchWarehouseDataEvent event,
    Emitter<WarehouseState> emit,
  ) async {
    if (event.isRefresh) {
      emit(WarehouseLoading());
    } else if (state is! WarehouseLoadSuccess) {
      emit(WarehouseLoading());
    }

    try {
      // 1. Load warehouse list
      final warehouseUrl = AppConfig.instance.apiUri(
        ApiEndpoints.listWarehouseByUser(event.userId),
      );
      final warehouseResponse = await http.get(warehouseUrl);

      if (warehouseResponse.statusCode != HttpStatus.ok) {
        emit(
          WarehouseLoadFailure(
            error: 'Lỗi máy chủ: ${warehouseResponse.statusCode}',
          ),
        );
        return;
      }

      final warehouseJson = json.decode(warehouseResponse.body);
      if (warehouseJson['code'] != 1) {
        emit(
          WarehouseLoadFailure(
            error: warehouseJson['message'] ?? 'Lỗi khi tải dữ liệu kho',
          ),
        );
        return;
      }

      final warehouseData = ListWarehouse.fromJson(warehouseJson['data']);

      // 2. Load statistics
      Statistic? statistic;
      try {
        final fmt = DateFormat('yyyy-MM-dd');
        final statisticUrl = AppConfig.instance
            .apiUri(ApiEndpoints.statisticalWarehouseHistory, {
              'start': fmt.format(event.startDate),
              'end': fmt.format(event.endDate),
              'user_id': event.userId,
            });
        final statisticResponse = await http.get(statisticUrl);
        if (statisticResponse.statusCode == HttpStatus.ok) {
          final statisticJson = json.decode(statisticResponse.body);
          if (statisticJson['code'] == 1 && statisticJson['data'] != null) {
            statistic = Statistic.fromJson(statisticJson['data']);
          }
        }
      } catch (e) {
        // Fail silently for statistics so main list still shows
      }

      emit(
        WarehouseLoadSuccess(
          warehouseData: warehouseData,
          statistic: statistic,
        ),
      );
    } catch (e) {
      emit(WarehouseLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onSearchCustomer(
    SearchCustomerEvent event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(UserSearchLoading());
    try {
      final url = AppConfig.instance.apiUri(ApiEndpoints.userSearch, {
        'query': event.query,
      });
      final response = await http.get(url);

      if (response.statusCode == HttpStatus.ok) {
        final jsonRes = json.decode(response.body);
        if (jsonRes['code'] == 1 && jsonRes['data'] != null) {
          final List<dynamic> userData = jsonRes['data'];
          final users = userData.map((u) => UserProfile.fromJson(u)).toList();
          emit(UserSearchSuccess(users: users));
        } else {
          emit(
            UserSearchFailure(
              error: jsonRes['message'] ?? 'Lỗi khi tìm kiếm khách hàng',
            ),
          );
        }
      } else {
        emit(UserSearchFailure(error: 'Lỗi máy chủ: ${response.statusCode}'));
      }
    } catch (e) {
      emit(UserSearchFailure(error: e.toString()));
    }
  }

  Future<void> _onExportWarehouse(
    ExportWarehouseEvent event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(ExportWarehouseLoading());
    try {
      final url = AppConfig.instance.apiUri(
        ApiEndpoints.exportWarehouse(event.userId),
      );
      final response = await http.post(
        url,
        body: event.params,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        final jsonRes = json.decode(response.body);
        if (jsonRes['code'] == 1) {
          emit(ExportWarehouseSuccess());
        } else {
          emit(
            ExportWarehouseFailure(
              error: jsonRes['message'] ?? 'Lỗi khi xuất kho',
            ),
          );
        }
      } else {
        emit(
          ExportWarehouseFailure(error: 'Lỗi máy chủ: ${response.statusCode}'),
        );
      }
    } catch (e) {
      emit(ExportWarehouseFailure(error: e.toString()));
    }
  }

  Future<void> _onRefundWarehouse(
    RefundWarehouseEvent event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(RefundWarehouseLoading());
    try {
      final url = AppConfig.instance.apiUri(
        ApiEndpoints.refundWarehouse(event.historyId),
      );
      final response = await http.post(url);

      if (response.statusCode == HttpStatus.ok) {
        final jsonRes = json.decode(response.body);
        if (jsonRes['code'] == 1) {
          emit(RefundWarehouseSuccess());
        } else {
          emit(
            RefundWarehouseFailure(
              error: jsonRes['message'] ?? 'Lỗi khi hoàn tác',
            ),
          );
        }
      } else {
        emit(
          RefundWarehouseFailure(error: 'Lỗi máy chủ: ${response.statusCode}'),
        );
      }
    } catch (e) {
      emit(RefundWarehouseFailure(error: e.toString()));
    }
  }
}
