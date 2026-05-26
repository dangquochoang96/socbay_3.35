abstract class UserNewOrderState {
  const UserNewOrderState();
}

class UserNewOrderInitialState extends UserNewOrderState {}

class UserNewOrderGetListProductsSuccessState extends UserNewOrderState {}

class UserNewOrderGetListProductsAllSuccessState extends UserNewOrderState {}

class UserNewOrderGetListProductsFailState extends UserNewOrderState {}

class UserCreateOrderCoresSuccessState extends UserNewOrderState {}

class UserCreateOrderCoresFailState extends UserNewOrderState {
  final String message;
  UserCreateOrderCoresFailState(this.message);
}

class ServiceScreenUploadImageSuccessState extends UserNewOrderState {
  final List<String> paths;

  const ServiceScreenUploadImageSuccessState(this.paths);
}

class ServiceScreenUploadImageFailedState extends UserNewOrderState {
  final String message;

  const ServiceScreenUploadImageFailedState(this.message);
}

class OrderHadCreated extends UserNewOrderState {}
