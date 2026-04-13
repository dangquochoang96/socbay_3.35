import 'dart:io';

import 'package:socbay/data/model/request/create_task_request.dart';

abstract class ServiceScreenEvent {
  const ServiceScreenEvent();
}

class ServiceScreenChangeTypeServiceEvent extends ServiceScreenEvent {
  final String typeService;

  ServiceScreenChangeTypeServiceEvent(this.typeService);
}

class ServiceScreenCreateTaskEvent extends ServiceScreenEvent {
  final CreateTaskRequest createTaskRequest;
  final bool isSearch;

  ServiceScreenCreateTaskEvent(this.createTaskRequest, this.isSearch);
}

class ServiceScreenUserAddressEvent extends ServiceScreenEvent {}

class ServiceScreenUploadImageEvent extends ServiceScreenEvent {
  final List<File> files;

  ServiceScreenUploadImageEvent(this.files);
}

class ServiceScreenUploadFileEvent extends ServiceScreenEvent {}
