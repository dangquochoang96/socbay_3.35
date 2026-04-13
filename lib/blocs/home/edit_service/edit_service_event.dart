import 'dart:io';

import 'package:socbay/data/model/request/update_task_request.dart';

abstract class EditServiceEvent {
  const EditServiceEvent();
}

class EditServiceStartedEvent extends EditServiceEvent {}

class EditServiceGetServicesEvent extends EditServiceEvent {}

class EditServiceUploadImageEvent extends EditServiceEvent {
  final List<File> files;

  EditServiceUploadImageEvent(this.files);
}

class EditServiceUploadFileEvent extends EditServiceEvent {}

class EditServiceUpdateTaskEvent extends EditServiceEvent {
  final UpdateTaskRequest updateTaskRequest;

  const EditServiceUpdateTaskEvent(this.updateTaskRequest);
}
