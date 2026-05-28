import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/staff/rent_task_sale/rent_booking_service_event.dart';
import 'package:socbay/blocs/staff/rent_task_sale/rent_booking_service_state.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/application.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/user_address.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/utils/logger_util.dart';

import 'package:socbay/utils/auth_http.dart' as http;
import 'package:path/path.dart';

class RentBookingServiceBloc
    extends Bloc<RentBookingServiceEvent, RentBookingServiceState> {
  final ApiRepository apiRepository;
  final Map<String, dynamic> args;
  bool isLoading = false;
  List<UserAddress> listUserAddress = [];
  List<OrderModel> listProducts = [];
  List<String> paths = [];
  List<HomeServiceModel> listService = [];
  UserProfile? customerInfo;

  RentBookingServiceBloc({required this.apiRepository, required this.args})
    : super(StaffServiceScreenSaleInitialState()) {
    on<StaffServiceScreenSaleChangeTypeServiceEvent>(
      _mapChangeTypeServiceEventToState,
    );
    on<StaffServiceScreenSaleCreateTaskEvent>(_mapCreateTaskEventToState);
    on<StaffServiceScreenSaleUploadImageEvent>(_mapUploadImageEventToState);
    on<StaffServiceSaleScreenCheckCustomerEvent>(_mapCheckCustomerEventToState);
    on<UserAddressScreenSaleCreateUserAddressEvent>(
      _mapCreateUserAddressToState,
    );
  }

  FutureOr<void> _mapChangeTypeServiceEventToState(
    StaffServiceScreenSaleChangeTypeServiceEvent event,
    Emitter<RentBookingServiceState> emit,
  ) {
    try {
      emit(StaffServiceScreenSaleChangeTypeServiceState(event.typeService));
    } catch (ex) {
      LoggerUtil.error("---_mapChangeTypeServiceEventToState--- \n$ex");
    }
  }

  Future _mapCreateTaskEventToState(
    StaffServiceScreenSaleCreateTaskEvent event,
    Emitter<RentBookingServiceState> emit,
  ) async {
    isLoading = true;
    try {
      emit(StaffServiceScreenSaleInitialState());
      List<String>? images = event.createTaskRequest.images;
      if (event.createTaskRequest.customerId == null ||
          event.createTaskRequest.customerId == 0 ||
          App.instance.userApp == null) {
        emit(
          const StaffServiceScreenSaleCreateTaskFailedState(
            "Lỗi tạo công việc mới",
          ),
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
        "staff": event.createTaskRequest.staffId.toString(),
        "user_create": App.instance.userApp?.id.toString(),
        "product_id": event.createTaskRequest.productId == 0
            ? null
            : event.createTaskRequest.productId,
        "images": images,
        "address": event.createTaskRequest.address.toString(),
        "request_user_id": App.instance.userApp!.id.toString(),
      };
      var url = AppConfig.instance.apiUri(ApiEndpoints.rentTaskCreate);
      var body = json.encode(args);
      print('body');
      print(body);
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
              StaffServiceScreenSaleCreateTaskSuccessState(
                task.id!,
                event.isSearch,
              ),
            );
          } else {
            emit(
              StaffServiceScreenSaleCreateTaskFailedState(
                l["message"] ?? "Errorr",
              ),
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
    emit(StaffServiceScreenSaleInitialState());
  }

  FutureOr<void> _mapUploadImageEventToState(
    StaffServiceScreenSaleUploadImageEvent event,
    Emitter<RentBookingServiceState> emit,
  ) async {
    isLoading = true;
    try {
      paths.clear();
      emit(StaffServiceScreenSaleInitialState());
      var uri = Uri.parse(
        AppConfig.instance.apiUrl(ApiEndpoints.orderUploadImage),
      );
      for (var file in event.files) {
        if (await file.length() > 2000000) {
          emit(const StaffServiceScreenSaleUploadImageFailedState('Error'));
          continue;
        }
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
        emit(StaffServiceScreenSaleUploadImageSuccessState(paths));
      } else {
        emit(const StaffServiceScreenSaleUploadImageFailedState('Error'));
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    emit(StaffServiceScreenSaleInitialState());
  }

  Future<void> _mapCheckCustomerEventToState(
    StaffServiceSaleScreenCheckCustomerEvent event,
    Emitter<RentBookingServiceState> emit,
  ) async {
    isLoading = true;
    try {
      emit(StaffServiceScreenSaleInitialState());
      var url = AppConfig.instance.apiUri(ApiEndpoints.orderByPhone, {
        'phone': event.phone,
      });
      var res = await http.post(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        if (l['success'] == true) {
          var m = Map<String, dynamic>.from(l["data"]);
          customerInfo = UserProfile.fromJson(m['users']);
          print(customerInfo);
          await _getProductByUser(customerInfo?.id ?? 0);
          emit(
            StaffServiceScreenSaleCheckCustomerSuccessState(
              l['message'].toString(),
            ),
          );
        } else {
          emit(
            StaffServiceScreenSaleCheckCustomerFailedState(
              l['message'].toString(),
            ),
          );
        }
      } else {
        emit(const StaffServiceScreenSaleCheckCustomerFailedState('Error'));
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
      emit(const StaffServiceScreenSaleCheckCustomerFailedState('Error'));
    }
    isLoading = false;
    emit(StaffServiceScreenSaleInitialState());
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
    UserAddressScreenSaleCreateUserAddressEvent event,
    Emitter<RentBookingServiceState> emit,
  ) async {
    isLoading = true;
    emit(StaffServiceScreenSaleInitialState());
    final res = await apiRepository.createUserAddress(event.userAddressRequest);
    isLoading = false;
    if (res.status == 1) {
      emit(const UserAddressScreenSaleCreateAddressSuccessState());
    } else {
      emit(
        UserAddressScreenSaleCreateAddressFailState(
          error: res.message.toString(),
        ),
      );
    }
    emit(StaffServiceScreenSaleInitialState());
  }
}
