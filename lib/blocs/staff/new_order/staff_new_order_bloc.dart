import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_order_event.dart';
import 'package:socbay/blocs/staff/new_order/staff_new_order_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/order_payment_model.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/request/user_info_request.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';

import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/utils/logger_util.dart';
import 'package:path/path.dart';

class StaffNewOrderBloc extends Bloc<StaffNewOrderEvent, StaffNewOrderState> {
  final ApiRepository apiRepository;
  final Map<String, dynamic> args;
  ProductModel? product;
  TaskModel? taskModel;
  List<OrderModel> listProducts = [];
  List<ProductModel> listProductsAll = [];
  bool isLoading = false;
  int total = 0,
      chietKhau = 0,
      subSavePoint = 0,
      totalPay = 0,
      savePoint = 0,
      vatAmount = 0;
  num vatPercentage = 0;
  int paymentType = 1;
  OrderDetailModel? orderDetail;
  List<String> paths = [];

  bool get isRent => args['isRent'] == true;
  StaffNewOrderBloc({required this.apiRepository, required this.args})
    : super(StaffNewOrderInitialState()) {
    on<StaffNewOrderInitEvent>(_mapChangeTypeServiceEventToState);
    on<StaffNewOrderGetListProductsEvent>(_getProductByUser);
    on<StaffNewOrderGetListProductsAllEvent>(_getProductAll);
    on<StaffCreateOrderEvent>(_createNewOrder);
    on<StaffNewOrderUploadImageEvent>(_mapUploadImageEventToState);
    on<StaffNewOrderUploadPaymentProofEvent>(
      _mapUploadPaymentProofEventToState,
    );
  }

  Future<void> _mapChangeTypeServiceEventToState(
    StaffNewOrderInitEvent event,
    Emitter<StaffNewOrderState> emit,
  ) async {
    if (args['id'] == null) {
      return;
    }
    try {
      isLoading = true;
      emit(StaffNewOrderInitialState());
      //Get info task
      var url = isRent
          ? AppConfig.instance.apiUri(ApiEndpoints.rentTaskById(args['id']))
          : AppConfig.instance.apiUri(ApiEndpoints.taskById(args['id']));
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        taskModel = TaskModel.fromJson(l["data"]);
        subSavePoint = taskModel?.customer?.point ?? 0;
        add(StaffNewOrderGetListProductsEvent());
        add(StaffNewOrderGetListProductsAllEvent());
        //get product info
        if (taskModel != null && taskModel!.id != null) {
          final res1 = await apiRepository.getProductDetail(
            product: ProductModel(id: 18),
          );
          if (res1.data != null && res1.status == HttpStatus.ok) {
            product = res1.data!;
          }
        }
        isLoading = false;
        emit(StaffNewOrderInitialState());
      }
    } catch (ex) {
      LoggerUtil.log(ex.toString());
    }
  }

  Future<FutureOr<void>> _getProductByUser(
    StaffNewOrderGetListProductsEvent event,
    Emitter<StaffNewOrderState> emit,
  ) async {
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.userProducts(taskModel?.customer?.id.toString()),
      );
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        var m = Map<String, dynamic>.from(l["data"]);
        listProducts = List<OrderModel>.from(
          m["listProducts"].map((model) => OrderModel.fromJson(model)),
        );
        emit(StaffNewOrderGetListProductsSuccessState());
        emit(StaffNewOrderGetListProductsAllSuccessState());
      }
    } catch (exception) {
      LoggerUtil.log(exception.toString());
    }
  }

  Future<FutureOr<void>> _getProductAll(
    StaffNewOrderGetListProductsAllEvent event,
    Emitter<StaffNewOrderState> emit,
  ) async {
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.productListAll);
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        listProductsAll = List<ProductModel>.from(
          l["data"].map((model) => ProductModel.fromJson(model)),
        );
        LoggerUtil.log(jsonEncode(listProductsAll));
        emit(StaffNewOrderGetListProductsAllSuccessState());
      }
    } catch (exception) {
      LoggerUtil.log(exception.toString());
    }
  }

  Future<FutureOr<void>> _createNewOrder(
    StaffCreateOrderEvent event,
    Emitter<StaffNewOrderState> emit,
  ) async {
    isLoading = true;
    var isNew = false;
    emit(StaffNewOrderInitialState());
    await _updateAddressCustomer(event.newAddress);
    try {
      if (event.productId == 0) {
        if (event.newProductId != null && event.newProductId != 0) {
          var queryParams = {
            'user_id': taskModel?.customer?.id.toString() ?? "0",
            'listProducts': event.newProductId.toString(),
            'price': '0',
            'ngaymua': DateFormat("yyyy-MM-dd").format(DateTime.now()),
            'socaploc': '0',
            'count': '1',
            'chiet_khau': '0',
            'status': '4',
            'tich_diem': '0',
            'tru_diem': '0',
            'address': event.newAddressSP.toString(),
            'type_payment': event.paymentType.toString(),
            'staff': App.instance.userApp?.id.toString() ?? '',
            'sale_id': taskModel?.saleId?.toString(),
          };
          if (isRent) {
            queryParams.addAll({
              'type': '3',
              'monthly_rent': event.monthlyRent.toString(),
              'rental_period': event.rentalPeriod.toString(),
              'deposits': event.deposits.toString(),
              'rental_end_date': DateFormat(
                "yyyy-MM-dd",
              ).format(event.rentalEndDate),
            });
          }
          var url = AppConfig.instance.apiUri(
            ApiEndpoints.orderCreate,
            queryParams,
          );

          var res = await http.post(url);
          if (res.statusCode == HttpStatus.ok) {
            var l = Map<String, dynamic>.from(json.decode(res.body));
            LoggerUtil.log(jsonEncode(l));
            var m = Map<String, dynamic>.from(l["data"]);
            var orderDetailModel = List<OrderDetailModel>.from(
              m["orderDetails"].map(
                (model) => OrderDetailModel.fromJson(model),
              ),
            );
            event.productId = orderDetailModel[0].id;
            isNew = true;
          }
        }
      }
      if (event.productId != null && event.productId != 0) {
        String listFilterId = "";
        String listCoresName = "";
        String listReplaceDate = "";
        String listNextDate = "";
        String listPrice = "";
        var lst1 = event.lstNew;
        var lst2 = event.lstMaintain;
        for (OrderFilterCoreModel filterCore in lst1) {
          for (OrderFilterCoreModel core in lst2) {
            if (filterCore.name == core.name) {
              filterCore.replaceDatePromise = core.replaceDatePromise ?? "";
              lst2.remove(core);
              break;
            }
          }
        }
        for (OrderFilterCoreModel filterCore in lst1) {
          if (filterCore.name != null && filterCore.name != '') {
            listFilterId += "0,";
            listCoresName += "${filterCore.name},";
            listReplaceDate +=
                "${DateFormat("yyyy-MM-dd").format(DateTime.now())},";
            listNextDate += filterCore.replaceDatePromise != null
                ? "${filterCore.replaceDatePromise!.split("/").reversed.join("-")},"
                : ",";
            listPrice += filterCore.price != null
                ? "${filterCore.price},"
                : "0,";
          }
        }
        for (OrderFilterCoreModel filterCore in lst2) {
          if (filterCore.name != null && filterCore.name != '') {
            listFilterId += "0,";
            listCoresName += "${filterCore.name},";
            listReplaceDate +=
                "${DateFormat("yyyy-MM-dd").format(DateTime.now())},";
            listNextDate += filterCore.replaceDatePromise != null
                ? "${filterCore.replaceDatePromise!.split("/").reversed.join("-")},"
                : ",";
            listPrice += filterCore.price != null
                ? "${filterCore.price},"
                : "0,";
          }
        }
        //Add cores
        List<String>? images = event.images;
        Map<String, dynamic> args = {
          'user_id':
              taskModel?.customer?.id.toString() ?? event.usernameId.toString(),
          'chiet_khau': event.chietKhau.toString(),
          'status': isNew
              ? event.lstMaintain.isEmpty
                    ? '4'
                    : '2'
              : (listNextDate.replaceAll(',', '').isEmpty ? '4' : '2'),
          if (isRent) ...{'type': '4'},
          'vat': event.vatAmount.toString(),
          'ghichu': event.ghichu,
          'tich_diem': event.savePoint.toString(),
          'tru_diem': event.subSavePoint.toString(),
          'type_payment': event.paymentType.toString(),
          'staff': App.instance.userApp?.id.toString(),
          'product_id': event.productId.toString(),
          'replaceDate': listReplaceDate.isEmpty
              ? ""
              : listReplaceDate.substring(0, listReplaceDate.length - 1),
          'replaceDatePromise': listNextDate.isEmpty
              ? ""
              : listNextDate.substring(0, listNextDate.length - 1),
          'name': listCoresName.isEmpty
              ? ""
              : listCoresName.substring(0, listCoresName.length - 1),
          'corePrice': listPrice.isEmpty
              ? ""
              : listPrice.substring(0, listPrice.length - 1),
          'listCores': listFilterId.isEmpty
              ? ""
              : listFilterId.substring(0, listFilterId.length - 1),
          "images": images,
          'sale_id': taskModel?.saleId?.toString() ?? event.saleId.toString(),
          'address': event.newAddressSP.toString(),
          'sub_type': event.subType.toString(),
          if (event.paymentType == 3) ...{
            'cash_amount': event.cashAmount?.toString(),
            'transfer_amount': event.transferAmount?.toString(),
          },
        };
        var body = json.encode(args);
        if (kDebugMode) {
          print('data: $body');
        }
        var urlAddCores = AppConfig.instance.apiUri(
          ApiEndpoints.orderSaveRepair,
        );
        var resAddCores = await http.post(
          urlAddCores,
          body: body,
          headers: {'Content-type': 'application/json'},
        );
        if (resAddCores.statusCode == HttpStatus.ok) {
          var l = Map<String, dynamic>.from(json.decode(resAddCores.body));
          if (l["code"] == 200) {
            var m = Map<String, dynamic>.from(l["data"]);
            var n = Map<String, dynamic>.from(m["order"]);
            OrderPaymentModel? orderPayment;
            if (m["order_payment"] != null) {
              orderPayment = OrderPaymentModel.fromJson(
                Map<String, dynamic>.from(m["order_payment"]),
              );
            }
            orderDetail = OrderDetailModel.fromJson({
              ...n,
              'order_payment': orderPayment?.toJson(),
            });
            var urleditTask = AppConfig.instance.apiUri(
              isRent
                  ? ApiEndpoints.rentTaskEdit(taskModel?.id)
                  : ApiEndpoints.taskEdit(taskModel?.id),
              {
                'type_task': taskModel?.type.toString(),
                'name': taskModel?.name ?? "",
                'des': taskModel?.des ?? "",
                'status': '3',
                'priority': taskModel?.priority?.toString() ?? '0',
                'time_start': DateFormat(
                  'dd/MM/yyyy HH:ss',
                ).format(DateTime.parse(taskModel!.timeStart.toString())),
                'time_end': DateFormat(
                  'dd/MM/yyyy HH:ss',
                ).format(DateTime.now()),
                'staff': App.instance.userApp?.id.toString(),
                'user_create': App.instance.userApp?.id.toString(),
                'product_id': event.productId.toString(),
                'order_id': orderDetail?.id.toString(),
              },
            );
            var resEditTask = await http.post(urleditTask);
            if (resEditTask.statusCode == HttpStatus.ok &&
                (event.lstNew.isNotEmpty || event.lstMaintain.isNotEmpty)) {
              emit(
                StaffCreateOrderCoresSuccessState(
                  order: orderDetail,
                  orderPayment: orderPayment,
                ),
              );
            } else {
              emit(StaffCreateOrderCoresFailState(l["message"]));
            }
          } else {
            emit(StaffCreateOrderCoresFailState(l["message"]));
          }
        }
      }
    } catch (exception) {
      emit(StaffCreateOrderCoresFailState("Có lỗi xảy ra!"));
    }
    isLoading = false;
    emit(StaffNewOrderInitialState());
  }

  Future<void> _mapUploadImageEventToState(
    StaffNewOrderUploadImageEvent event,
    Emitter<StaffNewOrderState> emit,
  ) async {
    isLoading = true;
    try {
      // emit(StaffNewOrderInitialState());
      paths.clear();
      var uri = Uri.parse(
        AppConfig.instance.apiUrl(ApiEndpoints.orderUploadImage),
      );
      for (var file in event.files) {
        isLoading = true;
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
        isLoading = false;
        emit(ServiceScreenUploadImageSuccessState(paths));
      } else {
        isLoading = false;
        emit(const ServiceScreenUploadImageFailedState('Error'));
      }
    } catch (ex) {
      LoggerUtil.error(ex.toString());
    }
  }

  Future<void> _mapUploadPaymentProofEventToState(
    StaffNewOrderUploadPaymentProofEvent event,
    Emitter<StaffNewOrderState> emit,
  ) async {
    isLoading = true;
    emit(StaffNewOrderInitialState());
    try {
      var uri = Uri.parse(
        AppConfig.instance.apiUrl(ApiEndpoints.uploadPaymentProof),
      );
      var request = http.MultipartRequest('POST', uri);
      request.fields['order_payment_id'] = event.orderPaymentId.toString();
      request.fields['notes'] = event.notes;
      if (event.paymentStatus != null) {
        request.fields['payment_status'] = event.paymentStatus.toString();
      }
      for (var file in event.files) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'payment_image_bill[]',
            file.readAsBytesSync(),
            filename: basename(file.path),
          ),
        );
      }

      var resStream = await request.send();
      var response = await http.Response.fromStream(resStream);
      if (response.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(response.body));
        if (l["code"] == 200 || l["code"] == 1) {
          isLoading = false;
          emit(StaffNewOrderUploadPaymentProofSuccessState(
            paymentStatus: event.paymentStatus,
          ));
        } else {
          isLoading = false;
          emit(
            StaffNewOrderUploadPaymentProofFailState(
              l["message"]?.toString() ?? "Upload ảnh bill lỗi!",
            ),
          );
        }
      } else {
        isLoading = false;
        emit(
          const StaffNewOrderUploadPaymentProofFailState(
            "Upload ảnh bill lỗi!",
          ),
        );
      }
    } catch (ex) {
      isLoading = false;
      LoggerUtil.error(ex.toString());
      emit(
        const StaffNewOrderUploadPaymentProofFailState("Upload ảnh bill lỗi!"),
      );
    }
  }

  FutureOr<void> _updateAddressCustomer(String? newAddress) async {
    try {
      UserInfoRequest userInfo = UserInfoRequest(
        phone: taskModel?.customer?.phone,
        birthday: taskModel?.customer?.birthday
            ?.substring(0, 10)
            .split("-")
            .reversed
            .join("/"),
        address: newAddress,
        email: taskModel?.customer?.email,
        avatar: taskModel?.customer?.avatar,
      );
      await apiRepository.updateUserInfo(userInfo);
    } catch (ex) {
      LoggerUtil.log(ex.toString());
    }
  }
}
