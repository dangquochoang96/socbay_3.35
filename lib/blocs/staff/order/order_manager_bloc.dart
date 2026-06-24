import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/staff/order/order_manager_event.dart';
import 'package:socbay/blocs/staff/order/order_manager_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/staff_order_detail_model.dart';
import 'package:socbay/data/model/staff_sales_income_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;

class OrderManagerBloc extends Bloc<OrderManagerEvent, OrderManagerState> {
  OrderManagerBloc({required this.apiRepository})
    : super(OrderManagerInitState()) {
    on<OrderManagerListEvent>(_mapGetListOrderManagerEventToState);
  }
  final ApiRepository apiRepository;
  bool isLoading = true;
  bool isLoadMoreLoading = false;
  int currentPage = 1;
  int lastPage = 1;
  List<OrderDetailModel>? lstOrder;
  int totalOrderAll = 0;
  double totalPriceAll = 0;
  double totalChietKhauAll = 0;
  double totalTruTichDiem = 0;
  int totalDonThayLoi = 0;
  int totalDonVeSinh = 0;
  int totalDonLapMay = 0;
  List<StaffSalesIncomeModel> staffSalesIncomes = [];
  List<StaffOrderDetailModel> staffLstOrders = [];
  FutureOr<void> _mapGetListOrderManagerEventToState(
    OrderManagerListEvent event,
    Emitter<OrderManagerState> emit,
  ) async {
    try {
      if (event.page == 1) {
        isLoading = true;
      } else {
        isLoadMoreLoading = true;
      }
      emit(OrderManagerInitState());

      var url = AppConfig.instance.apiUri(
        ApiEndpoints.orderListStaff(App.instance.userApp?.id),
        {
          'start': event.start,
          'end': event.end,
          'page': event.page.toString(),
        },
      );
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));

        if (event.page == 1) {
          totalPriceAll = 0;
          totalChietKhauAll = 0;
          totalTruTichDiem = 0;
          totalOrderAll = 0;
          totalDonThayLoi = 0;
          totalDonVeSinh = 0;
          totalDonLapMay = 0;
          staffLstOrders.clear();

          staffSalesIncomes = List<StaffSalesIncomeModel>.from(
            l["data"].map((model) => StaffSalesIncomeModel.fromJson(model)),
          );
          for (var e in staffSalesIncomes) {
            if (e.status == "2") {
              totalPriceAll = totalPriceAll + double.parse(e.totalPrice ?? "0");
              totalChietKhauAll =
                  totalChietKhauAll + double.parse(e.totalChietKhau ?? "0");
              totalTruTichDiem =
                  totalTruTichDiem + int.parse(e.totalTruTichDiem ?? "0");
            }
            totalOrderAll = totalOrderAll + int.parse(e.totalOrder ?? "0");
          }
          totalPriceAll =
              totalPriceAll - totalTruTichDiem * 1000 - totalChietKhauAll;

          for (var element in staffSalesIncomes) {
            if (element.status == "0") {
              totalDonLapMay = int.parse(element.totalOrder ?? "0");
            }
            if (element.status == "1") {
              totalDonVeSinh = int.parse(element.totalOrder ?? "0");
            }
            if (element.status == "2") {
              totalDonThayLoi = int.parse(element.totalOrder ?? "0");
            }
          }
        }

        var lstOrdersData = l["lstOrders"];
        currentPage = lstOrdersData["current_page"] ?? 1;
        lastPage = lstOrdersData["last_page"] ?? 1;

        var newOrders = List<StaffOrderDetailModel>.from(
          lstOrdersData["data"].map((model) => StaffOrderDetailModel.fromJson(model)),
        );
        
        if (event.page == 1) {
          staffLstOrders = newOrders;
        } else {
          staffLstOrders.addAll(newOrders);
        }
      }
    } catch (e) {
      print("Error loading staff orders: $e");
    } finally {
      isLoading = false;
      isLoadMoreLoading = false;
      emit(OrderManagerInitState());
    }
  }
}
