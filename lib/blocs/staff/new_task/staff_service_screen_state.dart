abstract class StaffServiceScreenState {
  const StaffServiceScreenState();
}

class StaffServiceScreenInitialState extends StaffServiceScreenState {}

class StaffServiceScreenChangeTypeServiceState extends StaffServiceScreenState {
  final String typeService;

  const StaffServiceScreenChangeTypeServiceState(this.typeService);
}

class StaffServiceScreenCreateTaskSuccessState extends StaffServiceScreenState {
  final int id;
  final bool isSearch;

  const StaffServiceScreenCreateTaskSuccessState(this.id, this.isSearch);
}

class StaffServiceScreenCreateTaskFailedState extends StaffServiceScreenState {
  final String message;

  const StaffServiceScreenCreateTaskFailedState(this.message);
}

class StaffServiceScreenUserAddressSuccessState extends StaffServiceScreenState {}

class StaffServiceScreenUserAddressFailedState extends StaffServiceScreenState {}

class StaffServiceScreenUploadImageSuccessState extends StaffServiceScreenState {
  final List<String> paths;

  const StaffServiceScreenUploadImageSuccessState(this.paths);
}

class StaffServiceScreenUploadImageFailedState extends StaffServiceScreenState {
  final String message;

  const StaffServiceScreenUploadImageFailedState(this.message);
}

class StaffServiceScreenUploadFileSuccessState extends StaffServiceScreenState {
  final String path;

  const StaffServiceScreenUploadFileSuccessState(this.path);
}

class StaffServiceScreenUploadFileFailedState extends StaffServiceScreenState {
  final String message;

  const StaffServiceScreenUploadFileFailedState(this.message);
}
class StaffServiceScreenCheckCustomerFailedState extends StaffServiceScreenState {
  final String message;

  const StaffServiceScreenCheckCustomerFailedState(this.message);
}
class StaffServiceScreenCheckCustomerSuccessState extends StaffServiceScreenState {
  final String message;

  const StaffServiceScreenCheckCustomerSuccessState(this.message);
}
class UserAddressScreenCreateAddressSuccessState
    extends StaffServiceScreenState {
  final String error;

  const UserAddressScreenCreateAddressSuccessState({this.error = ""});
}
class UserAddressScreenCreateAddressFailState
    extends StaffServiceScreenState {
  final String error;

  const UserAddressScreenCreateAddressFailState({this.error = ""});
}
