

abstract class StaffServiceSaleScreenState{
  const StaffServiceSaleScreenState();
}

class StaffServiceScreenSaleInitialState extends StaffServiceSaleScreenState {}

class StaffServiceScreenSaleChangeTypeServiceState extends StaffServiceSaleScreenState {
  final String typeService;

  const StaffServiceScreenSaleChangeTypeServiceState(this.typeService);
}

class StaffServiceScreenSaleCreateTaskSuccessState extends StaffServiceSaleScreenState {
  final int id;
  final bool isSearch;

  const StaffServiceScreenSaleCreateTaskSuccessState(this.id, this.isSearch);
}

class StaffServiceScreenSaleCreateTaskFailedState extends StaffServiceSaleScreenState {
  final String message;

  const StaffServiceScreenSaleCreateTaskFailedState(this.message);
}


class StaffServiceScreenSaleUploadImageFailedState extends StaffServiceSaleScreenState {
  final String message;

  const StaffServiceScreenSaleUploadImageFailedState(this.message);
}


class StaffServiceScreenSaleUploadImageSuccessState extends StaffServiceSaleScreenState {
  final List<String> paths;

  const StaffServiceScreenSaleUploadImageSuccessState(this.paths);
}

class StaffServiceScreenSaleCheckCustomerSuccessState extends StaffServiceSaleScreenState {
  final String message;

  const StaffServiceScreenSaleCheckCustomerSuccessState(this.message);
}

class StaffServiceScreenSaleCheckCustomerFailedState extends StaffServiceSaleScreenState {
  final String message;

  const StaffServiceScreenSaleCheckCustomerFailedState(this.message);
}
class UserAddressScreenSaleCreateAddressSuccessState
    extends StaffServiceSaleScreenState {
  final String error;

  const UserAddressScreenSaleCreateAddressSuccessState({this.error = ""});
}
class UserAddressScreenSaleCreateAddressFailState
    extends StaffServiceSaleScreenState {
  final String error;

  const UserAddressScreenSaleCreateAddressFailState({this.error = ""});
}


