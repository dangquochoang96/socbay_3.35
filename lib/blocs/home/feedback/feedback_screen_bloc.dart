import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_event.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/feed_back_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/utils/logger_util.dart';
import 'package:path/path.dart';

class FeedbackScreenBloc
    extends Bloc<FeedbackScreenEvent, FeedbackScreenState> {
  final ApiRepository apiRepository;
  Map<String, dynamic> args;
  bool isLoading = false;
  var ordersModel = <OrderFilterCoreModel>[];
  var feedBacksModel = <FeedBackModel>[];
  var feedbackDetail = FeedBackModel();
  int feedbackDetailId = 0;
  int currentOrderId = 0;
  List<String> paths = [];
  FeedbackScreenBloc({required this.apiRepository, required this.args})
    : super(FeedbackScreenInitialState()) {
    on<FeedbackScreenTabPressEvent>(_mapTabPressEventToState);
    on<FeedbackCreateEvent>(_mapCreateNewFeedbackEvent);
    on<UploadImageEvent>(_mapUploadImageEventToState);
    on<FeedbackScreenListOfStaffEvent>(_mapListFeedbackOfStaffEventToState);
    on<FeedbackDetailEvent>(_mapGetDetailFeedBackEventToState);
    on<FeedbackUpdateEvent>(_mapGetUpdateFeedBackEventToState);
    on<FeedbackProcessedEvent>(_mapGetProcessedFeedBackEventToState);
  }

  Future<FutureOr<void>> _mapTabPressEventToState(
    FeedbackScreenTabPressEvent event,
    Emitter<FeedbackScreenState> emit,
  ) async {
    if (event.index == 0) {
      currentOrderId = int.parse(args["orderId"]);
      await _getListOrderByCustomer();
    } else {
      await _mapTabListFeedPressEventToState("CST");
    }
    emit(FeedbackScreenChangeTabState(event.index));
  }

  Future<FutureOr<void>> _mapListFeedbackOfStaffEventToState(
    FeedbackScreenListOfStaffEvent event,
    Emitter<FeedbackScreenState> emit,
  ) async {
    await _mapTabListFeedPressEventToState("STAFF");
    emit(FeedbackScreenStaffInitialState());
  }

  Future<FutureOr<void>> _mapTabListFeedPressEventToState(String type) async {
    Uri url;
    if (type == "CST") {
      url = AppConfig.instance.apiUri(ApiEndpoints.feedbacks, {
        "customer_id": App.instance.userApp?.id.toString(),
      });
    } else {
      url = AppConfig.instance.apiUri(
        ApiEndpoints.feedbacksByStaff(App.instance.userApp?.id.toString()),
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
    FeedbackCreateEvent event,
    Emitter<FeedbackScreenState> emit,
  ) async {
    List<String>? images = event.images;
    var url = AppConfig.instance.apiUri(ApiEndpoints.feedbacks);
    Map<String, dynamic> args = {
      "order_id": event.orderId.toString(),
      "description": event.description.toString(),
      "user_id": App.instance.userApp?.id.toString(),
      "images": images,
    };
    print("create feedback $args");
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
        emit(FeedbackCreateSuccessState("Success"));
      } else {
        emit(FeedbackCreateErrorState(l["message"] ?? "Error"));
      }
    }
    emit(const FeedbackScreenChangeTabState(1));
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
    UploadImageEvent event,
    Emitter<FeedbackScreenState> emit,
  ) async {
    isLoading = true;
    try {
      paths.clear();
      var uri = AppConfig.instance.apiSecureUri(ApiEndpoints.orderUploadImage);
      for (var file in event.files) {
        if (await file.length() > 2000000) {
          emit(FeedbackUploadImagesErrorState('Error'));
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
        emit(FeedbackUploadImagesSuccessState(paths));
      } else {
        emit(FeedbackUploadImagesErrorState('Error'));
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    //emit(const FeedbackScreenChangeTabState(0));
  }

  Future<void> _mapGetDetailFeedBackEventToState(
    FeedbackDetailEvent event,
    Emitter<FeedbackScreenState> emit,
  ) async {
    isLoading = true;
    emit(FeedbackScreenStaffInitialState());
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
    emit(FeedbackScreenStaffInitialState());
  }

  Future<void> _mapGetUpdateFeedBackEventToState(
    FeedbackUpdateEvent event,
    Emitter<FeedbackScreenState> emit,
  ) async {
    isLoading = true;
    emit(FeedbackScreenStaffInitialState());
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
          emit(FeedbackUpdateSuccessState("Success"));
        } else {
          emit(FeedbackUpdateErrorState(l["message"] ?? "Error"));
        }
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    emit(FeedbackScreenStaffInitialState());
  }

  Future<void> _mapGetProcessedFeedBackEventToState(
    FeedbackProcessedEvent event,
    Emitter<FeedbackScreenState> emit,
  ) async {
    isLoading = true;
    emit(FeedbackScreenStaffInitialState());
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
          emit(FeedbackUpdateSuccessState("Success"));
        } else {
          emit(FeedbackUpdateErrorState(l["message"] ?? "Error"));
        }
      }
    } catch (ex) {
      LoggerUtil.error(jsonEncode(ex));
    }
    isLoading = false;
    emit(FeedbackScreenStaffInitialState());
  }
}
