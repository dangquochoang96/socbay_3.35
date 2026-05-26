import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/staff/order/order_manager_event.dart';
import 'package:socbay/blocs/staff/order/order_manager_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/staff_order_detail_model.dart';
import 'package:socbay/data/model/staff_sales_income_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:http/http.dart' as http;

class OrderManagerBlocBySale
    extends Bloc<OrderManagerEvent, OrderManagerState> {
  OrderManagerBlocBySale({required this.apiRepository})
    : super(OrderManagerInitState()) {
    on<OrderManagerListEvent>(_mapGetListOrderManagerEventToState);
  }
  final ApiRepository apiRepository;
  bool isLoading = true;
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
    isLoading = true;
    final url = AppConfig.instance.apiUri(
      ApiEndpoints.orderListBySale(App.instance.userApp?.id),
      {'start': event.start, 'end': event.end},
    );
    print(url);
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      totalPriceAll = 0;
      totalChietKhauAll = 0;
      totalTruTichDiem = 0;
      totalOrderAll = 0;
      totalDonThayLoi = 0;
      totalDonVeSinh = 0;
      totalDonLapMay = 0;
      staffLstOrders.clear();
      var l = Map<String, dynamic>.from(json.decode(res.body));
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
      staffLstOrders = List<StaffOrderDetailModel>.from(
        l["lstOrders"].map((model) => StaffOrderDetailModel.fromJson(model)),
      );
      staffLstOrders.reversed;
      for (var element in staffSalesIncomes) {
        if (element.status == "0")
          totalDonLapMay = int.parse(element.totalOrder ?? "0");
        if (element.status == "1")
          totalDonVeSinh = int.parse(element.totalOrder ?? "0");
        if (element.status == "2")
          totalDonThayLoi = int.parse(element.totalOrder ?? "0");
      }
    }
    isLoading = false;
    emit(OrderManagerInitState());
  }
}
