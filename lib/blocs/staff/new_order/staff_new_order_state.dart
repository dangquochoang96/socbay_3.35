import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/order_payment_model.dart';

abstract class StaffNewOrderState {
  const StaffNewOrderState();
}

class StaffNewOrderInitialState extends StaffNewOrderState {}

class StaffNewOrderGetListProductsSuccessState extends StaffNewOrderState {}

class StaffNewOrderGetListProductsAllSuccessState extends StaffNewOrderState {}

class StaffNewOrderGetListProductsFailState extends StaffNewOrderState {}

class StaffCreateOrderCoresSuccessState extends StaffNewOrderState {
  final OrderDetailModel? order;
  final OrderPaymentModel? orderPayment;

  const StaffCreateOrderCoresSuccessState({this.order, this.orderPayment});
}

class StaffCreateOrderCoresFailState extends StaffNewOrderState {
  final String message;
  StaffCreateOrderCoresFailState(this.message);
}

class ServiceScreenUploadImageSuccessState extends StaffNewOrderState {
  final List<String> paths;

  const ServiceScreenUploadImageSuccessState(this.paths);
}

class ServiceScreenUploadImageFailedState extends StaffNewOrderState {
  final String message;

  const ServiceScreenUploadImageFailedState(this.message);
}

class StaffNewOrderUploadPaymentProofSuccessState
    extends StaffNewOrderState {}

class StaffNewOrderUploadPaymentProofFailState extends StaffNewOrderState {
  final String message;

  const StaffNewOrderUploadPaymentProofFailState(this.message);
}

class OrderHadCreated extends StaffNewOrderState {}
