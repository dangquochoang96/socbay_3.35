import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/order_rent_model.dart';

abstract class MachineDetailScreenState{
  const MachineDetailScreenState();
}

class MachineDetailScreenInitialState extends MachineDetailScreenState{}

class MachineDetailScreenLoadedState extends MachineDetailScreenState {
  final List<OrderDetailModel> ordersModel;
  final List<OrderRent> orderRentModel;

  MachineDetailScreenLoadedState({required this.ordersModel, required this.orderRentModel});
}