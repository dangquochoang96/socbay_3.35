import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/user_info/user_new_order/user_new_order_event.dart';
import 'package:socbay/blocs/user_info/user_new_order/user_new_order_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:path/path.dart';

import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/utils/logger_util.dart';

class UserNewOrderBloc extends Bloc<UserNewOrderEvent, UserNewOrderState> {
  final ApiRepository apiRepository;
  // final Map<String, dynamic> args;
  TaskModel? taskModel;
  List<OrderModel> listProducts = [];
  List<ProductModel> listProductsAll = [];
  bool isLoading = false;
  int total = 0, chietKhau = 0, subSavePoint = 0, totalPay = 0, savePoint = 0;
  int paymentType = 1;
  List<String> paths = [];
  OrderDetailModel? orderDetail;
  UserNewOrderBloc({required this.apiRepository})
    : super(UserNewOrderInitialState()) {
    on<UserCreateOrderEvent>(_createNewOrder);
    on<UserNewOrderGetListProductsAllEvent>(_getProductAll);
    on<UserNewOrderUploadImageEvent>(_mapUploadImageEventToState);
  }

  Future<FutureOr<void>> _createNewOrder(
    UserCreateOrderEvent event,
    Emitter<UserNewOrderState> emit,
  ) async {
    isLoading = true;
    emit(UserNewOrderInitialState());
    try {
      if (event.productId == 0) {
        if (event.newProductId != null && event.newProductId != 0) {
          var url = AppConfig.instance.apiUri(ApiEndpoints.orderCreate, {
            'user_id': App.instance.userApp?.id.toString() ?? '',
            'listProducts': event.newProductId.toString(),
            'price': '0',
            'ngaymua': orderDetail?.dateOrder.toString(),
            'socaploc': '0',
            'count': '0',
            'chiet_khau': '0',
            'status': '4',
            'tich_diem': '0',
            'tru_diem': '0',
            'address': App.instance.userApp?.address.toString(),
            'type_payment': event.paymentType.toString(),
            'staff': '161',
            'sale_id': '161',
          });

          var res = await http.post(url);
          if (res.statusCode == HttpStatus.ok) {
            add(UserNewOrderGetListProductsAllEvent());
            var l = Map<String, dynamic>.from(json.decode(res.body));
            // LoggerUtil.log(jsonEncode(l));
            var m = Map<String, dynamic>.from(l["data"]);
            var orderDetailModel = List<OrderDetailModel>.from(
              m["orderDetails"].map(
                (model) => OrderDetailModel.fromJson(model),
              ),
            );
            event.productId = orderDetailModel[0].id;
          }
        }
      }
      if (event.productId != null && event.productId != 0) {
        List<String> listFilterId = [];
        List<String> listCoresName = [];
        List<String> listReplaceDate = [];
        List<String> listNextDate = [];
        List<String> listPrice = [];
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
            listFilterId.add("0");
            listCoresName.add(filterCore.name!);
            listReplaceDate.add(
              filterCore.replaceDate != null
                  ? filterCore.replaceDate!.split("/").reversed.join("-")
                  : "",
            );
            listNextDate.add(
              filterCore.replaceDatePromise != null
                  ? filterCore.replaceDatePromise!.split("/").reversed.join("-")
                  : "",
            );
            listPrice.add(filterCore.price ?? "0");
          }
        }
        for (OrderFilterCoreModel filterCore in lst2) {
          if (filterCore.name != null && filterCore.name != '') {
            listFilterId.add("0");
            listCoresName.add(filterCore.name!);
            listReplaceDate.add(
              filterCore.replaceDate != null
                  ? filterCore.replaceDate!.split("/").reversed.join("-")
                  : "",
            );
            listNextDate.add(
              filterCore.replaceDatePromise != null
                  ? filterCore.replaceDatePromise!.split("/").reversed.join("-")
                  : "",
            );
            listPrice.add(filterCore.price ?? "0");
          }
        }
        //Add cores
        List<String>? images = event.images;
        Map<String, dynamic> args = {
          'user_id': App.instance.userApp?.id.toString() ?? '',
          'chiet_khau': event.chietKhau.toString(),
          'status': '2',
          'tich_diem': event.savePoint.toString(),
          'tru_diem': event.subSavePoint.toString(),
          'type_payment': event.paymentType.toString(),
          'staff': '161',
          'sale_id': '161',
          'product_id': event.productId.toString(),
          'replaceDate': listReplaceDate,
          'replaceDatePromise': listNextDate,
          'name': listCoresName,
          'corePrice': listPrice,
          'listCores': listFilterId,
          "images": images,
          'address': App.instance.userApp?.address.toString(),
        };
        var body = json.encode(args);
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
            orderDetail = OrderDetailModel(id: n["id"]);
            if (event.lstNew.isNotEmpty || event.lstMaintain.isNotEmpty) {
              emit(UserCreateOrderCoresSuccessState());
            } else {
              emit(UserCreateOrderCoresFailState(l["message"]));
            }
          } else {
            emit(UserCreateOrderCoresFailState(l["message"]));
          }
        }
      }
    } catch (exception) {
      emit(UserCreateOrderCoresFailState("Có lỗi xảy ra!"));
    }
    isLoading = false;
    emit(UserNewOrderInitialState());
  }

  Future<FutureOr<void>> _getProductAll(
    UserNewOrderGetListProductsAllEvent event,
    Emitter<UserNewOrderState> emit,
  ) async {
    try {
      var url = AppConfig.instance.apiUri(ApiEndpoints.productListAll);
      var res = await http.get(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        listProductsAll = List<ProductModel>.from(
          l["data"].map((model) => ProductModel.fromJson(model)),
        );
        // LoggerUtil.log(jsonEncode(listProductsAll));
        emit(UserNewOrderGetListProductsAllSuccessState());
      }
    } catch (exception) {
      LoggerUtil.log(exception.toString());
    }
  }

  Future<void> _mapUploadImageEventToState(
    UserNewOrderUploadImageEvent event,
    Emitter<UserNewOrderState> emit,
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
      LoggerUtil.error(json.encode(ex));
    }
  }
}
