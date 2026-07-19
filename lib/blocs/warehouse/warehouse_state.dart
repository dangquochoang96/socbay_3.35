import 'package:socbay/data/model/warehouse_model.dart';
import 'package:socbay/data/model/user_model.dart';

abstract class WarehouseState {
  const WarehouseState();
}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoading extends WarehouseState {}

class WarehouseLoadSuccess extends WarehouseState {
  final ListWarehouse warehouseData;
  final Statistic? statistic;

  const WarehouseLoadSuccess({
    required this.warehouseData,
    this.statistic,
  });
}

class WarehouseLoadFailure extends WarehouseState {
  final String error;

  const WarehouseLoadFailure({required this.error});
}

// User suggestions states
class UserSearchLoading extends WarehouseState {}

class UserSearchSuccess extends WarehouseState {
  final List<UserModel> users;

  const UserSearchSuccess({required this.users});
}

class UserSearchFailure extends WarehouseState {
  final String error;

  const UserSearchFailure({required this.error});
}

// Export states
class ExportWarehouseLoading extends WarehouseState {}

class ExportWarehouseSuccess extends WarehouseState {}

class ExportWarehouseFailure extends WarehouseState {
  final String error;

  const ExportWarehouseFailure({required this.error});
}

// Refund states
class RefundWarehouseLoading extends WarehouseState {}

class RefundWarehouseSuccess extends WarehouseState {}

class RefundWarehouseFailure extends WarehouseState {
  final String error;

  const RefundWarehouseFailure({required this.error});
}

// Return states
class ReturnWarehouseLoading extends WarehouseState {}

class ReturnWarehouseSuccess extends WarehouseState {
  final String message;

  const ReturnWarehouseSuccess({this.message = 'Hoàn kho thành công !!!'});
}

class ReturnWarehouseFailure extends WarehouseState {
  final String error;

  const ReturnWarehouseFailure({required this.error});
}

// Fetch Destination Warehouse states
class DestinationWarehouseLoading extends WarehouseState {}

class DestinationWarehouseSuccess extends WarehouseState {
  final List<DestinationWarehouse> warehouses;

  const DestinationWarehouseSuccess({required this.warehouses});
}

class DestinationWarehouseFailure extends WarehouseState {
  final String error;

  const DestinationWarehouseFailure({required this.error});
}


