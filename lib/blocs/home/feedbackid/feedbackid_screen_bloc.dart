import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/feed_back_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/utils/logger_util.dart';
import 'package:path/path.dart';

import 'feedbackid_screen_event.dart';
import 'feedbackid_screen_state.dart';

class FeedbackScreenidBloc
    extends Bloc<FeedbackScreenidEvent, FeedbackScreenidState> {
  final ApiRepository apiRepository;
  Map<String, dynamic> args;
  bool isLoading = false;
  var ordersModel = <OrderFilterCoreModel>[];
  var feedBacksModel = <FeedBackModel>[];
  var feedbackDetail = FeedBackModel();
  int feedbackDetailId = 0;
  int currentOrderId = 0;
  List<String> paths = [];
  FeedbackScreenidBloc({required this.apiRepository, required this.args})
    : super(FeedbackScreenInitialidState()) {
    on<FeedbackScreenTabPressidEvent>(_mapTabPressEventToState);
    on<FeedbackCreateidEvent>(_mapCreateNewFeedbackEvent);
    on<UploadImageidEvent>(_mapUploadImageEventToState);
    on<FeedbackScreenListOfStaffidEvent>(_mapListFeedbackOfStaffEventToState);
    on<FeedbackDetailidEvent>(_mapGetDetailFeedBackEventToState);
    on<FeedbackUpdateidEvent>(_mapGetUpdateFeedBackEventToState);
    on<FeedbackProcessedidEvent>(_mapGetProcessedFeedBackEventToState);
  }

  Future<FutureOr<void>> _mapTabPressEventToState(
    FeedbackScreenTabPressidEvent event,
    Emitter<FeedbackScreenidState> emit,
  ) async {
    if (event.index == 0) {
      currentOrderId = int.parse(args["orderId"]);
      await _getListOrderByCustomer();
    } else {
      await _mapTabListFeedPressEventToState("CST");
    }
    emit(FeedbackScreenChangeTabidState(event.index));
  }

  Future<FutureOr<void>> _mapListFeedbackOfStaffEventToState(
    FeedbackScreenListOfStaffidEvent event,
    Emitter<FeedbackScreenidState> emit,
  ) async {
    await _mapTabListFeedPressEventToState("STAFF");
    emit(FeedbackScreenStaffInitialidState());
  }

  Future<FutureOr<void>> _mapTabListFeedPressEventToState(String type) async {
    Uri url;
    if (type == "CST") {
      url = AppConfig.instance.apiUri(ApiEndpoints.feedbacks, {
        "customer_id": args["id"].toString(),
      });
    } else {
      url = AppConfig.instance.apiUri(
        ApiEndpoints.feedbacksByStaff(args["id"]),
      );
    }
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      feedBacksModel.clear();
      feedBacksModel.addAll(
        List<FeedBackModel>.from(
          l["data"].map((model) => FeedBackModel.fromJson(model)),
        ),
      );
      // feedBacksModel.sort((a,b)=>a.createdAt!.compareTo(b.createdAt!));
    }
    //emit(const FeedbackScreenChangeTabState(1));
  }

  Future<void> _mapCreateNewFeedbackEvent(
    FeedbackCreateidEvent event,
    Emitter<FeedbackScreenidState> emit,
  ) async {
    List<String>? images = event.images;
    var url = AppConfig.instance.apiUri(ApiEndpoints.feedbacks);
    Map<String, dynamic> args = {
      "order_id": event.orderId.toString(),
      "description": event.description.toString(),
      "customer_id": App.instance.userApp?.id.toString(),
      "images": images,
    };
    var body = json.encode(args);
    var res = await http.post(
      url,
      body: body,
      headers: {'Content-type': 'application/json'},
    );
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      if (l["code"] == 1) {
        // var task = TaskModel.fromJson(l["data"]);
        emit(FeedbackCreateSuccessidState("Success"));
      } else {
        emit(FeedbackCreateErroridState(l["message"] ?? "Error"));
      }
    }
    emit(const FeedbackScreenChangeTabidState(1));
  }

  Future<void> _getListOrderByCustomer() async {
    var url = AppConfig.instance.apiUri(
      ApiEndpoints.orderListByCustomer(App.instance.userApp?.id),
    );
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      ordersModel.clear();
      ordersModel = List<OrderFilterCoreModel>.from(
        l["data"].map((model) => OrderFilterCoreModel.fromJson(model)),
      );
      // ordersModel.sort((a,b)=>a.createdAt!.compareTo(b.createdAt!));
      // ordersModel = ordersModel.reversed.toList();
    }
  }

  Future<void> _mapUploadImageEventToState(
    UploadImageidEvent event,
    Emitter<FeedbackScreenidState> emit,
  ) async {
    isLoading = true;
    try {
      paths.clear();
      var uri = AppConfig.instance.apiSecureUri(ApiEndpoints.orderUploadImage);
      for (var file in event.files) {
        if (await file.length() > 2000000) {
          emit(FeedbackUploadImagesErroridState('Error'));
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
        var res = await request.send();
        if (res.statusCode == HttpStatus.ok) {
          //var url = await res.stream.bytesToString();
          var l = Map<String, dynamic>.from(
            json.decode(await res.stream.bytesToString()),
          );
          if (l["data"]["image_link"] != "") {
            paths.add(l["data"]["image_link"]);
          }
        }
      }
      if (paths.isNotEmpty) {
        emit(FeedbackUploadImagesSuccessidState(paths));
      } else {
        emit(FeedbackUploadImagesErroridState('Error'));
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
  }

  Future<void> _mapGetDetailFeedBackEventToState(
    FeedbackDetailidEvent event,
    Emitter<FeedbackScreenidState> emit,
  ) async {
    isLoading = true;
    emit(FeedbackScreenStaffInitialidState());
    feedbackDetailId = int.parse(args["fbId"]);
    try {
      var uri = AppConfig.instance.apiUri(
        ApiEndpoints.feedbackById(feedbackDetailId),
      );
      var res = await http.get(uri);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        feedbackDetail = FeedBackModel.fromJson(l["data"]);
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    emit(FeedbackScreenStaffInitialidState());
  }

  Future<void> _mapGetUpdateFeedBackEventToState(
    FeedbackUpdateidEvent event,
    Emitter<FeedbackScreenidState> emit,
  ) async {
    isLoading = true;
    emit(FeedbackScreenStaffInitialidState());
    try {
      var url = AppConfig.instance
          .apiUri(ApiEndpoints.feedbackUpdate(feedbackDetailId), {
            "status": "2",
            "description": event.description.toString(),
            "user_id": App.instance.userApp?.id.toString(),
          });
      var res = await http.post(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        if (l["code"] == 1) {
          feedbackDetail = FeedBackModel.fromJson(l["data"]);
          emit(FeedbackUpdateSuccessidState("Success"));
        } else {
          emit(FeedbackUpdateErroridState(l["message"] ?? "Error"));
        }
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    emit(FeedbackScreenStaffInitialidState());
  }

  Future<void> _mapGetProcessedFeedBackEventToState(
    FeedbackProcessedidEvent event,
    Emitter<FeedbackScreenidState> emit,
  ) async {
    isLoading = true;
    emit(FeedbackScreenStaffInitialidState());
    try {
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.feedbackUpdate(feedbackDetailId),
        {"status": "2", "user_id": App.instance.userApp?.id.toString()},
      );
      var res = await http.post(url);
      if (res.statusCode == HttpStatus.ok) {
        var l = Map<String, dynamic>.from(json.decode(res.body));
        if (l["code"] == 1) {
          feedbackDetail = FeedBackModel.fromJson(l["data"]);
          emit(FeedbackUpdateSuccessidState("Success"));
        } else {
          emit(FeedbackUpdateErroridState(l["message"] ?? "Error"));
        }
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    emit(FeedbackScreenStaffInitialidState());
  }
}
