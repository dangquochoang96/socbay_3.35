import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/home/edit_service/edit_service_event.dart';
import 'package:socbay/blocs/home/edit_service/edit_service_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/utils/logger_util.dart';
import '../../../data/model/home_service_model.dart';
import '../../../data/model/task_model.dart';
import '../../../data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:path/path.dart';

class EditServiceBloc extends Bloc<EditServiceEvent, EditServiceState> {
  final ApiRepository apiRepository;
  bool isLoading = false;
  Map<String, dynamic> args;
  List<HomeServiceModel> services = [];
  TaskModel? taskModel;
  List<String> paths = [];

  EditServiceBloc({required this.apiRepository, required this.args})
    : super(EditServiceInitialState()) {
    on<EditServiceStartedEvent>(_mapStartedEventToState);
    on<EditServiceGetServicesEvent>(_mapGetServicesEventToState);
    on<EditServiceUpdateTaskEvent>(_mapUpdateTaskEventToState);
    on<EditServiceUploadImageEvent>(_mapUploadImageEventToState);
  }

  FutureOr<void> _mapStartedEventToState(
    EditServiceStartedEvent event,
    Emitter<EditServiceState> emit,
  ) async {
    isLoading = true;
    emit(EditServiceInitialState());
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.taskById(args['id']));
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        taskModel = TaskModel.fromJson(l["data"]);
        add(EditServiceGetServicesEvent());
      }
    } catch (ex) {
      LoggerUtil.error(ex.toString());
    }
    isLoading = false;
    emit(EditServiceInitialState());
  }

  Future<void> _mapGetServicesEventToState(
    EditServiceGetServicesEvent event,
    Emitter<EditServiceState> emit,
  ) async {
    isLoading = true;
    emit(EditServiceInitialState());
    services.clear();
    services = HomeServiceModel.taskServiceList;
    isLoading = false;
    emit(EditServiceInitialState());
  }

  Future<void> _mapUploadImageEventToState(
    EditServiceUploadImageEvent event,
    Emitter<EditServiceState> emit,
  ) async {
    isLoading = true;
    try {
      paths.clear();
      // emit(EditServiceInitialState());

      var uri = AppConfig.instance.apiSecureUri(ApiEndpoints.orderUploadImage);
      for (var file in event.files) {
        var request = http.MultipartRequest('POST', uri);
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            file.readAsBytesSync(),
            filename: basename(file.path),
          ),
        );
        // add file to multipart
        var resStream = await request.send();
        var response = await http.Response.fromStream(resStream);
        if (response.statusCode == HttpStatus.ok) {
          var l = Map<String, dynamic>.from(json.decode(response.body));
          if (l["data"]["image_link"] != "") {
            paths.add(l["data"]["image_link"]);
          }
        }
      }
      if (paths.isNotEmpty) {
        emit(EditServiceUploadImageSuccessState(paths));
      } else {
        emit(const EditServiceUploadImageFailedState('Error'));
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    // emit(EditServiceInitialState());
  }

  Future<void> _mapUpdateTaskEventToState(
    EditServiceUpdateTaskEvent event,
    Emitter<EditServiceState> emit,
  ) async {
    isLoading = true;
    emit(EditServiceInitialState());
    List<String>? images = event.updateTaskRequest.images;
    // List<int>? products = event.updateTaskRequest.products;
    if (event.updateTaskRequest.customerId == null ||
        event.updateTaskRequest.customerId == 0 ||
        App.instance.userApp == null) {
      isLoading = false;
      return;
    }
    Map<String, dynamic> params = {
      "time_star": event.updateTaskRequest.timeStart.toString(),
      "time_end": event.updateTaskRequest.timeEnd.toString(),
      "type_task": event.updateTaskRequest.serviceId.toString(),
      "name": event.updateTaskRequest.name.toString(),
      "staff": event.updateTaskRequest.staffId.toString(),
      "priority": (event.updateTaskRequest.priority).toString(),
      "status": event.updateTaskRequest.status.toString(),
      "des": event.updateTaskRequest.des.toString(),
      "user_create": App.instance.userApp!.id.toString(),
      "customer": event.updateTaskRequest.customerId,
      "images": images,
    };
    var url = AppConfig.instance.apiUri(ApiEndpoints.taskEdit(args['id']));
    var body = json.encode(params);

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {'Content-type': 'application/json'},
      );
      if (response.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(response.body));
        if (l["code"] == 1) {
          // var task = TaskModel.fromJson(l["data"]);
          emit(EditServiceSuccessState());
        } else {
          emit(EditServiceFailedState());
        }
      }
    } catch (ex) {
      LoggerUtil.error(ex.toString());
    }
    isLoading = false;
    emit(EditServiceInitialState());
  }
}
