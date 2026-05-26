abstract class EditServiceState {
  const EditServiceState();
}

class EditServiceInitialState extends EditServiceState {}

class EditServiceUploadImageSuccessState extends EditServiceState {
  final List<String> paths;

  const EditServiceUploadImageSuccessState(this.paths);
}

class EditServiceUploadImageFailedState extends EditServiceState {
  final String message;

  const EditServiceUploadImageFailedState(this.message);
}

class EditServiceUploadFileSuccessState extends EditServiceState {
  final String path;

  const EditServiceUploadFileSuccessState(this.path);
}

class EditServiceUploadFileFailedState extends EditServiceState {
  final String message;

  const EditServiceUploadFileFailedState(this.message);
}

class EditServiceSuccessState extends EditServiceState {}

class EditServiceFailedState extends EditServiceState {}
