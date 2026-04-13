abstract class StaffNewOrderState {
  const StaffNewOrderState();
}

class StaffNewOrderInitialState extends StaffNewOrderState {}
class StaffNewOrderGetListProductsSuccessState extends StaffNewOrderState {}
class StaffNewOrderGetListProductsAllSuccessState extends StaffNewOrderState {}
class StaffNewOrderGetListProductsFailState extends StaffNewOrderState {}
class StaffCreateOrderCoresSuccessState extends StaffNewOrderState {
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
class OrderHadCreated extends StaffNewOrderState {}