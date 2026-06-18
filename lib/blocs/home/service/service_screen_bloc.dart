import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/home/service/service_screen_event.dart';
import 'package:socbay/blocs/home/service/service_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/user_address.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';

import 'package:socbay/utils/auth_http.dart' as http;
import 'package:path/path.dart';

class ServiceScreenBloc extends Bloc<ServiceScreenEvent, ServiceScreenState> {
  final ApiRepository apiRepository;
  final Map<String, dynamic> args;
  bool isLoading = false;
  String productId = "0";
  List<UserAddress> listUserAddress = [];
  List<OrderModel> listProducts = [];
  List<String> paths = [];
  List<HomeServiceModel> listService = [];

  ServiceScreenBloc({required this.apiRepository, required this.args})
    : super(ServiceScreenInitialState()) {
    on<ServiceScreenChangeTypeServiceEvent>(_mapChangeTypeServiceEventToState);
    on<ServiceScreenCreateTaskEvent>(_mapCreateTaskEventToState);
    on<ServiceScreenUserAddressEvent>(_mapGetListUserAddressEventToState);
    on<ServiceScreenUploadImageEvent>(_mapUploadImageEventToState);
  }

  FutureOr<void> _mapChangeTypeServiceEventToState(
    ServiceScreenChangeTypeServiceEvent event,
    Emitter<ServiceScreenState> emit,
  ) {
    try {
      emit(ServiceScreenChangeTypeServiceState(event.typeService));
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
  }

  Future _mapCreateTaskEventToState(
    ServiceScreenCreateTaskEvent event,
    Emitter<ServiceScreenState> emit,
  ) async {
    isLoading = true;
    try {
      emit(ServiceScreenInitialState());
      List<String>? images = event.createTaskRequest.images;
      Map<String, dynamic> params = {
        "customer": App.instance.userApp!.id.toString(),
        "time_start": event.createTaskRequest.timeStart.toString(),
        "time_end": event.createTaskRequest.timeEnd.toString(),
        "type_task": event.createTaskRequest.serviceId.toString(),
        "name": event.createTaskRequest.name.toString(),
        "des": event.createTaskRequest.des.toString(),
        "status": event.createTaskRequest.status.toString(),
        "priority": (event.createTaskRequest.priority).toString(),
        "staff": event.createTaskRequest.staffId.toString(),
        "user_create": "161",
        "product_id": event.createTaskRequest.productId == 0
            ? null
            : event.createTaskRequest.productId,
        "images": images,
        //new
        "address": event.createTaskRequest.address.toString(),
        "request_user_id": App.instance.userApp!.id.toString(),
      };
      if (kDebugMode) {
        print(params);
      }
      var url = AppConfig.instance.apiUri(ApiEndpoints.taskCreate);
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
            var task = TaskModel.fromJson(l["data"]);
            emit(ServiceScreenCreateTaskSuccessState(task.id!, event.isSearch));
          } else {
            emit(ServiceScreenCreateTaskFailedState(l["message"] ?? "Error"));
          }
        }
      } catch (ex) {
        LoggerUtil.error(ex.toString());
      }
    } catch (ex) {
      LoggerUtil.log("_mapCreateTaskEventToState");
      LoggerUtil.error(ex.toString());
    }
    isLoading = false;
    emit(ServiceScreenInitialState());
  }

  FutureOr<void> _mapGetListUserAddressEventToState(
    ServiceScreenUserAddressEvent event,
    Emitter<ServiceScreenState> emit,
  ) async {
    isLoading = true;
    emit(ServiceScreenInitialState());
    listService = HomeServiceModel.getServiceList();
    productId = args["productId"] ?? "0";
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.userProducts(App.instance.userApp?.id.toString()),
      );
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        var m = Map<String, dynamic>.from(l["data"]);
        listProducts = List<OrderModel>.from(
          m["listProducts"].map((model) => OrderModel.fromJson(model)),
        );
        emit(ServiceScreenUserAddressSuccessState());
      } else {
        emit(ServiceScreenUserAddressFailedState());
      }
    } catch (exception) {
      LoggerUtil.log(exception.toString());
    }
    isLoading = false;
    emit(ServiceScreenInitialState());
  }

  Future<void> _mapUploadImageEventToState(
    ServiceScreenUploadImageEvent event,
    Emitter<ServiceScreenState> emit,
  ) async {
    isLoading = true;
    try {
      paths.clear();
      emit(ServiceScreenInitialState());
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
        emit(ServiceScreenUploadImageSuccessState(paths));
      } else {
        emit(const ServiceScreenUploadImageFailedState('Error'));
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    emit(ServiceScreenInitialState());
  }
}
