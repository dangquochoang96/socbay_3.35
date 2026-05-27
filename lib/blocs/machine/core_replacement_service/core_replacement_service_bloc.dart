import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/machine/core_replacement_service/core_replacement_service_event.dart';
import 'package:socbay/blocs/machine/core_replacement_service/core_replacement_service_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/api_endpoints.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:socbay/utils/logger_util.dart';
import 'package:collection/collection.dart';

class CoreReplacementServiceBloc
    extends Bloc<CoreReplatementServiceEvent, CoreReplatementServiceState> {
  CoreReplacementServiceBloc({required this.apiRepository, required this.args})
    : super(CoreReplatementServiceInitialState()) {
    on<CoreReplatementServiceStartEvent>(_getStartEventToState);
    on<OrderFeedbackTaskProcessedEvent>(_createOrUpdateFeedbackTaskProcessed);
    on<OrderPaymentStatusUpdatedEvent>(_updatePaymentStatus);
  }
  final ApiRepository apiRepository;
  OrderDetailModel? orderDetailModel;
  Map<String, dynamic> args;
  bool isLoading = true;
  double rating = 0;
  String createDate = "";
  var des = "";
  double totalPriceForOrder = 0;
  FutureOr<void> _getStartEventToState(
    CoreReplatementServiceStartEvent event,
    Emitter<CoreReplatementServiceState> emit,
  ) async {
    var orderDetail = args["orderDetail"] as OrderDetailModel;
    var url = AppConfig.instance.apiUri(
      ApiEndpoints.userDetailHistory(orderDetail.id),
    );

    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      var l = Map<String, dynamic>.from(json.decode(res.body));
      var m = Map<String, dynamic>.from(l["data"]);
      try {
        orderDetailModel = OrderDetailModel.fromJson(m["order"]);
        rating = orderDetailModel!.rate != null
            ? double.parse(orderDetailModel!.rate!)
            : 0.0;
        des = orderDetailModel?.comment ?? "";
        createDate =
            orderDetailModel?.orderFilterCoresModel?.reduce((value, element) {
              if (value.replaceDate != null) {
                return value;
              } else {
                return element;
              }
            }).replaceDate ??
            "";
        if (orderDetailModel != null &&
            orderDetailModel!.orderFilterCoresModel != null) {
          final groupedCores = groupBy(
            orderDetailModel!.orderFilterCoresModel!,
            (OrderFilterCoreModel core) => core.orderId,
          );
          totalPriceForOrder = groupedCores[orderDetailModel!.id.toString()]!
              .map((core) => double.tryParse(core.price ?? "0") ?? 0)
              .sum;
        }
      } catch (ex) {
        LoggerUtil.error(ex.toString());
      }
    }
    isLoading = false;
    emit(CoreReplatementServiceInitialState());
  }

  FutureOr<void> _updatePaymentStatus(
    OrderPaymentStatusUpdatedEvent event,
    Emitter<CoreReplatementServiceState> emit,
  ) async {
    var orderDetail = args["orderDetail"] as OrderDetailModel;
    var url = AppConfig.instance.apiUri(
      ApiEndpoints.userUpdatePaymentStatus(orderDetail.id),
    );
    try {
      var response = await http.post(url, body: {'payment_status': '1'});
      if (response.statusCode == HttpStatus.ok) {
        orderDetailModel = OrderDetailModel.fromJson({
          ...orderDetailModel!.toJson(),
          'payment_status': '1',
        });
        emit(CoreReplatementServiceInitialState());
      } else {
        LoggerUtil.log("Error updating payment status: ${response.body}");
      }
    } catch (ex) {
      LoggerUtil.log(ex.toString());
    }
    emit(CoreReplatementServiceInitialState());
  }

  FutureOr<void> _createOrUpdateFeedbackTaskProcessed(
    OrderFeedbackTaskProcessedEvent event,
    Emitter<CoreReplatementServiceState> emitter,
  ) async {
    //do something
    rating = event.rating;
    des = event.des;
    var orderDetail = args["orderDetail"] as OrderDetailModel;
    var url = AppConfig.instance.apiUri(
      ApiEndpoints.userRate(App.instance.userApp?.id, orderDetail.id),
      {'rate': rating.toString(), 'comment': des},
    );
    try {
      await http.post(url);
    } catch (ex) {
      LoggerUtil.log(ex.toString());
    }
    emitter(CoreReplatementServiceInitialState());
  }
}
