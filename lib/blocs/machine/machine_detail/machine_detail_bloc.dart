import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/machine/machine_detail/machine_detail_event.dart';
import 'package:socbay/blocs/machine/machine_detail/machine_detail_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/order_rent_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:http/http.dart' as http;

class MachineDetailScreenBloc
    extends Bloc<MachineDetailScreenEvent, MachineDetailScreenState> {
  MachineDetailScreenBloc({
    required this.args,
    required this.apiRepository,
  }) : super(MachineDetailScreenInitialState()) {
    order = args['id_oder'];
    on<MachineDetailScreenStartedEvent>(_mapStartedEventToState);
  }
  final Map<String, dynamic> args;
  late OrderModel order;
  final ApiRepository apiRepository;
  bool isLoading = false;

  List<OrderDetailModel> ordersModel = [];
  List<OrderRent> orderRentModel = [];
  FutureOr<void> _mapStartedEventToState(MachineDetailScreenStartedEvent event,
      Emitter<MachineDetailScreenState> emit) async {
    isLoading = true;
    order = args['id_oder'];
    emit(MachineDetailScreenInitialState());
    var url = Uri.http(AppConfig.instance.values.apiUrl,
        "/api/user/history/${order.id}", {'phone': args['id_user']});
    var res1 = await http.get(url);
    if (res1.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res1.body));
      var m = Map<String, dynamic>.from(l["data"]);
      ordersModel = List<OrderDetailModel>.from(
          m["history"].map((model) => OrderDetailModel.fromJson(model)));
      ordersModel.sort((a, b) => a.id!.compareTo(b.id!));
      ordersModel = ordersModel.reversed.toList();

      orderRentModel = List<OrderRent>.from(
          m['product']['order_rent'].map((model) => OrderRent.fromJson(model)));
    }
    isLoading = false;
    emit(MachineDetailScreenInitialState());
    emit(MachineDetailScreenLoadedState(
        ordersModel: ordersModel, orderRentModel: orderRentModel));
  }
}
