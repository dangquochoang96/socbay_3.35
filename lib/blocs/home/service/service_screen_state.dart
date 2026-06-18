abstract class ServiceScreenState {
  const ServiceScreenState();
}

class ServiceScreenInitialState extends ServiceScreenState {}

class ServiceScreenChangeTypeServiceState extends ServiceScreenState {
  final String typeService;

  const ServiceScreenChangeTypeServiceState(this.typeService);
}

class ServiceScreenCreateTaskSuccessState extends ServiceScreenState {
  final int id;
  final bool isSearch;

  const ServiceScreenCreateTaskSuccessState(this.id, this.isSearch);
}

class ServiceScreenCreateTaskFailedState extends ServiceScreenState {
  final String message;

  const ServiceScreenCreateTaskFailedState(this.message);
}

class ServiceScreenUserAddressSuccessState extends ServiceScreenState {}

class ServiceScreenUserAddressFailedState extends ServiceScreenState {}

class ServiceScreenUploadImageSuccessState extends ServiceScreenState {
  final List<String> paths;

  const ServiceScreenUploadImageSuccessState(this.paths);
}

class ServiceScreenUploadImageFailedState extends ServiceScreenState {
  final String message;

  const ServiceScreenUploadImageFailedState(this.message);
}

class ServiceScreenUploadFileSuccessState extends ServiceScreenState {
  final String path;

  const ServiceScreenUploadFileSuccessState(this.path);
}

class ServiceScreenUploadFileFailedState extends ServiceScreenState {
  final String message;

  const ServiceScreenUploadFileFailedState(this.message);
}
