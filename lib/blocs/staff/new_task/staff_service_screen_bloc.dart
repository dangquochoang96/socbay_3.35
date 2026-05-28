import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/staff/new_task/staff_service_screen_event.dart';
import 'package:socbay/blocs/staff/new_task/staff_service_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/user_address.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/logger_util.dart';

import 'package:socbay/utils/auth_http.dart' as http;
import 'package:path/path.dart';

class StaffServiceScreenBloc
    extends Bloc<StaffServiceScreenEvent, StaffServiceScreenState> {
  final ApiRepository apiRepository;
  final Map<String, dynamic> args;
  bool isLoading = false;
  List<HomeServiceModel> services = [];
  List<UserAddress> listUserAddress = [];
  List<OrderModel> listProducts = [];
  List<TaskModel> listTaskModel = [];
  List<String> paths = [];
  UserProfile? customerInfor;
  StaffServiceScreenBloc({required this.apiRepository, required this.args})
    : super(StaffServiceScreenInitialState()) {
    on<StaffServiceScreenChangeTypeServiceEvent>(
      _mapChangeTypeServiceEventToState,
    );
    on<StaffServiceScreenCreateTaskEvent>(_mapCreateTaskEventToState);
    on<StaffServiceScreenUploadImageEvent>(_mapUploadImageEventToState);
    on<StaffServiceScreenCheckCustomerEvent>(_mapCheckCustomerEventToState);
    on<UserAddressScreenCreateUserAddressEvent>(_mapCreateUserAddressToState);
  }

  FutureOr<void> _mapChangeTypeServiceEventToState(
    StaffServiceScreenChangeTypeServiceEvent event,
    Emitter<StaffServiceScreenState> emit,
  ) {
    try {
      emit(StaffServiceScreenChangeTypeServiceState(event.typeService));
    } catch (ex) {
      LoggerUtil.error("---_mapChangeTypeServiceEventToState--- \n$ex");
    }
  }

  Future _mapCreateTaskEventToState(
    StaffServiceScreenCreateTaskEvent event,
    Emitter<StaffServiceScreenState> emit,
  ) async {
    isLoading = true;
    try {
      emit(StaffServiceScreenInitialState());
      List<String>? images = event.createTaskRequest.images;
      if (event.createTaskRequest.customerId == null ||
          event.createTaskRequest.customerId == 0 ||
          App.instance.userApp == null) {
        emit(
          const StaffServiceScreenCreateTaskFailedState("Chưa có khách hàng"),
        );
        isLoading = false;
        return;
      }
      Map<String, dynamic> args = {
        "customer": event.createTaskRequest.customerId,
        "time_start": event.createTaskRequest.timeStart.toString(),
        "time_end": event.createTaskRequest.timeEnd.toString(),
        "type_task": event.createTaskRequest.serviceId.toString(),
        "name": event.createTaskRequest.name.toString(),
        "des": event.createTaskRequest.des.toString(),
        "status": event.createTaskRequest.status.toString(),
        "priority": (event.createTaskRequest.priority).toString(),
        "staff": App.instance.userApp?.id,
        "user_create": "161",
        "product_id": event.createTaskRequest.productId == 0
            ? null
            : event.createTaskRequest.productId,
        "images": images,
        "address": event.createTaskRequest.address.toString(),
        "request_user_id": App.instance.userApp!.id.toString(),
      };
      var url = AppConfig.instance.apiUri(ApiEndpoints.taskCreate);
      var body = json.encode(args);

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
            emit(
              StaffServiceScreenCreateTaskSuccessState(
                task.id!,
                event.isSearch,
              ),
            );
          } else {
            emit(
              StaffServiceScreenCreateTaskFailedState(l["message"] ?? "Error"),
            );
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
    emit(StaffServiceScreenInitialState());
  }

  FutureOr<void> _mapUploadImageEventToState(
    StaffServiceScreenUploadImageEvent event,
    Emitter<StaffServiceScreenState> emit,
  ) async {
    isLoading = true;
    try {
      emit(StaffServiceScreenInitialState());
      paths.clear();
      var uri = Uri.parse(
        AppConfig.instance.apiUrl(ApiEndpoints.orderUploadImage),
      );
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
        emit(StaffServiceScreenUploadImageSuccessState(paths));
      } else {
        emit(
          const StaffServiceScreenUploadImageFailedState('No images uploaded'),
        );
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    emit(StaffServiceScreenInitialState());
  }

  Future<void> _mapCheckCustomerEventToState(
    StaffServiceScreenCheckCustomerEvent event,
    Emitter<StaffServiceScreenState> emit,
  ) async {
    isLoading = true;
    try {
      emit(StaffServiceScreenInitialState());
      var url = AppConfig.instance.apiUri(ApiEndpoints.orderByPhone, {
        'phone': event.phone,
      });
      var res = await http.post(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        if (l['success'] == true) {
          var m = Map<String, dynamic>.from(l["data"]);
          customerInfor = UserProfile.fromJson(m['users']);
          await _getProductByUser(customerInfor?.id ?? 0);
          emit(
            StaffServiceScreenCheckCustomerSuccessState(
              l['message'].toString(),
            ),
          );
        } else {
          emit(
            StaffServiceScreenCheckCustomerFailedState(l['message'].toString()),
          );
        }
      } else {
        emit(const StaffServiceScreenCheckCustomerFailedState('Error'));
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
      emit(const StaffServiceScreenCheckCustomerFailedState('Error'));
    }
    isLoading = false;
    emit(StaffServiceScreenInitialState());
  }

  Future<void> _getProductByUser(int id) async {
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.userProducts(id.toString()),
      );
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        var m = Map<String, dynamic>.from(l["data"]);
        listProducts = List<OrderModel>.from(
          m["listProducts"].map((model) => OrderModel.fromJson(model)),
        );
      }
    } catch (exception) {
      LoggerUtil.log(exception.toString());
    }
  }

  FutureOr<void> _mapCreateUserAddressToState(
    UserAddressScreenCreateUserAddressEvent event,
    Emitter<StaffServiceScreenState> emit,
  ) async {
    isLoading = true;
    emit(StaffServiceScreenInitialState());
    final res = await apiRepository.createUserAddress(event.userAddressRequest);
    isLoading = false;
    if (res.status == 1) {
      emit(const UserAddressScreenCreateAddressSuccessState());
    } else {
      emit(
        UserAddressScreenCreateAddressFailState(error: res.message.toString()),
      );
    }
    // emit(StaffServiceScreenInitialState());
  }
}
